##################################################
## Project: General purpose 
## Script purpose: convert excel sheet (e.g. .csv, .xlsx) to a text file 
## Usage example : Rscript convertExcel2txt.R example.xlxs 
## Author: Jingkui Wang (jingkui.wang@imp.ac.at)
## Date of creation: Mon Dec  4 10:26:20 2017
##################################################
args = commandArgs(trailingOnly=TRUE)

# args = "R5750_Sample_IDs.xlsx"
# test if there is at least one argument: if not, return an error
if (length(args)==0){
  stop("At least one argument must be supplied (input_file).xlsx, .csv or .txt", call.=FALSE)
}else{
  strparsing = function(x)
  {
    #x = sheet[2, 2]
    y = as.character(x);
    patterns = c("-",  "/", " ","+", "//")
    strs = unlist(strsplit(y, ""))
    mm = match(strs, patterns)
    strs[which(!is.na(mm)==TRUE)] = "."

    jj2remove = c()
    for(n in 1:length(strs) )
    {
      if(n == 1 | n == length(strs))
      {
         if(strs[n] == ".") jj2remove = c(jj2remove, n);
         
      }else{
        if(strs[n-1] == "." & strs[n] == ".") jj2remove = c(jj2remove, n);
      }
            
    }

    if(length(jj2remove)>0)
      strs = strs[-jj2remove];
    
    strs = paste0(strs, collapse = "")
    #strs = gsub("....", ".", strs);
    #strs = gsub("...", ".", strs);
    #strs = gsub("..", ".", strs);
    return(strs)
  }
  
  library(openxlsx)
  library(tools)
  for(n in 1:length(args))
  {
    filename = file_path_sans_ext(args[n])
    extension = file_ext(args[n])
    if(extension == "xlsx"){
      sheet = read.xlsx(args[n], sheet = 1, colNames = TRUE,  rowNames = FALSE)
    }else{
      if(extension == "csv"){
        sheet = read.csv(args[n], header = TRUE)
      }else{
        if(extension == "txt"){
          sheet = read.delim(args[n], header = TRUE, sep = '\t')
        }else{
          stop("Input file must be .csv or .xlsx or .txt", call. = FALSE)
        }
      }
    }
    
    if(ncol(sheet)>2){

      newff = data.frame(sheet[ ,1], apply(sheet[, -1], 1, function(x) paste0(x, collapse = "_")))
      newff = data.frame(newff[ ,1], sapply(newff[, 2], strparsing))

    }else{
      if(ncol(sheet)==2){

        newff = data.frame(sheet[, 1], sapply(sheet[, -1], strparsing))
      }else{
        cat("ERROR: there is ONLY one column....")
      }
      
    }
    
    colnames(newff) = c("sampleID", "fileName")
    write.table(newff, file=paste0(filename, "_parsed.txt"),
                sep = "\t", quote = FALSE, col.names = TRUE, row.names = FALSE)
    #print(sheet[1,])
    
    #if(extension == "txt"){
    #  sheet = read.xlsx(args[n], sheet = 1, colNames = TRUE,  rowNames = FALSE)
    #}
    
    #if (length(args)==1){
    # default output file
    #args[2] = "out.txt"
    #}
    
  }
}