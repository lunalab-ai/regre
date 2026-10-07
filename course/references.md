# 전체 참고자료

[강의 홈](../README.md)

## 강의 소개와 회귀분석의 개요

[강의 원문](../course/notion/week01/01_week01_orientation_regression_intro.md)

- Ali S. Hadi, Samprit Chatterjee, *Chatterjee 예제를 통한 회귀분석 제6판: R 활용*, Chapter 1.
- 강현철, *예제를 통한 회귀분석 제6판 제1장 서론* 강의자료.
- 수업용 R 코드: 주교재 Chapter 2 예제 중 R 객체, 데이터 구조, 데이터 읽기 관련 부분.

## RStudio 실습 환경 설정, R 문법 복습 및 데모

[강의 원문](../course/notion/w02a/w02a-rstudio-r-basics.md)

https://cran.r-project.org/

https://cran.r-project.org/doc/manuals/r-release/R-intro.html

https://docs.posit.co/ide/user/ide/get-started/

## R 문법 복습 (2)

[강의 원문](../course/notion/w02b/w02b-r-syntax-2.md)

https://cran.r-project.org/doc/manuals/r-release/R-data.html

https://cran.r-project.org/doc/manuals/r-release/R-intro.html

https://github.com/lunalab-ai/regre/blob/main/src/r-syntax-tools.R#L15

https://github.com/lunalab-ai/regre/blob/main/src/r-syntax-tools.R#L36

https://shiny.posit.co/r/getstarted/build-an-app/reactivity-essentials/reactive-elements.html

## 산점도, 공분산, 상관계수와 회귀분석의 기본 아이디어

[강의 원문](../course/notion/w03a/w03a-association.md)

- Ali S. Hadi·Samprit Chatterjee, 『Chatterjee 예제를 통한 회귀분석 제6판: R 활용』, 자유아카데미, 2024, 3.2–3.3, pp.92–100. 그림 3.1–3.4의 교육적 개념과 표 3.4의 수리시간 수치를 참고했다. 원본 스캔은 포함하지 않았다.
- 수리시간 데이터는 기존 수업의 `Computer.Repair.txt`를 재사용했다. 이 노트의 0.9937은 14개 관측을 반올림하지 않고 재계산한 값이다.
- [R 공식 문서: 공분산·상관계수](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/cor.html): 기본 Pearson 방식과 표본 공분산의 분모.
- [R 공식 문서: Anscombe 데이터](https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/anscombe.html): 내장 데이터와 네 산점도 비교. 원출처 F. J. Anscombe (1973), “Graphs in Statistical Analysis”.
- [NIST: Scatter Plot](https://www.itl.nist.gov/div898/handbook/eda/section3/scatterp.htm): 형태·산포·이상점 탐색 및 연관성과 인과의 구분.
- 그림 1–7, 10–12의 배치·색상·예시와 풀이 예제 1–4, 6은 수업용으로 새로 설계했다. 그림 8은 R 내장 데이터, 그림 9는 교재 사례의 수치를 직접 그린 것이다. 합성 자료와 실제 사례를 구분해 표시했다.

https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/anscombe.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/cor.html

https://www.itl.nist.gov/div898/handbook/eda/section3/scatterp.htm

## 단순선형회귀모형: 회귀계수 추정·검정·신뢰구간과 R 실습

[강의 원문](../course/notion/w03b/w03b-simple-regression.md)

- Ali S. Hadi·Samprit Chatterjee, 『Chatterjee 예제를 통한 회귀분석 제6판: R 활용』, 자유아카데미, 2024, 3.4–3.7, pp.100–114. 모형·추정·계수 검정·신뢰구간과 수리시간 사례를 참고했다.
- [R lm 공식 문서](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html), [summary.lm 공식 문서](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html), [confint 공식 문서](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/confint.html), 2026-09-15 확인.
- 수리시간 수치는 기존 수업의 14행 데이터를 R로 재계산했다. 그림 5와 9는 교재 그림 3.5·3.6의 수학적 관계를 새 배치로 독립 제작했다. 원본 스캔은 포함하지 않았다.
- 그림 1·6·12는 독립 개념도, 2–4·8은 설명용 도식/합성 자료, 7·11은 참 계수를 명시한 정규오차 시뮬레이션, 10은 실제 수리자료의 계산이다. 시뮬레이션을 실제 회사의 추가 관측으로 해석하지 않는다.

https://github.com/lunalab-ai/regre/blob/2026-fall-w03b/src/slr-api.md

https://github.com/lunalab-ai/regre/blob/2026-fall-w03b/src/slr-tools.R

https://lunalab-ai.github.io/regre/apps/w03b/edit/index.html

https://lunalab-ai.github.io/regre/w03b.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/confint.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html

## 단순선형회귀모형 마무리: 예측·적합성·특수 회귀모형

[강의 원문](../course/notion/w04a/w04a-prediction.md)

- 주교재: Hadi·Chatterjee, 『Chatterjee 예제를 통한 회귀분석 제6판: R 활용』, 자유아카데미(2024), 3.8–3.12, pp.115–126. 용어·수식 관계와 장 순서를 따르며 설명은 수업용으로 새로 작성했다.
- R 공식 문서: [predict.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/predict.lm.html), [summary.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html), [lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html), [t.test](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/t.test.html). 2026-09-20 확인.
- 수리자료는 이전 차시와 동일한 공개 수업 자료를 재사용했다. 수치와 그림은 반올림 전 14행으로 다시 계산했다. 작은 네 점, 곡선 예시, 대응표본은 별도로 만든 합성 자료다.
- 모든 그림은 수학적 관계와 실제 계산을 바탕으로 독립 제작했다. 교재 스캔을 사용하지 않았다. 외삽·인과성·R² 비교의 주의, F와 t의 연결, 웹앱 활동은 이해를 돕기 위한 수업의 추가 설명이다.

https://github.com/lunalab-ai/regre/blob/2026-fall-w04a/src/prediction-api.md

https://github.com/lunalab-ai/regre/blob/main/course/handouts/w04a-quiz.md

https://github.com/lunalab-ai/regre/tree/2026-fall-w04a/labs/student/w04a

https://lunalab-ai.github.io/regre/apps/w04a/edit/index.html

https://lunalab-ai.github.io/regre/w04a.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/predict.lm.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/t.test.html

## 다중선형회귀모형과 모수 추정: 평균 예측에서 여러 설명변수로

[강의 원문](../course/notion/w05a/w05a-multiple-regression.md)

- 주교재: 『Chatterjee 예제를 통한 회귀분석 제6판: R 활용』, 4.1–4.5, pp.136–145(4.6 시작 전). 표4.2는 선별 원본 발췌, 나머지 도식·그래프는 실제 계산과 명시한 합성 자료로 제작했습니다. 3.9절 보강은 별도 자료입니다.
- [R attitude](https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/attitude.html), [lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html), [summary.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html), [predict.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/predict.lm.html), [model.matrix](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/model.matrix.html). 2026-09-28 확인.
- 퍼센트포인트 해석, 평균 기준 손실 비교, 고정 단면, 인과성·외삽의 주의와 앱 조립 활동은 이해를 돕는 추가 설명입니다. 이번 범위 이후의 검정·예측구간을 이미 학습한 것으로 전제하지 않습니다.

https://colab.research.google.com/github/lunalab-ai/regre/blob/2026-fall-w05a-v2/notebooks/student/w05a_multiple_regression.ipynb

https://github.com/lunalab-ai/regre/blob/2026-fall-w05a-v2/src/mlr-api.md

https://github.com/lunalab-ai/regre/blob/main/course/handouts/w05a-quiz.md

https://github.com/lunalab-ai/regre/blob/main/course/notion/w05a/w05a-r2-remediation.md

https://lunalab-ai.github.io/regre/apps/w05a/edit/index.html

https://lunalab-ai.github.io/regre/w05a.html

https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/attitude.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/model.matrix.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/predict.lm.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html

[강의 원문](../course/notion/w05a/w05a-r2-remediation.md)

- 주교재 3.9, pp.117–121, 식3.44–3.47 및 그림3.7을 기준으로 용어와 관계를 설명했습니다. 그림3.7은 원본 발췌, 나머지는 독립 제작입니다.
- [R 공식 summary.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html): R²의 기준과 잔차분산. [lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html): 최소제곱 적합과 절편. 2026-09-28 확인.
- 네 점은 수업용 합성 자료입니다. 실제 조사 자료나 새로운 실험 결과로 해석하지 않습니다. 방향 화살표·단계적 비교·오해 점검은 수업을 위해 추가한 설명입니다.

https://colab.research.google.com/github/lunalab-ai/regre/blob/2026-fall-w05a-v2/notebooks/student/w05a_deviations.ipynb

https://github.com/lunalab-ai/regre/blob/main/course/notion/w05a/w05a-multiple-regression.md

https://lunalab-ai.github.io/regre/apps/w05a/edit/index.html

https://lunalab-ai.github.io/regre/w05a.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/lm.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html

## 다중회귀의 해석·추론·예측: 계수에서 불확실성으로

[강의 원문](../course/notion/w05b/w05b-interpretation.md)

- 주교재 §4.5 연결 및 §4.6–4.8, pp.144–151. 교재 용어와 범위를 유지했습니다. 그림 A1–A7은 수업용 원본 도식 또는 R 계산 그래프입니다.
- [R attitude](https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/attitude.html), [scale](https://stat.ethz.ch/R-manual/R-devel/library/base/html/scale.html), [summary.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html). 2026-09-29 본문 확인.
- 좌표 변경 비유, 모의 반복표본, 가정 단계도, 과잉 해석을 막는 비교 문장은 이해를 돕는 추가 설명입니다. 행렬 유도는 [수학 보충](w05b-math.md)에 있습니다.

https://fancy-ballcap-a15.notion.site/R-3e87fd00109f811d9e0cc8890bf2a0b0

https://lunalab-ai.github.io/regre/w05b.html

https://stat.ethz.ch/R-manual/R-devel/library/base/html/scale.html

https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/attitude.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html

[강의 원문](../course/notion/w05b/w05b-inference.md)

- 주교재 §4.9–4.12, pp.152–171. 표4.4만 선별 원본 발췌; 나머지 그림은 명시한 R 자료와 수업용 도식으로 제작했습니다. 표4.7의 두 변수 계수는 전체 정밀도의 R 결과를 사용합니다.
- [R summary.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html), [anova.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/anova.lm.html), [predict.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/predict.lm.html), [vcov](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/vcov.html). 2026-09-29 본문 확인.
- 비기각의 해석, 동일 반응·동일 행의 비교, 공동 관측 영역, 앱 입력/출력 활동은 개념 이해를 돕는 보완 설명입니다. 행렬과 제약 계산의 상세 유도는 수학 보충에서 확인하세요.

https://lunalab-ai.github.io/regre/apps/w05b/edit/index.html

https://lunalab-ai.github.io/regre/w05b.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/anova.lm.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/predict.lm.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/summary.lm.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/vcov.html

[강의 원문](../course/notion/w05b/w05b-workbook.md)

https://lunalab-ai.github.io/regre/w05b.html

[강의 원문](../course/notion/w05b/w05b-math.md)

주교재 §4.6–4.11의 식과 제약 사례를 R 내장 attitude로 검산했습니다. [R vcov](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/vcov.html), [anova.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/anova.lm.html), [predict.lm](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/predict.lm.html), 2026-09-29 확인. 재매개화와 가정 구분, 잘못된 반응 비교의 교정은 수업용 추가 해설입니다.

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/anova.lm.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/predict.lm.html

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/vcov.html

## 회귀진단: 모형위반의 검출

[강의 원문](../course/notion/w06a/w06a-assumptions.md)

https://lunalab-ai.github.io/regre/w06a.html

https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/anscombe.html

https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/attitude.html

[강의 원문](../course/notion/w06a/w06a-residuals.md)

https://colab.research.google.com/github/lunalab-ai/regre/blob/2026-fall-w06a/notebooks/student/w06a_residuals.ipynb

https://github.com/lunalab-ai/regre/blob/2026-fall-w06a/src/diagnostics-api.md

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/influence.measures.html

[강의 원문](../course/notion/w06a/w06a-graphs.md)

https://colab.research.google.com/github/lunalab-ai/regre/blob/2026-fall-w06a/notebooks/student/w06a_graphs.ipynb

https://github.com/lunalab-ai/regre/blob/2026-fall-w06a/src/diagnostics-api.md

https://lunalab-ai.github.io/regre/apps/w06a/edit/index.html

https://www1.aucegypt.edu/faculty/hadi/RABE6/Data6/Hamilton.Data.txt

[강의 원문](../course/notion/w06a/w06a-workbook.md)

https://colab.research.google.com/github/lunalab-ai/regre/blob/2026-fall-w06a/notebooks/student/w06a_graphs.ipynb

https://colab.research.google.com/github/lunalab-ai/regre/blob/2026-fall-w06a/notebooks/student/w06a_residuals.ipynb

https://lunalab-ai.github.io/regre/apps/w06a/edit/index.html

https://lunalab-ai.github.io/regre/w06a.html

[강의 원문](../course/notion/w06a/w06a-math.md)

https://stat.ethz.ch/R-manual/R-devel/library/stats/html/influence.measures.html

## 중간고사 대비 복습 ①: 회귀분석의 개요와 R 기초

[강의 원문](../course/notion/w06b/w06b-review-workbook.md)

https://cran.r-project.org/doc/manuals/r-release/R-intro.html

https://github.com/lunalab-ai/regre/blob/2026-fall-w06b/src/review-foundations-api.md

https://lunalab-ai.github.io/regre/apps/w06b/

https://lunalab-ai.github.io/regre/w06b.html

https://stat.ethz.ch/R-manual/R-devel/library/base/html/Control.html

https://stat.ethz.ch/R-manual/R-devel/library/base/html/Extract.html

https://stat.ethz.ch/R-manual/R-devel/library/base/html/NA.html

https://stat.ethz.ch/R-manual/R-devel/library/base/html/mean.html
