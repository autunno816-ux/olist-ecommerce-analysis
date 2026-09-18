<# Update the portable Power BI snapshot after running sql/export_results.psql.
   Close Olist in Power BI first. This script reads aggregate CSVs only.
   Reopen Olist.pbip, Refresh, verify all pages, then save Olist.pbix again.
#>
[CmdletBinding()]
param([switch]$Check)
$ErrorActionPreference = 'Stop'
$culture = [Globalization.CultureInfo]::InvariantCulture
$utf8 = New-Object Text.UTF8Encoding($false)
$resultPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'reports/results'
$manifestPath = Join-Path $PSScriptRoot 'snapshot-manifest.json'
$modelPath = Join-Path $PSScriptRoot 'Olist.SemanticModel/model.bim'
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$model = Get-Content -LiteralPath $modelPath -Raw -Encoding UTF8 | ConvertFrom-Json
$sourceRows = @{}
$changes = @()
foreach ($source in $manifest.sources) {
    $csvPath = Join-Path $resultPath $source.file
    $rows = @(Import-Csv -LiteralPath $csvPath -Encoding UTF8)
    if ($rows.Count -eq 0) { throw "Empty source: $($source.file)" }
    $sourceRows[$source.file] = $rows
    $hash = (Get-FileHash -LiteralPath $csvPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($hash -ne $source.sha256) { $changes += $source.file }
    $source.sha256 = $hash
}
if ($Check) {
    if ($changes.Count) { throw ('Snapshot is stale: ' + ($changes -join ', ')) }
    Write-Output 'All 10 aggregate source hashes match the Power BI snapshot.'
    return
}
function ConvertTo-MValue($value, $dataType) {
    if ($null -eq $value -or [string]$value -eq '') { return 'null' }
    switch ($dataType) {
        'string' { return '"' + ([string]$value).Replace('#(', '#(#)(').Replace('"', '""').Replace("`r", '#(cr)').Replace("`n", '#(lf)') + '"' }
        'dateTime' {
            $d = [datetime]::ParseExact([string]$value, 'yyyy-MM-dd', $culture)
            return '#date(' + $d.Year + ',' + $d.Month + ',' + $d.Day + ')'
        }
        default {
            $n = [decimal]::Parse([string]$value, [Globalization.NumberStyles]::Float, $culture)
            return $n.ToString($culture)
        }
    }
}
foreach ($spec in $manifest.tables) {
    $recipe = [string]$spec.recipe
    if ($recipe.StartsWith('top10:')) {
        $parts = $recipe.Split(':')
        $sortColumn = $parts[2]
        $rows = @($sourceRows[$parts[1]] | Sort-Object { [decimal]::Parse($_.$sortColumn, $culture) } -Descending | Select-Object -First 10)
    } elseif ($recipe.StartsWith('repeat_contribution:')) {
        $repeat = @($sourceRows['q2_customer_segments.csv'] | Where-Object customer_type -eq 'Repeat')
        if ($repeat.Count -ne 1) { throw 'Expected one Repeat customer segment.' }
        $rows = @()
        $i = 0
        foreach ($pair in @(@('Customers', 'customer_share_pct'), @('Orders', 'order_share_pct'), @('Sales', 'revenue_share_pct'))) {
            $i++
            $value = [decimal]::Parse([string]$repeat[0].($pair[1]), $culture) / 100
            $rows += [pscustomobject][ordered]@{metric=$pair[0]; share=$value.ToString($culture); sort_order=$i}
        }
    } else { $rows = $sourceRows[$recipe] }
    $table = @($model.model.tables | Where-Object name -eq $spec.table)[0]
    if ($null -eq $table -or $rows.Count -eq 0) { throw "Missing model table/source: $($spec.table)" }
    $columns = @($table.columns | Where-Object { $_.sourceColumn })
    $types = foreach ($column in $columns) {
        if ($column.name -notin $rows[0].PSObject.Properties.Name) { throw "Missing column $($column.name) in $recipe" }
        $mType = switch ($column.dataType) { 'string' {'nullable text'} 'dateTime' {'nullable date'} 'int64' {'Int64.Type'} 'double' {'nullable number'} default {throw "Unsupported type: $($column.dataType)"} }
        "$($column.sourceColumn) = $mType"
    }
    $body = foreach ($row in $rows) {
        $values = foreach ($column in $columns) { ConvertTo-MValue $row.($column.sourceColumn) $column.dataType }
        '    {' + ($values -join ', ') + '}'
    }
    $expression = "let`n    Source = #table(type table [" + ($types -join ', ') + "], {`n" + ($body -join ",`n") + "`n    })`nin`n    Source"
    $table.partitions[0].source.expression = @($expression -split "`n")
}
# Complete validation before writing either file. No database credentials or raw data are read.
[IO.File]::WriteAllText($modelPath, ($model | ConvertTo-Json -Depth 100) + "`n", $utf8)
[IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 100) + "`n", $utf8)
Write-Output 'Updated 16 aggregate/presentation tables. Open Olist.pbip, Refresh, inspect all pages, and save a new PBIX/PDF.'
