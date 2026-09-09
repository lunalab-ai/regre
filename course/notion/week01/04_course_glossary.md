# 핵심 용어집

## 회귀분석 용어

| 용어 | 영어 | 의미 |
|---|---|---|
| 회귀분석 | regression analysis | 변수들 사이의 함수적 관계를 탐색·요약·평가·예측하는 방법 |
| 반응변수 | response variable | 설명하거나 예측하려는 결과 $Y$ |
| 종속변수 | dependent variable | 반응변수의 다른 이름 |
| 목표변수 | target variable | 예측 관점에서 반응변수를 부르는 이름 |
| 설명변수 | explanatory variable | 반응변수와 관련된 입력 $X$ |
| 예측변수 | predictor | 예측에 사용하는 설명변수 |
| 공변량 | covariate | 설명변수를 가리키는 또 다른 용어 |
| 회귀계수 | regression coefficient | 데이터로 추정하는 미지의 모수 $\beta$ |
| 오차 | random error | 모형의 체계적인 부분이 설명하지 못하는 불일치 $\varepsilon$ |
| 적합값 | fitted value | 학습 데이터의 설명변수에 모형을 적용해 얻은 값 `ŷ` |
| 예측값 | predicted value | 주어진 설명변수 값에서 모형으로 예측한 반응값 |
| 잔차 | residual | 관측값과 적합값의 차이 `e = y − ŷ` |
| 단순회귀 | simple regression | 설명변수가 하나인 회귀 |
| 다중회귀 | multiple regression | 설명변수가 둘 이상인 회귀 |
| 일변량 회귀 | univariate regression | 반응변수가 하나인 회귀 |
| 다변량 회귀 | multivariate regression | 반응변수가 둘 이상인 회귀 |
| 선형모형 | linear model | 회귀계수가 모형식에 선형적으로 들어가는 모형 |
| 모형 적합 | model fitting | 데이터로부터 모형의 모수를 추정하는 과정 |
| 회귀진단 | regression diagnostics | 잔차, 가정, 이상값과 영향력을 점검하는 과정 |

## R 실습 용어

| 용어 | 의미 |
|---|---|
| R | 통계 계산과 데이터 분석을 위한 언어 및 실행 엔진 |
| RStudio | R 코드, 콘솔, 파일, 그래프와 도움말을 통합한 IDE |
| Quarto | 설명과 실행 코드를 함께 포함하는 재현 가능한 문서 시스템 |
| `.qmd` | Quarto 문서의 파일 확장자 |
| 코드 청크 | 문서 안에서 실행되는 R 코드 블록 |
| Render | `.qmd`의 설명과 코드 출력을 결합하여 HTML 등의 결과를 만드는 과정 |
| 패키지 | R의 기능을 추가하는 코드 묶음 |
| 데이터프레임 | 행은 관측개체, 열은 변수인 표 형태의 R 객체 |
| 작업 폴더 | 상대경로의 기준이 되는 현재 폴더 |
| RStudio 프로젝트 | 코드, 데이터와 문서의 공통 기준 폴더를 정하는 프로젝트 파일 |
| Shiny | R로 인터랙티브 웹 애플리케이션을 만드는 패키지 |

## 기억할 표현

$$
Y=f(X_1,X_2,\ldots,X_p)+\varepsilon
$$

관측값을 체계적인 관계와 설명되지 않은 오차의 합으로 표현한다는 뜻입니다.

```text
회귀분석 = 문제 진술 → 데이터 → 모형 적합 → 진단 → 비판 → 수정 → 사용
```
