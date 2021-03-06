% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/toolsDaniel.R
\name{generateModel}
\alias{generateModel}
\title{Generate the model objects for use in Xs (models with sensitivities)}
\usage{
generateModel(f, forcings = NULL, fixed = NULL, modelname = "f", ...)
}
\arguments{
\item{f}{Named character vector with the ODE}

\item{forcings}{Character vector with the names of the forcings}

\item{fixed}{Character vector with the names of parameters (initial values and dynamic) for which
no sensitivities are required (will speed up the integration).}

\item{modelname}{Character, the name of the C file being generated.}

\item{...}{Further arguments being passed to funC.}
}
\value{
list with \code{func} (ODE object) and \code{extended} (ODE+Sensitivities object)
}
\description{
Generate the model objects for use in Xs (models with sensitivities)
}

