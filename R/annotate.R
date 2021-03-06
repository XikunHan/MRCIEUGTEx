
#' Returns transcripts surpassing given FDR threshold in each tissue
#'
#' @param x List object returned by "run_eQTL".
#' @param fdr Should FDR be used.
#' @param pthresh Threshold for annotation gene names.
#' @return Data.frame of genes passing threshold, annotated with gene names.
#' @export
extract_top_hits <- function(x, fdr = T, pthresh = 0.05) {

  x <- do.call(rbind,unlist(x[['models']], recursive = F))

  if (fdr != 1) {
    th <- x[x$p <= pthresh,]
  } else {
    th <- x[x$fdr <= pthresh,]
  }

  tissue <- gsub(rownames(th), pattern = "(^\\S+)\\.(\\S+)\\.(ENSG\\S+)", replacement = "\\1")
  trait  <- gsub(rownames(th), pattern = "(^\\S+)\\.(\\S+)\\.(ENSG\\S+)", replacement = "\\2")
  gene   <- gsub(rownames(th), pattern = "(^\\S+)\\.(\\S+)\\.(ENSG\\S+)", replacement = "\\3")

  rownames(th) <- NULL
  df <- cbind(trait,tissue,gene,th)

  df <- df[order(df$p),]

  txrfm  <- gsub(df$gene, pattern = '\\.\\d+', replacement = '')

  symbol <- try(add_gene_names(ids = txrfm))
  # reorder symbol to conform to input
  if (class(symbol) != "try-error") {
    symbol <- symbol[match(txrfm, names(symbol))]
  } else {symbol <- rep("NA", length(txrfm)); names(symbol) <- txrfm}

  return(cbind(df, symbol))

  }


#' Render volcanoe plot for each element in output list.
#'
#' @param x List object returned by "run_eQTL"
#' @param fdr Should FDR corrected p-values be used for annotation.
#' @param p.thresh Threshold for adding gene name label.
#' @return volcanoe plots
#' @export
volcanoeplot <- function(x, fdr = T, p.thresh = 0.05) {

  x <- unlist(x[['models']], recursive = F)

  lapply(names(x), function(name) {

    tissue <- gsub(name, pattern = "(^\\S+)\\.(\\S+)", replacement = "\\1")
    trait  <- gsub(name, pattern = "(^\\S+)\\.(\\S+)", replacement = "\\2")

    message(paste0("volcanoe plot: ", tissue,"", trait))

    df  <- x[[name]]
    row.names(df) <- gsub(row.names(df), pattern = '\\.\\d+', replacement = '')

    if (fdr != 1) {
      sig_ids   <- row.names(df[df$p <= p.thresh,]); pass <- df$p <= p.thresh
    } else {sig_ids <- row.names(df[df$fdr <= p.thresh,]); pass <- df$fdr <= p.thresh}


    if (length(sig_ids) > 0) {
      try(symbols   <- add_gene_names(sig_ids), silent = T)
      if (class(symbols) == "try-error") {
        df$symbol <- NA
      } else {df$symbol <- symbols[match(x = rownames(df), table = names(symbols))]}
    } else {df$symbol <- NA }

    plot <- ggplot(df, aes(x= b, y= -log10(p), colour = pass, label=as.character(symbol))) +
      geom_point(alpha=0.4, size=1.75) +
      geom_text(aes(label=ifelse(pass,as.character(symbol),'')),hjust=0,vjust=0) +
      theme(legend.position="none") +
      ggtitle(paste0(tissue,":",p.thresh))

    return(plot)
  })
}

add_gene_names <- function(ids) {
  # one-to-many output
  output <- select(x = org.Hs.eg.db, columns = 'SYMBOL', keys = as.character(ids), keytype = 'ENSEMBL')
  # make one-to-one
  return(unlist(lapply(split(output, output$ENSEMBL), function(x) paste(x[,'SYMBOL'], collapse = ','))))
}
