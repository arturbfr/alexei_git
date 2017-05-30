## LEITURA DE LABELS
# Versão de teste. Estado atual:
# -- Cria lista de labels da parte 1 (2012Q1 a 2015Q3)

## PACOTES
# Leitura de arquivos de Excel
library(rio)
# Pacote disponibiliza o operador "pipe" (%>%)
library(magrittr)
# Permite leitura de arquivos .sas
library(SAScii)

## Controle --------------------------------------------------------------------
# Variáveis desejadas
# var <- c("ANO", "UF", "V1014", "V1008", "V1027")
var <- "ALL"
## -----------------------------------------------------------------------------

# Identifica o arquivo .zip de input
zip <- list.files() %>%
  grep("Dicionario\\_e\\_input.*\\.zip", ., value = TRUE )

# Identifica o arquivo a ser extraído
file <- unzip(zip, list = TRUE)$Name %>%
  grep("Input.*1Tri\\_2012.*\\.sas", ., value = TRUE)

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

# Extrai o arquivo de label
labels_date <- "1Tri_2012"
labels_file <- unzip(zip, list = TRUE)$Name %>% 
  grep(paste0(labels_date, ".*\\.xls"), ., value = TRUE)
unzip(zip, labels_file)

# Importa arquivo
labels_raw <- import(labels_file)

# Tratamento do arquivo
labels_raw <- as.data.frame(lapply(labels_raw, function(x) {
  gsub('.000000', '', x) } ))

if(var == "ALL"){
  var <- dict$VARNAME
}

# Criando list com as posições das variáveis no arquivo de labels
labels_pos <- labels_raw[,3] %>% trimws %>%  as.character %>% 
  toupper %>% match(var, .)
labels_names <- labels_raw[labels_pos, 5] %>% as.character
labels_names[is.na(labels_names)] <- "---"
# labels_title <- paste(var, labels_names, sep = ": ")

# Criando a lista de labels
labels <- list()

for(k in 1:length(labels_pos)){
  
  i <- labels_pos[k]
  j <- i
  repeat{
    if(!is.na(labels_raw[j+1,2]) | (j+1 > nrow(labels_raw))){break}
    j <- j + 1
  }
  labels_title <- var[k]
  labels[[labels_title]] <- paste(as.vector(labels_raw[i:j,6]),
                            as.vector(labels_raw[i:j,7]), sep = ': ') 
  
}

pos_err1 <- vector()
pos_err2 <- vector()
inc <- 1
for(k in 1:length(labels)){
  
  for(l in 1:length(labels[[k]])){
    
    cond <- labels[[k]][l] == "NA: NA"
    
    if(cond){
      
      pos_err1[inc] <- k 
      pos_err2[inc] <- l
      inc <- inc + 1
      
    }
  }
}

for(k in length(pos_err1):1) {
  
  if(length(labels[[pos_err1[k]]]) == 1){
    labels[[pos_err1[k]]] <- "---"
  } else {
    labels[[pos_err1[k]]] <- labels[[pos_err1[k]]][-pos_err2[k]]
  }
  
}

for(k in 1:length(labels)){
  
  for(l in 1:length(labels[[k]])){
    
    if(grepl("\"", labels[[k]][l])) {
      
      labels[[k]][l] <- gsub("\"", "'", labels[[k]][l])
      
    }
  }
}


