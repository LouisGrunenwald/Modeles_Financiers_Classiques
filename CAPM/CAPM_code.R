library("readxl")
library("dplyr")
library("quantmod")
library("purrr")
library("PerformanceAnalytics")
library("timetk")
library("tidyr")
library("tidyverse")
library("tidyquant")
library("broom.mixed")
setwd("D:/Documents/Cours M2 MoSEF/Projets M2 MoSEF/Finance Base/")

table <-read_excel("Fidelity Funds - European Growth Fund.xlsx", skip = 11)
table <- table[3:227, ]
table$Shift <- lag(table$PX_LAST ,1,na.pad = TRUE)
table$Rendement = (table$PX_LAST - table$Shift) /table$Shift
table$'Shift'=NULL
table$'PX_LAST'=NULL
table$Rf= as.numeric(table$Rf)

#Extraction de l'ETF sur Yahoo finance
spy_monthly_xts <- 
  getSymbols("EXW1.DE", 
             src = 'yahoo', 
             from = "2000-12-01", 
             to = "2019-09-30",
             auto.assign = TRUE, 
             warnings = FALSE) %>% 
  map(~Ad(get(.))) %>% 
  reduce(merge) %>%
  `colnames<-`("EXW1.DE") %>% 
  to.monthly(indexAt = "last", OHLC = FALSE)

market_returns_xts <-
  Return.calculate(spy_monthly_xts, method = "log") %>% 
  na.omit()

market_returns_tidy <-
  market_returns_xts %>% 
  tk_tbl(preserve_index = TRUE, rename_index = "date") %>% 
  na.omit() %>%
  select(date, returns = EXW1.DE)

#table$Dates <- as.Date(table$Dates)
#table <- table[-c(225,219,108),]
table <- table[-c(225,1),]

a <- table %>% 
  mutate(market_returns = market_returns_tidy$returns) 
a <- a[-1,]
a$Rf <- a$Rf/100

#Calcul du B�ta du CAPM
a$cov <- cov(a$Rendement, a$market_returns)
a$beta <- a$cov/ var(a$market_returns)
mean(a$beta) # B�ta du CAPM calcul� � la mains

# ind�pendamment, avec une r�gression classique, on retrouve le B�ta du march� par la mod�lisation
beta_dplyr_byhand <-  a %>% 
  do(model = lm(Rendement ~ market_returns, data = a)) %>% 
  tidy(model) %>% 
  mutate(term = c("alpha", "beta"))

beta_dplyr_byhand

a$pred <- 0.004174 + 0.392719 * a$market_returns #On retrouve bien le beta (=0.39)

########  Mod�lisation par le CAPM   #########

a$`Rm-Rf` <- a$market_returns - a$Rf


#Estimation des rendements par le MEDAF
# Pour cela, on r�utilise le b�ta d�termin� prec�dement: calcul� � la mains ou par mod�lisation
a$pr�vision_MEDAF <- a$Rf + a$beta * a$`Rm-Rf`

#Qualite de l'estimation
a$diff <- a$Rendement - a$pred
mean(a$diff)
StdDev(a$diff)

#Repr�sentation du mod�le 
plot(a$Dates, a$Rendement, ylab = "Rendement", xlab = "Dates")
lines(a$Dates , a$pr�vision_MEDAF, col = "red")
lines(a$Dates , a$Rendement, col = "blue")
legend("topleft",
       c("Rendement","pred"),
       fill=c("blue","red"))


#Calcul R�
sum((a$pr�vision_MEDAF-mean(a$pr�vision_MEDAF))^2)/sum((a$Rendement-mean(a$Rendement))^2)
model=lm(Rendement ~ market_returns, data = a)
summary(model)  # verif on retrouve bien le m�me R� que celui calcul�


#Calcul ratio de Sharp
Sharp=(mean(a$Rendement)-mean(a$Rf))/StdDev(a$Rendement)
Sharp


#Ce ratio est donc la pente de la CML. Comme propos� par Sharp ce ratio peut �tre consid�r� comme une mesure de performance on peut prendre le num�rateur comme la prime de risque (positive ou n�gative) et le d�nominateur comme un indicateur de risque. Autrement dit, c'est le rapport entre l'exc�s de rendement moyen du portefeuille et la mesure totale du risque du portefeuille.
#Pour exemplifier, le g�rant d'un fonds peut regarder si son exc�s de rendement moyen est suffisant pour compenser un risque plus �lev� que celui du portefeuille de march�. Si un portefeuille est bien diversifi�, son ratio de Sharp est proche de celui du portefeuille de march�.
#Plus le ratio de Sharp est �lev� mieux c'est.