% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{plot_cells}
\alias{plot_cells}
\title{plot_cells}
\usage{
plot_cells(
  spe_object,
  categories_of_interest = NULL,
  colour_vector = NULL,
  feature_colname = "Cell.Type"
)
}
\arguments{
\item{spe_object}{SpatialExperiment object or a data.frame that has cell
locations and cell type info.}

\item{categories_of_interest}{String Vector of cell categories to be
coloured.}

\item{colour_vector}{String Vector specifying the colours of each cell
type.}

\item{feature_colname}{String specifying the column the cell categories
belong to.}
}
\value{
A plot is returned
}
\description{
Produces a scatter plot of the cells in the tissue. Cells are
coloured categorically by \code{Cell.Type} column. Cell categories not specified
will be coloured "lightgrey" and labled "Unspecified".
}
