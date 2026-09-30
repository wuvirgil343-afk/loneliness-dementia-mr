################################################################################
# 在 OpenGWAS 中查找正确的 Bellenguez 2022 AD GWAS
# 目标: 找到 ~111,326 cases / 大样本、临床诊断+proxy 的 AD GWAS
################################################################################
suppressMessages({
  library(ieugwasr)
  library(dplyr)
})

BASE <- "d:/kiroproject/原始数据/3. HRS  美国/HRS_美国/Analysis"
token <- trimws(readLines(file.path(BASE, ".opengwas_token"), warn = FALSE)[1])
Sys.setenv(OPENGWAS_JWT = token)

# 拉取全部 GWAS 信息，筛选 Alzheimer 相关
cat("查询所有 Alzheimer 相关 GWAS...\n")

# 方法1: 直接候选ID逐个查（Bellenguez常见的几个ID）
candidates <- c("ieu-b-2", "ieu-b-5067", "ebi-a-GCST90027158",
                "ebi-a-GCST002245", "ieu-a-297", "ieu-a-298",
                "ieu-a-299", "ieu-b-8036", "ebi-a-GCST90012877")

cat("\n===== 候选 AD GWAS 元数据 =====\n")
for(id in candidates){
  info <- tryCatch(gwasinfo(id), error=function(e) NULL)
  if(!is.null(info) && nrow(info) > 0){
    cat(sprintf("\n[%s]\n", id))
    cat(sprintf("  trait   : %s\n", info$trait[1]))
    cat(sprintf("  author  : %s\n", ifelse("author" %in% names(info), info$author[1], "NA")))
    cat(sprintf("  year    : %s\n", ifelse("year" %in% names(info), info$year[1], "NA")))
    cat(sprintf("  ncase   : %s\n", ifelse("ncase" %in% names(info), info$ncase[1], "NA")))
    cat(sprintf("  ncontrol: %s\n", ifelse("ncontrol" %in% names(info), info$ncontrol[1], "NA")))
    cat(sprintf("  N       : %s\n", ifelse("sample_size" %in% names(info), info$sample_size[1], "NA")))
    cat(sprintf("  pmid    : %s\n", ifelse("pmid" %in% names(info), info$pmid[1], "NA")))
  } else {
    cat(sprintf("\n[%s] - 不存在或查询失败\n", id))
  }
}

cat("\n\n目标特征: author=Bellenguez, year=2022, ncase约39106(临床)或含proxy达85934+\n")
cat("PMID应为 35379992\n")
