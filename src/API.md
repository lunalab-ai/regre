# 공통 R API

## 공통 R 파일을 읽는 순서

`source(tools_path)`는 해당 R 파일의 함수 정의를 현재 실행 환경에 읽어 들이며, 함수 실행이나 학습을 대신하지 않는다. tools_path는 파일 경로 문자열이다. `classify_minutes(minutes, threshold=45)`를 그 다음 호출하면 숫자 벡터와 기준값으로 ordered factor를 반환한다. 결측은 실제 NA가 아닌 missing 범주로 표시한다. `summarize_by_shift(data)`는 shift/minutes 열의 표를 받아 shift/n_observed/mean_minutes 표를 새로 반환한다. minutes는 숫자이며 전부 결측인 집단 평균은 NaN이다. 두 함수는 원본 입력을 변경하지 않는다.

- [classify_minutes 정의·인자·출력](https://github.com/lunalab-ai/regre/blob/main/src/r-syntax-tools.R#L15)
- [summarize_by_shift 정의·인자·출력](https://github.com/lunalab-ai/regre/blob/main/src/r-syntax-tools.R#L36)
