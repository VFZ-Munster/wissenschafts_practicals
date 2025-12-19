library(haven)
library(data.table)
# Read data

data <- read_sav("nhanes30.sav")
data <- as.data.table(data)
data[, smk_factor := factor(smk)]


data[, smk_factor_new := factor(fcase(smk == 1, 0, smk == 2, 1, smk == 3, 2, default = NA_real_))]
data[, sexf := factor(sex)]
data[, sex_new := fcase(sex == 1, 0, sex == 2, 1, default = NA_real_)]
summary(data[,.(cal_mean, smk)])
data[, .N, by = sexf]

data[, interaction := (sex_new*alcg)]
glm(cal_mean ~ sex_new + alcg + interaction, data = data)|> coef()

(Intercept)         sex        alcg interaction 
0.514592718 0.336376529 0.001607073 0.002323928 

summary(data[['alcg']])
hist(data[['alcg']])
