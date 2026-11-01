# W10A data and helper provenance

- hand-five-w10a.csv: original teaching construction, arbitrary x/y units; five rows (0,1),(1,2),(2,2),(3,4),(4,4).
- nyrivers-w10a.csv: official RABE6 NY Rivers20 rows, same numbers as W09B; Nitrogen original scale (physical unit not verified), ComIndl original land-use scale.
- scottish-hills-w10a.csv: official RABE6 Scottish Hills35 rows; Time seconds, Distance miles, Climb total ascent feet; row23 Time2859. MASS::hills uses a different time scale and one differing observation.
- salary-survey-w10a.csv: official RABE6 Salary.Survey.txt46 rows, S annual USD, X experience years, E1 high school/E2 bachelor/E3graduate, M0nonmanager/M1manager. All46 retained; omit33 only in separately labeled sensitivity.
- Official data index: https://www1.aucegypt.edu/faculty/hadi/RABE6/ . Textbook Chatterjee Regression by Example6e, Korean2024, §5.1–5.15 and§6.1–6.3.
- diagnostics-base-w09b.R is the unchanged previous diagnostics.R byte-normalized toLF; influence/effects modules retain the previous additive numeric OLS boundary. diagnostics-learning.R adds inspectable teaching and explicit factor models; do not pass factor/interaction models to the old numeric-only diagnostics helpers.
- Files from prior weeks support cumulative app tabs; their original provenance remains in README.md/W09B-SOURCES.md. No textbook scan or exercise answer bank is bundled.
