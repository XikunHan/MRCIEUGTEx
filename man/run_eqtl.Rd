% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/model.R
\name{run_eqtl}
\alias{run_eqtl}
\title{Run linear models}
\usage{
run_eqtl(geno, tissue, tx = NULL, restrict_coding = T)
}
\arguments{
\item{geno}{Data.frame (or list of data.frames) of GTEx polygenic risk scores.}

\item{tissue}{Vector of tissues to be tested.}

\item{tx}{Vector of transcripts to be tested.}

\item{restrict.coding}{if TRUE (default) ignores non-coding transcripts.}
}
\value{
List of data.frames by tissue; each dataframe contains summary statistics
  (p,se,b) per transcript.
}
\description{
Run linear models
}
