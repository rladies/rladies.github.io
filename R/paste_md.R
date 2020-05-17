library(rvest)
library(stringr)

pasteReadme <- function(fileName){
  
  breakFun <- function(x){
    #function to replace empty lines with newline. 
    if(nchar(x) == 0){
      return("\n\n") #double newline to give same space as in the .md-file
    } else if(substr(x, 1, 1) == "*") {
      return(paste("\n", x)) #lists
    } else {
      return(x)
    }
  }
  
  storeLines <- readLines(fileName)
  
  cat(paste0(lapply(storeLines, FUN=function(x) breakFun(x)), collapse=""))
  
}