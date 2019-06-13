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
if (length(args) != 2){
  stop("At least one argument must be supplied (input_file).xlsx, .csv or .txt", call.=FALSE)
}else{
  cat("barcode file : ", args[1], "\nsample_info file : ", args[2], "\n")
  cat("outfile name: barcode.txt")
  strparsing = function(x)
  {
    #x = sheet[2, 2]
    y = as.character(x);
    patterns = c("-",  "/", " ","+", "//", "#")
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
  
  ## start the file processing
  library(openxlsx)
  library(tools)
  
  #args = c("srbc_all.xlsx", "NGS_Samples_Philipp_20190514_R7846_R7604.xlsx")
  bcs = read.xlsx(args[1], sheet = 1, colNames = FALSE,  rowNames = FALSE)
  samples = read.xlsx(args[2], sheet = 1, colNames = TRUE,  rowNames = FALSE)
  #samples.names = sapply(colnames(samples), strparsing)
  samples = data.frame(samples$Sample.ID, samples$Adapter.sequence, stringsAsFactors = FALSE)
  colnames(samples) = c("sample", "barcode_name")
  samples$barcode_name = sapply(samples$barcode_name, strparsing)
  samples$barcode_name = sapply(samples$barcode_name, function(x) gsub("[.]", "",x))
  samples$barcode_name = sapply(samples$barcode_name, function(x) gsub("SRB", "sRBC",x))
  samples = samples[grep("sRBC", samples$barcode_name), ]
  
  bcs = data.frame(bcs, stringsAsFactors = FALSE)
  colnames(bcs) = c("barcode_name", "barcode")
  bcs$barcode_name = sapply(bcs$barcode_name, function(x) gsub("[-]", "",x))
  
  newff = data.frame(samples, barcode=bcs$barcode[match(samples$barcode_name, bcs$barcode_name)], stringsAsFactors = FALSE)
  
  colnames(newff) = c("sample", "barcode_name", "barcode")
  write.table(newff, file=paste0("barcodes.txt"),
               sep = "\t", quote = FALSE, col.names = TRUE, row.names = FALSE)
    
}
