library("readxl")
library("tidyquant")
library("tidyverse")
library("dplyr")
library("timetk")
library("broom")
library("glue")
library("Metrics")
library("caret") 
FFF <- read_excel("D:/Documents/Cours M2 MoSEF/Projets M2 MoSEF/Finance Base/Europe_3_Factors.xlsx")

#Cette table est issue du https://mba.tuck.dartmouth.edu/pages/faculty/ken.french/data_library.html .
#Celui-ci recense les diif�rents facteurs tant pour le mod�le � 3 qu'� 5 facteurs du continent Am�ricain � l'Europe.

# Formatage de la table

FFF$'...1'=NULL
FFF$`Mkt-RF`=gsub(",", '.', FFF$`Mkt-RF`, fixed = T)
FFF$`SMB`=gsub(",", '.', FFF$`SMB`, fixed = T)
FFF$`HML`=gsub(",", '.', FFF$`HML`, fixed = T)
FFF$`RF`=gsub(",", '.', FFF$`RF`, fixed = T)
FFF$SMB= as.numeric(FFF$SMB)
FFF$HML= as.numeric(FFF$HML)
FFF$RF= as.numeric(FFF$RF)
FFF$`Mkt-RF`= as.numeric(FFF$`Mkt-RF`)
FFF$date=parse_date_time(FFF$date, "%Y%m")
FFF$date = lubridate::rollback(FFF$date)

FFF$`Mkt-RF`= FFF$`Mkt-RF`/100
FFF$SMB= FFF$SMB/100
FFF$HML= FFF$HML/100
FFF$RF= FFF$RF/100

# Calcul des rendements

FFF$Shift <- lag(FFF$Prix ,1,na.pad = TRUE)
FFF$Rendements = (FFF$Prix - FFF$Shift) /FFF$Shift
FFF$R_excess = round(FFF$Rendements - FFF$RF, 4)

# Mod�lisation

reg=lm(R_excess ~ `Mkt-RF` + SMB + HML, 
       data = FFF)
summary(reg)
AIC(reg)
BIC(reg)

# Estimation des rendements 

FFF$pred=7.259e-05 + 6.807e-01* FFF$`Mkt-RF` + -2.529e-02 * FFF$SMB + -1.113e-01*FFF$HML

# Representation graphique

plot(FFF$date, FFF$R_excess,main="Mod�lisation Fama & French 3 Factors", ylab = "R-rf", xlab = "Dates")
lines(FFF$date , FFF$pred, col = "red")
lines(FFF$date , FFF$R_excess, col = "blue")
legend("topleft",
       c("R_excess","pred"),
       fill=c("blue","red"))

# Import Fama French 5 factors

FFF <- read_excel("D:/Documents/Cours M2 MoSEF/Projets M2 MoSEF/Finance Base/Europe_5_Factors.xlsx")

FFF$'...1'=NULL
FFF$`Mkt-RF`=gsub(",", '.', FFF$`Mkt-RF`, fixed = T)
FFF$`SMB`=gsub(",", '.', FFF$`SMB`, fixed = T)
FFF$`HML`=gsub(",", '.', FFF$`HML`, fixed = T)
FFF$`RF`=gsub(",", '.', FFF$`RF`, fixed = T)
FFF$SMB= as.numeric(FFF$SMB)
FFF$HML= as.numeric(FFF$HML)
FFF$RF= as.numeric(FFF$RF)
FFF$RMW= as.numeric(FFF$RMW)
FFF$CMA= as.numeric(FFF$CMA)
FFF$`Mkt-RF`= as.numeric(FFF$`Mkt-RF`)
FFF$date=parse_date_time(FFF$date, "%Y%m")
FFF$date = lubridate::rollback(FFF$date)
FFF$`Mkt-RF`= FFF$`Mkt-RF`/100
FFF$SMB= FFF$SMB/100
FFF$HML= FFF$HML/100
FFF$RF= FFF$RF/100
FFF$RMW= FFF$RMW/100
FFF$CMA= FFF$CMA/100

FFF$Shift <- lag(FFF$Prix ,1,na.pad = TRUE)
FFF$Rendements = (FFF$Prix - FFF$Shift) /FFF$Shift
FFF$R_excess = round(FFF$Rendements - FFF$RF, 4)

# Mod�lisation Farma&French 5 facteurs

reg=lm(R_excess ~ `Mkt-RF` + SMB + HML + RMW + CMA, 
       data = FFF)
summary(reg)
AIC(reg)
BIC(reg)

FFF$pred=0.0007383 + 0.6439174* FFF$`Mkt-RF` + -0.0624098 * FFF$SMB + -0.0099926 * FFF$HML + -0.0225132 *FFF$RMW + -0.2334534 * FFF$CMA

# Repr�sentatioon graphique

plot(FFF$date, FFF$R_excess,main="Mod�lisation Fama & French 5 Factors", ylab = "R-rf", xlab = "Dates")
lines(FFF$date , FFF$pred, col = "red")
lines(FFF$date , FFF$R_excess, col = "blue")
legend("topleft",
       c("R_excess","pred"),
       fill=c("blue","red"))
