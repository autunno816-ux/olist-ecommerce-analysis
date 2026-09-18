# Optional chart automation

[PostgreSQL reproduction](postgresql-setup.md) · [Project overview](../README.md)

The primary project is PostgreSQL / pgAdmin SQL. The SQL workflow reproduces the analysis and exports all 10 result tables without Python.

The Python helper was added during repository preparation to regenerate the presentation figures, run an additional set of checks and support an in-process DuckDB execution option. It is supplementary tooling rather than the original project's required environment.

## Regenerate the figures

Use Python 3.11 or later; the helper was tested with Python 3.13. From the repository root:

```bash
python -m venv .venv
```

Activate the environment in Windows PowerShell with `.venv\Scripts\Activate.ps1`, or in macOS/Linux with `source .venv/bin/activate`. Then:

```bash
python -m pip install -r requirements.txt
python -m unittest discover -s tests -v
python scripts/run_analysis.py --data-dir data/raw
```

The helper loads the CSVs into DuckDB, executes the same four analytical SQL files and writes 10 result tables, 33 quality checks, source hashes and 17 figures. It does not connect to or modify PostgreSQL. Its quality profile omits the additional PostgreSQL empty-orders guard. `--no-charts` exports only the evidence tables; `--output-dir` changes the output destination. The default output location is `reports/`, so rerunning replaces those local generated artifacts.

`reports/results/metrics.json` records the helper-generated figures' source manifest and execution metadata. [postgres_validation.json](../reports/results/postgres_validation.json) records the separate native PostgreSQL verification. SQL query changes should be validated on PostgreSQL first.
