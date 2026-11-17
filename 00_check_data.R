library(readxl)

raw <- read_excel("data/dataset-uci.xlsx")
dim(raw)                       # rows and columns
names(raw)                     # variable names
table(raw$`Gallstone Status`)  # counts of 0 and 1
head(raw)
