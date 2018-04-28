

# Qualtrics files -------------------------------------------------------------------------------------------------


library(xlsx)
library(memisc)
library(raster)
library(magrittr)
library(dplyr)
library(tidyr)
library(countrycode)
filter <- dplyr::filter

setwd("~/Dropbox/honesty across societies")
dfr1 <- read.xlsx2("HAS.xlsx", 1, stringsAsFactors=FALSE)
dfr2 <- read.csv("HAS second wave updated.csv", stringsAsFactors = FALSE, skip = 1, colClasses = "character")

mygrep <- function(x) grep(x, dfr2[,65], ignore.case = TRUE)
dfr2$nationality <- ""
dfr2$nationality[mygrep("rgentin")] <- "AR"
dfr2$nationality[mygrep("india|indai")] <- "IN"
dfr2$nationality[mygrep("dansk|danish|danmark|denmark|DK")] <- "DK"
dfr2$nationality[mygrep("welsh|british|english|scottish|UK|englsh")] <- "GB"
dfr2$nationality[mygrep("대한민국|한국|korea")] <- "KR"
dfr2$nationality[mygrep("por")] <- "PT"
dfr2$nationality[mygrep("south afri|white|Caucasi")] <- "ZA" # what about Indian?

dfr2 <- dfr2[,-25]
names(dfr2)[36:41] <- paste0("Quiz.", 1:6, ".correct")
names(dfr2)[57:59] %<>% sub("\\.$", "", .)

dfr <- as.data.frame(bind_rows(dfr1, dfr2))
dfr$wave2 <- dfr$project == "Qual12-1114CountriesUKUS"

names(dfr)[25] <- "consent"
names(dfr)[26:28] <- c("gender", "age", "residence")
names(dfr)[30:35] <- paste0("quiz", 1:6, c("elise", "gaga", "nirvana", "debussy", "trumpet", "jackson"))
names(dfr)[40] <- "heads"
names(dfr)[41:55] <- sub(".*\\.{6}", "", names(dfr)[41:55])
names(dfr)[56] <- "guess"
names(dfr)[58] <- "nation"
names(dfr)[59] <- "religattend"
names(dfr)[90:103] <- c("cguess_trans1", "nationality", paste("quiz_trans", 1:6, sep=""), 
  paste("quiz_correct", 1:6, sep=""))
names(dfr)[114] <- "trust"
names(dfr)[115:118] %<>% sub(".*\\.\\.", "", .)
names(dfr)[109:114] <- c("marital", "children", "income_raw", "religimport", "educage", "trust")

for (i in c(41:55, 115:118)) dfr[,i] <- as.numeric(dfr[,i])
dfr$guess <- as.numeric(dfr$guess)
dfr$hilow <- as.numeric(dfr$hilow)
dfr[,41:55][dfr[,41:55]==5] <- NA # "don't know" 
dfr$quiz_correct3[ dfr$quiz_correct3 == "#VALUE!" ] <- "0" # fix mistake
dfr[dfr$ResponseID %in%  c("R_8nSMpMLq9jNunFb", "R_0jsug08aYcTaLVH", "R_2gjnWImjsPFoKfb", "R_5sUCkoVy2OOPSE5",
  "R_6sPAtXfuTVhOGep", "R_0dlidk3wVUwIb0V", "R_bklULiDAMx7283H", "R_1BURu0GIwrjPsrj", "R_9Y4ZOYXjK40fCjb",
  "R_6VRJfDQbcyD14LH", "R_0eUu8Ui1w6AOcjb"), paste0("quiz_correct", 1:6)] <- 
  c(
    0,0,0,0,0,0,
    1,1,1,1,1,1,
    0,1,1,1,0,1,
    0,0,0,0,0,0,
    0,1,0,0,0,0,
    0,0,0,0,0,0,
    1,1,1,1,1,1,
    1,1,1,1,1,1,
    0,0,0,0,0,0,
    1,1,1,1,1,1,
    0,0,0,0,0,0
  ) # another oversight
  
# 1= always justified, 2=sometimes, 3=rarely, 4=never 
dfr$integ <- rowMeans(dfr[,41:55], na.rm=TRUE) * 15
dfr$integ[dfr$integ==0] <- NA # no non-5 answers
dfr$integ[apply(dfr[,41:55], 1, function(x) sum(is.na(x))) > 5] <- NA # too few to be accurate
dfr$integ.straightline <- apply(dfr[,41:55], 1, function(x) min(x)==max(x))
dfr$marital <- recode(dfr$marital, "Single" <- 1, "Married" <- 2, "Sep." <- 3, "Div." <- 4, "Wid." <- 5)
dfr$children <- recode(dfr$children, "0" <- 1, "1" <- 2, "2" <- 3, "3" <- 4, "4+" <- 5)
dfr$religimport <- 5 - as.numeric(dfr$religimport)
dfr$educage <- recode(dfr$educage, "18" <- 1, "U16" <- 2, "16" <- 3, "17" <- 4, "19" <- 5, "20" <- 6, "21+" <- 7, 
  "in_educ" <- 8)
dfr[, 115:118] <- 2 - dfr[, 115:118]
dfr$behav <- rowSums(dfr[, 115:118]) # bad behaviours out of 4.
dfr$cguess_trans[dfr$cguess %in% c("Brazil", "Βραζιλία", "Brasil", "Brésil",
  "Brezilya", "Бразилия", "ブラジル")] <- "BR"
dfr$cguess_trans[dfr$cguess %in% c("Suíça", "Suisse", "Switzerland", "İsviçre", 
  "Ελβετία", "Швейцария", "スイス")] <- "CH"
dfr$cguess_trans[dfr$cguess %in% c("Japão", "Japon", "Japan", "Japonya", "Япония", 
  "Ιαπωνία", "日本")] <- "JP"
dfr$cguess_trans[dfr$cguess %in% c("Rússia", "Russia", "Ρωσία", "Russie", "Россия", 
  "ロシア")] <- "RU"
dfr$cguess_trans[dfr$cguess %in% c("China", "Китай", "Chine", "Κίνα", "Çin", 
  "中国")] <- "CN"
dfr$cguess_trans[dfr$cguess %in% c("the United States", "οι Ηνωμένες Πολιτείες",
  "Estados Unidos", "Соединенные Штаты", "Etats-Unis", 
  "Birleşik Devletler", "米国")] <- "US"
dfr$cguess_trans[dfr$cguess %in% c("Turkey", "Turquia", "Τουρκία", "Türkiye",  
  "Turquie", "Турция", "トルコ", "土耳其")] <- "TR"
dfr$cguess_trans[dfr$cguess %in% c("Grécia", "Greece", "Греция", "Grèce", 
  "Ελλάδα", "Yunanistan", "ギリシ", "ギリシャ")] <- "GR"
dfr$cguess_trans[dfr$cguess %in% c("Argentina", "아르헨티나")] <- "AR"
dfr$cguess_trans[dfr$cguess %in% c("África Do Sul", "South Africa", "sydafrika", "Sudáfrica", "남아프리카")] <- "ZA"
dfr$cguess_trans[dfr$cguess %in% c("Denmark", "Danmark", "Dinamarca", "덴마크")] <- "DK"
dfr$cguess_trans[dfr$cguess %in% c("Forenede Kongerige Storbritannien og Nordirland", 
  "Reino Unido da Grã-Bretanha e Irlanda do Norte", "Reino Unido de Gran Bretaña e Irlanda del Norte",
  "United Kingdom of Great Britain and Northern Ireland", "영국과 북 아일랜드의 영국")] <- "GB"
dfr$cguess_trans[dfr$cguess %in% c("India", "Índia", "Indien", "인도")] <- "IN"
dfr$cguess_trans[dfr$cguess %in% c("República da Coreia", "Republikken Korea", "Republic of Korea", 
  "República de Corea", "대한민국")] <- "KR"
dfr$cguess_trans[dfr$cguess %in% c("Portugal", "포르투갈")] <- "PT"

dfr$quizfirst <- apply(dfr[,seq(61,75,2)], 1, function (x) any(grepl("^Quiz", x)))

dfr$residence <- as.numeric(dfr$residence)
dfr$residence <- as.character(recode(dfr$residence, "RU" <- 142, "CH" <- 167, "TR" <- 177, 
  "US" <- 185, "BR" <- 24, "CN" <- 36, "GR" <- 67, "JP" <- 86, "AR" <- 7, "DK" <- 48, "IN" <- 78, "PT" <- 137, 
  "KR" <- 139, "ZA" <- 160, "GB" <- 183, otherwise = "copy"))

dfr$cguess_trans1 <- trimws(dfr$cguess_trans1)
dfr$cguess_trans1 <- recode(dfr$cguess_trans1, "BR" <- c("Brasil", "Brazil"), 
  "CN" <- "China", "GR" <- "Greece", "JP" <- c("Japan", "Japna", "Japonya"),
  "RU" <- "Russia", "CH" <- c("Swittzerland", "Switzerland"), 
  "TR" <- "Turkey", "US" <- c("United state", "United State", 
    "United States", "UnitedStates", "Unites States"))

dfr$nationality2 <- recode(dfr$nationality, "BR" <- "Brazilian", "CH" <- "Switzerland", "CN" <- "China", 
  "GR" <- "Greece", "JP" <- "Japan", "RU" <- "Russia", "TR" <- "Turkey", "US" <- "American", otherwise="copy")
# workaround bug:
dfr$nationality[ ! is.na(dfr$nationality2)] <- as.character(dfr$nationality2[ ! is.na(dfr$nationality2)])

# "resident nationals"
dfr$resnat <- dfr$residence
dfr$resnat[dfr$residence != dfr$nationality] <- NA

dfr$quizperf <- rowSums(dfr[,98:103]=="1")
dfr$quizp.hard <- rowSums(dfr[, c(99,101, 103)]=="1")
dfr$quizp.easy <- rowSums(dfr[, c(98, 100, 102)]=="1")

worldpop <- raster("world pop density/glds15ag.bil")
dfr$popdens <- raster::extract(worldpop, sapply(dfr[,88:87], as.numeric))

# indiv cases
dfr$income_raw %<>% sub("900 에서 1100만원", "9000000", .)
dfr$income_raw %<>% sub("2-5 LAKHS", "", .)
dfr$income_raw %<>% sub("OOO","000", .) 

dfr$income_num <- gsub("[^0-9\\.,$]", "", dfr$income_raw)
dfr$income_num <- gsub("(\\.|,)(\\d\\d\\d)", '\\2', dfr$income_num)
dfr$income_num[dfr$resnat %in% c("US", "UK", "IN", "CN", "JP", "KR")] %<>% gsub("\\..*", "", .)
dfr$income_num[! dfr$resnat %in% c("US", "UK", "IN", "CN", "JP", "KR")] %<>% gsub(",.*", "", .)
dfr$income_num[grepl("만원", dfr$income_raw)] %<>% {as.numeric(.) * 10000}
multips <- c(AR = 0.107, IN = 0.0151, GB = 1.57, KR =  	0.000839, DK = 0.154 , PT = 1.15, ZA = 0.0761) # 25 Aug 2015, xe.com, rates into $
multips <- multips[dfr$resnat]
dfr$income_num[!grepl("\\$", dfr$income_num)] %<>% as.numeric %>% multiply_by(multips[!grepl("\\$", dfr$income_num)]) 
dfr$income_num[grepl("\\$", dfr$income_num)] %<>% sub("\\$", "", .) 
dfr$income_num %<>% as.numeric
dfr$income_cens <- ave(dfr$income_num, dfr$resnat, FUN = function (x) ifelse(x > quantile(x,.2, na.rm = T) & x < quantile(x,.9, na.rm=T), x, NA)) 

dfr.orig <- dfr
dfr <- dfr[dfr$gc==1,]
dfr <- dfr[order(dfr$residence),]


# ztree comparison files ------------------------------------------------------------------------------------------

source("zTree.R")
compar <- list.files(
  c("~/Dropbox/Coercive Capacity and Anonymity/Treatments/PublicGoodsGame/Essex 28 Oct 2014/",
    "~/Dropbox/Coercive Capacity and Anonymity/Treatments/PublicGoodsGame/Essex 31 Oct 2014/", 
    "~/Dropbox/Coercive Capacity and Anonymity/Treatments/PublicGoodsGame/Essex 7 Nov 2014/"), 
  "*.sbj", full.names=TRUE)
compar <- zTreeSbj(compar)
compar <- compar[,grep("quiz", names(compar))]
compar$quiz1correct <- TRUE
compar$quiz1correct[! grepl("eethoven", compar$quiz1elise, ignore.case=TRUE)] <- FALSE
compar$quiz2correct <- TRUE
compar$quiz2correct[! grepl("stefa|stepha|german|joan|angeli", compar$quiz2gaga, ignore.case=TRUE)] <- FALSE
compar$quiz3correct <- TRUE
compar$quiz3correct[! grepl("gro|ghr|dave", compar$quiz3nirvana, ignore.case=TRUE)] <- FALSE
compar$quiz4correct <- TRUE
compar$quiz4correct[trimws(compar$quiz4debussy) != "1862"] <- FALSE
compar$quiz5correct <- TRUE
compar$quiz5correct[! grepl("(^3$)|three", compar$quiz5trumpet, ignore.case=TRUE)] <- FALSE
compar$quiz6correct <- TRUE
compar$quiz6correct[! grepl("gary|indiana", compar$quiz6jackson, ignore.case=TRUE)] <- FALSE
compar$score <- rowSums(compar[grepl("correct", colnames(compar))])

# View(compar) # manual check


# GDP preload -----------------------------------------------------------------------------------------------------


ctries <- sort(unique(dfr$resnat))
qog <- read.csv("qog_bas_ts_jan15.csv", stringsAsFactors = FALSE)
qog$cc2 <- countrycode(qog$ccodecow, "cown", "iso2c")
qog <- qog[qog$cc2 %in% ctries, c("cc2", "year", "gle_rgdpc", "ti_cpi")]
qog <- qog[order(qog$cc2),]


# Weights ---------------------------------------------------------------------------------------------------------

unp <- read.csv("UN population data.csv", stringsAsFactors = FALSE)
unp <- unp[1:39085,]
unp %<>% filter(grepl("-", unp$Age)) %>% dplyr::rename(country = Country.or.Area) %>% group_by(country) %>% 
  filter(Year == max(Year))
"2='18-24'; 3='25-34'; 4='35-44'; 5='54-54'; 6='55+'; else='NA'"
unp %<>% ungroup %>% group_by(country, Sex) %>% summarize(
  age1824 = round(sum(Value[Age=="20 - 24"]*7/5)), 
  age2534 = sum(Value[Age %in% c("25 - 29", "30 - 34")]),
  age3544 = sum(Value[Age %in% c("35 - 39", "40 - 44")]),
  age4554 = sum(Value[Age %in% c("45 - 49", "50 - 54")]),
  age55plus = sum(Value[Age %in% c("55 - 59", "60 - 64", "65 - 69", "70 - 74", "75 - 79", "80 - 84", "85 - 89",
    "90 - 94", "95 - 99")])
  ) %>% gather(age, pop, -c(country,Sex))

unp$age <- car::recode(unp$age, "'age1824' = '2'; 'age2534' = '3'; 'age3544' = '4'; 'age4554' = '5'; 'age55plus' = '6'") 
unp$resnat <- countrycode(unp$country, 'country.name', 'iso2c')
unp$gender <- as.character(recode(unp$Sex, "'Male' = 1; 'Female' = 2"))
totpops <- tapply(unp$pop, unp$resnat, sum)
unp$popweight <- unp$pop/totpops[unp$resnat]
dfr %<>% left_join(unp[,c("resnat", "age", "gender", "popweight")]) 
# Save ------------------------------------------------------------------------------------------------------------

save(dfr, dfr.orig, qog, compar, file="honesty.RData")

