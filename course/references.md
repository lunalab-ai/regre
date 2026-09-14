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
