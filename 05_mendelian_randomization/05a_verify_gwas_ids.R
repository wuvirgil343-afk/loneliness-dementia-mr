################################################################################
# 核实 MR 使用的 GWAS ID 真实元数据 (回应审稿人 R4 #10, #12)
################################################################################
suppressMessages({
  library(ieugwasr)
})

BASE <- "d:/kiroproject/原始数据/3. HRS  美国/HRS_美国/Analysis"
token <- trimws(readLines(file.path(BASE, ".opengwas_token"), warn = FALSE)[1])
Sys.setenv(OPENGWAS_JWT = token)

ids <- c("ukb-b-8476",       # 暴露: 声称 loneliness/isolation
         "ieu-b-5067",       # 结局: 声称 Bellenguez 2022 AD
         "ieu-b-102",        # 中介: 声称 MDD
         "ieu-b-35",         # 中介: 声称 CRP
         "ebi-a-GCST006250", # 反向: 声称 Intelligence
         "ukb-b-11307")      # 备用 loneliness

cat("========== OpenGWAS 元数据核实 ==========\n\n")

info <- gwasinfo(ids)

cols <- intersect(c("id","trait","year","author","consortium","population",
                    "sample_size","ncase","ncontrol","nsnp","sex","build","pmid"),
                  names(info))

for(i in seq_len(nrow(info))){
  cat("----------------------------------------------------\n")
  for(cc in cols){
    cat(sprintf("  %-14s: %s\n", cc, as.character(info[[cc]][i])))
  }
  cat("\n")
}

write.csv(info, file.path(BASE, "output", "MR", "GWAS_ID_verification.csv"),
          row.names = FALSE)
cat("已保存: output/MR/GWAS_ID_verification.csv\n")
