% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lib_plot_jackknife.R
\name{revolver_plt_jackknife_coclust_bplot}
\alias{revolver_plt_jackknife_coclust_bplot}
\title{Plot jackknife statistics for co-clustering (boxplot).}
\usage{
revolver_plt_jackknife_coclust_bplot(x, file = NA, cex = 1)
}
\arguments{
\item{x}{An object obtained as output of \code{\link{revolver_jackknife}}.}

\item{file}{Output file, or NA.}

\item{cex}{cex for the plot.}
}
\value{
None
}
\description{
Plot jackknife statistics for co-clustering (boxplot).
}
\details{
It plots a boxplot with the result of the jackknife computations
for the co-clustering probability.
}
\examples{
data(Breast.fit)
revolver_plt_jackknife_coclust_bplot(Breast.fit)
}
