# W06B student practice. Deliberate faulty code stays commented.
locations <- c("data","labs/student/w06b/data","../../labs/student/w06b/data")
data_dir <- locations[file.exists(file.path(locations,"review-foundations.R"))][1]
if(is.na(data_dir)) stop("R/QMD와 동봉 data 폴더를 함께 보관하세요.")
source(file.path(data_dir,"review-foundations.R"))
demo <- review_data()
demo_summary <- review_summary(demo$minutes)
print(demo)
print(demo_summary)

# Predict first: which denominator describes observed values?
comparison <- rbind(review_summary(demo$minutes,"exclude"),
                    review_summary(demo$minutes,"keep"),
                    review_summary(demo$minutes,"zero"))
print(comparison)
print(review_summary(demo$minutes,scale=60))
barplot(demo$minutes,names.arg=demo$id,col="#087f8c",
        ylab="Minutes",main="Synthetic work records (NA is not zero)")

# ## Q43 · 주어진 식을 코드로 옮기기
# 
# 유형: R · 난이도: 기초 · 빈칸
# 
# 주어진 예측식은 시간(분)=9+4×부품 수이다. 빈칸을 채우고 parts=3일 때 계산 과정과 단위를 쓰시오. 계수를 추정하는 문제가 아니다.
# 
# ```r
# parts <- 3
# predicted <- ___ + ___ * parts
# predicted
# ```
# Q43 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q44 · 단위를 바꿀 때 식 전체를 바꾸기
# 
# 유형: R · 난이도: 기초 · 빈칸
# 
# 시간(분)=2+3*x이다. x=4일 때 초 단위 예측을 구하도록 빈칸을 채우고 괄호의 이유를 쓰시오.
# 
# ```r
# x <- 4
# seconds <- ___ * (2 + 3*x)
# seconds
# ```
# Q44 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q45 · 짝을 유지하는 데이터프레임
# 
# 유형: R · 난이도: 기초 · 빈칸
# 
# 첫 작업은 부품 1개·시간 12분, 둘째는 부품 3개·시간 26분이다. 같은 행에 짝이 유지되도록 빈칸을 채우고 행과 열 개수를 쓰시오.
# 
# ```r
# d <- data.frame(parts=c(1,3), minutes=c(___,___))
# d
# ```
# Q45 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q46 · 행과 열로 한 값을 고르기
# 
# 유형: R · 난이도: 기초 · 빈칸
# 
# 둘째 작업의 시간 하나를 출력하도록 빈칸을 채우고, 쉼표 앞뒤가 무엇인지 설명하시오.
# 
# ```r
# d <- data.frame(parts=c(1,3,5), minutes=c(12,26,40))
# d[___, "minutes"]
# ```
# Q46 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q47 · 열 이름과 객체 이름 구별
# 
# 유형: R · 난이도: 적용 · 에러 찾기
# 
# 새 R 세션에서 다음 코드가 실패한다. 이유를 설명하고 시간 열 전체를 선택하도록 고치시오. minutes라는 별도 객체는 없다.
# 
# ```r
# d <- data.frame(parts=c(1,2), minutes=c(15,25))
# d[, minutes]
# ```
# Q47 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q48 · 숫자처럼 보이는 문자
# 
# 유형: R · 난이도: 적용 · 에러 찾기
# 
# 다음 덧셈이 실패하는 이유를 설명하고, 원자료가 모두 숫자를 의미하는 문자열임을 확인했다는 조건 아래 각 값에 5를 더하도록 고치시오.
# 
# ```r
# x <- c(10,"20",30)
# x + 5
# ```
# Q48 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q49 · 평균의 분자와 분모
# 
# 유형: R · 난이도: 기초 · 빈칸
# 
# x의 산술평균을 sum과 length만으로 계산하도록 채우고, 중간 합과 개수를 쓰시오.
# 
# ```r
# x <- c(6,12,18)
# avg <- ___(x) / ___(x)
# avg
# ```
# Q49 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q50 · 결측을 제외한 관측값 선택
# 
# 유형: R · 난이도: 적용 · 빈칸
# 
# 관측된 값만 남겨 평균을 계산하려 한다. 빈칸에 논리 조건을 채우고 선택된 값과 평균을 쓰시오. is.na(x)는 결측 위치에서 TRUE를 준다.
# 
# ```r
# x <- c(8,NA,16)
# observed <- x[___]
# mean(observed)
# ```
# Q50 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q51 · 오류 없이 나온 NA 해석
# 
# 유형: R · 난이도: 적용 · 에러 찾기
# 
# 관측된 값만의 평균을 원했지만 아래 결과가 NA이다. 실행 오류인지 설명하고 목적에 맞게 고치시오.
# 
# ```r
# x <- c(5,NA,15)
# mean(x)
# ```
# Q51 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q52 · 실행되지만 분모가 잘못된 코드
# 
# 유형: R · 난이도: 통합 · 에러 찾기
# 
# 관측된 값만의 평균을 계산하려 한다. 다음 코드가 왜 틀렸는지 원래 출력과 올바른 출력의 계산 과정을 비교하고 고치시오.
# 
# ```r
# x <- c(10,NA,20)
# sum(x,na.rm=TRUE)/length(x)
# ```
# Q52 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q53 · 계산과 원본 변경은 다른 일
# 
# 유형: R · 난이도: 적용 · 출력 예측
# 
# 실행하지 말고 두 print의 출력을 순서대로 쓰고 그 이유를 설명하시오.
# 
# ```r
# x <- c(2,4,6)
# y <- x*10
# print(y)
# print(x)
# ```
# Q53 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q54 · 결측과 조건을 함께 읽기
# 
# 유형: R · 난이도: 통합 · 출력 예측
# 
# keep, selected, mean(selected)의 출력을 순서대로 쓰시오. &는 원소별로 두 조건을 모두 만족하는지 검사한다.
# 
# ```r
# x <- c(10,NA,30,40)
# keep <- !is.na(x) & x >= 30
# selected <- x[keep]
# print(keep)
# print(selected)
# mean(selected)
# ```
# Q54 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q55 · 두 조건으로 행 고르기
# 
# 유형: R · 난이도: 적용 · 빈칸
# 
# 오전(AM)이면서 시간이 30분 이하인 행을 선택하도록 빈칸을 채우고 남는 id를 쓰시오. &는 그리고, |는 또는이다.
# 
# ```r
# d <- data.frame(id=c("A","B","C"),shift=c("AM","PM","AM"),minutes=c(20,25,40))
# d[d$shift=="AM" ___ d$minutes<=30, ]
# ```
# Q55 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q56 · 반복문에서 합 쌓기
# 
# 유형: R · 난이도: 적용 · 빈칸
# 
# 다음 반복문이 x의 합과 평균을 구하도록 빈칸을 채우고 각 반복 뒤 total의 값을 쓰시오.
# 
# ```r
# x <- c(3,6,9)
# total <- 0
# for (value in x) {
#   total <- total + ___
# }
# avg <- total / length(x)
# avg
# ```
# Q56 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q57 · if는 한 번에 하나의 조건
# 
# 유형: R · 난이도: 적용 · 에러 찾기
# 
# 각 작업을 30분 이하이면 fast, 아니면 slow로 분류하려 한다. 아래 코드는 길이가 1보다 큰 조건 오류를 낸다. 제공한 반복문 틀을 사용해 고치고 출력하시오.
# 수정 틀: label <- character(length(x)); for(i in seq_along(x)) { if (조건) label[i] <- "fast" else label[i] <- "slow" }
# 
# ```r
# x <- c(20,40)
# if (x<=30) "fast" else "slow"
# ```
# Q57 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q58 · 입력을 바꾸면 계산도 다시
# 
# 유형: R · 난이도: 적용 · 에러 찾기
# 
# 부품 수를 4로 바꿨는데 printed가 새 예측값을 보여 주지 않는다. 실제 출력과 이유를 쓰고 필요한 한 줄을 추가하시오.
# 
# ```r
# parts <- 2
# predicted <- 5+3*parts
# parts <- 4
# print(predicted)
# ```
# Q58 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q59 · 함수의 입력과 반환값
# 
# 유형: R · 난이도: 적용 · 출력 예측
# 
# 아래 함수는 분 단위 숫자 벡터를 받아 초 단위 결과를 반환한다. 두 출력과 원자료 변경 여부를 쓰시오.
# 
# ```r
# to_seconds <- function(minutes) { minutes*60 }
# x <- c(1,2.5)
# print(to_seconds(x))
# print(x)
# ```
# Q59 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

# ## Q60 · 앱의 조건 변화와 같은 계산 읽기
# 
# 유형: R · 난이도: 통합 · 출력 예측
# 
# 웹 앱에서 기준을 바꾸는 상황을 다음 기본 R 함수로 표현했다. 두 호출의 선택 값·분모·출력을 쓰고, 기준 증가만으로 전체 자료의 값이 변한 것인지 설명하시오. 이 자료에는 NA가 없다.
# 
# ```r
# selected_mean <- function(x,limit) {
#  chosen <- x[x<=limit]
#  mean(chosen)
# }
# x <- c(40,50,60)
# print(selected_mean(x,50))
# print(selected_mean(x,60))
# ```
# Q60 TODO: 위 문제의 코드를 여기에 직접 완성하세요.
# 예상 출력 / 실제 출력 / 차이의 이유를 기록하세요.

my_summary <- review_summary(demo$minutes,scale=1)
print(my_summary)
