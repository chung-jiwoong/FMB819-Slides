# Load required libraries
library(httr)
library(xml2)
library(magrittr)

# 1. 고유번호 파일 요청 URL
codezip_url <- paste0('https://opendart.fss.or.kr/api/corpCode.xml?crtfc_key=', dart_api_key)

# 2. 데이터 다운로드
response <- GET(codezip_url)

# 3. 데이터 수령 -> 저장 -> 압축 해제 -> 내용 판독
tf <- tempfile(fileext = '.zip')
writeBin(content(response, as = "raw"), tf)

# 압축 파일 내의 파일 목록 확인
nm <- unzip(tf, list = TRUE)

# 임시 폴더(tempdir)에 압축 해제하여 작업 공간 오염 방지
extracted_file <- unzip(tf, files = nm$Name[1], exdir = tempdir())

# XML 읽기
code_data <- read_xml(extracted_file)

# 4. 데이터프레임 변환
corp_code <- code_data %>% xml_find_all('//corp_code') %>% xml_text()
corp_name <- code_data %>% xml_find_all('//corp_name') %>% xml_text()
stock_code <- code_data %>% xml_find_all('//stock_code') %>% xml_text()

corp_list <- data.frame(
  code = corp_code,
  name = corp_name,
  stock = stock_code,
  stringsAsFactors = FALSE
)

# 상장사(stock_code가 6자리인 기업)만 필터링 
# (공백 문자가 들어올 수 있으므로 trimws() 적용 권장)
corp_list_listed <- subset(corp_list, nchar(trimws(stock)) == 6)

# 5. 메모리 정리 (임시 파일 삭제)
unlink(tf)
unlink(extracted_file)

head(corp_list_listed)
