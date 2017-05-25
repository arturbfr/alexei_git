
# library(foreign)
# library(stringr)
library(readr)
library(magrittr)
library(SAScii)

## Versão de teste. Estado atual:
# -- Lê dicionário 1tri2012 até 3tri2015
# -- Lê arquivo PNADC_012012
# -- Lê arquivo PNADC_022012
# -- Lê arquivo PNADC_032012
# -- Lê arquivo PNADC_042012

## Supondo arquivos no working directory

## Controle --------------------------------------------------------------------
# Variáveis desejadas
# var <- c("ANO", "UF", "V1014", "V1008", "V1027")
var <- "ALL"
# Número de observações para ler (TESTE)
n_max <- 100
# Nome do arquivo de microdados
name <- "PNADC_012012.txt"
## -----------------------------------------------------------------------------


# Identifica o arquivo .zip de input
zip <- list.files() %>%
  grep("Dicionario\\_e\\_input.*\\.zip", ., value = TRUE )

# Identifica o arquivo a ser extraído
file <- unzip(zip, list = TRUE)$Name %>%
  grep("Input.*1Tri\\_2012.*\\.sas", ., value = TRUE)

# Extrai o arquivo
# unzip(zip, file)
unzip(zip)

# Lendo arquivo no formato .sas
dict_temp <- parse.SAScii(file)

# Transformando num dicionário
start_pos <- dict_temp[-nrow(dict_temp), 2] %>% cumsum %>% add(1) %>% c(1, .)
end_pos <- start_pos + dict_temp[, 2] - 1
dict_temp <- data.frame(VARNAME = dict_temp[, 1],
                   START = start_pos,
                   END = end_pos,
                   CHAR = dict_temp[, 3],
                   DIVISOR = dict_temp[, 4],
                   stringsAsFactors = FALSE
                   )

# Constrói dicionário apenas com variáveis escolhidas
if(var != "ALL"){
  
  # Ordena o vetor de nome da variáveis
  start_order <- dict_temp[match(var, dict_temp$VARNAME), 2]
  var <- var[order(start_order)]
  
  # Dicionário das variáveis escolhidas
  dict <- dict_temp[match(var, dict_temp[,1]),]
  
} else {
  
  # Dicionário de todas as variáveis
  dict <- dict_temp
  
}

# Lendo arquivo
type <- paste(rep('d', nrow(dict)), collapse = '')
col_pos <- fwf_positions(dict$START, dict$END, col_names = dict$VARNAME)

dados <- read_fwf(name, col_pos, col_types = type, n_max = n_max)








