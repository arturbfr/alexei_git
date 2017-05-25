
library(foreign)
library(stringr)
library(readr)
library(magrittr)
library(SAScii)

## Supondo arquivos em caminho diferente do working directory
# Inserir o caminho da pasta que contém os arquivos
folder <- "C:\Users\Artur e Breno\Desktop\R-LaTeX\alexei2\PNADC"
if(grepl("\\", folder))

# Identifica o arquivo .zip de input
zip <- list.files(folder) %>%
  grep("input.*\\.zip", ., value = TRUE )

# Diz o caminho do arquivo
path <- paste0(folder, "/", zip)

# Identifica o arquivo a ser extraído
file <- unzip(path, list = TRUE)$Name %>%
  grep("Input.*2012.*txt", ., value = TRUE)

# Extrai o arquivo
unzip(path, file)

dict <- read_file(file, locale = locale(encoding = "Windows-1252")) %>% 
  strsplit("\r\n")
dict <- dict[[1]]
dictpos <- grep("^@", dict)
dict <- dict[dictpos] 
start <- dict %>% str_extract(pattern = "[1-9][0-9]*(?=")

file2 <- file %>% sub(".txt", ".sas",.)
test <- read.xport(file2)

load("pnadc 2012 01.rda")
head(x)

apply(x, 2, mean)
