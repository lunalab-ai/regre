# W11A data and shared-code provenance

- salary-survey-w11a.csv: the official Salary Survey46 source rows, same order and S/X/E/M values. S annual USD, X years; E1 HighSchool/E2 Bachelor/E3 Graduate; M0 non-management/M1 management.
- preemployment-w11a.csv: official Preemployment20 rows, unchanged TEST/RACE/JPERF values and row order. RACE0 White/RACE1 minority group in the historical textbook example. Scores retain their original scale; no invented physical units.
- Data companion: https://www1.aucegypt.edu/faculty/hadi/RABE6/ ; Preemployment source: https://www1.aucegypt.edu/faculty/hadi/RABE6/Data6/Preemployment.txt
- Original row ID is its position in the unchanged file. No automatic deletion or recoding.
- diagnostics-learning-w11a.R is a byte-identical copy of the existing src/diagnostics-learning.R. categorical-trace-w11a.R is a byte-identical copy of src/categorical-trace.R. They expose reusable calculations, not exercise answer lookups.
- Main textbook: Korean sixth edition2024, sections6.1–6.4. Raw scans and private exercise solutions are excluded.
