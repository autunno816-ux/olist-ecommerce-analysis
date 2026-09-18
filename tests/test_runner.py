import csv
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
from run_analysis import export_csv


class ExportTests(unittest.TestCase):
    def test_empty_segment_exports_column_headers(self):
        with tempfile.TemporaryDirectory() as folder:
            path = Path(folder) / 'empty.csv'
            export_csv(path, [], fieldnames=['interval_bucket', 'customer_count'])
            with path.open(encoding='utf-8', newline='') as f:
                self.assertEqual(list(csv.reader(f)), [['interval_bucket', 'customer_count']])


if __name__ == '__main__':
    unittest.main()
