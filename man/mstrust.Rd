% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/toolsWolfgang.R
\name{mstrust}
\alias{mstrust}
\title{Non-Linear Optimization, multi start}
\usage{
mstrust(objfun, center, rinit = 0.1, rmax = 10, fits = 20, cores = 1,
  samplefun = "rnorm", resfld = ".", logfile = "mstrust.log",
  fitsfile = "fitlist.rda", stats = FALSE, msgtag = "",
  narrowing = NULL, ...)
}
\arguments{
\item{objfun}{Objective function, see \code{\link{trust}}.}

\item{center}{Parameter values around which the initial values for each fit
  are randomly sampled. The initial values handed to \link{trust} are the sum
  of center and the output of \option{samplefun}, center +
  \option{samplefun}. See \code{\link{trust}}, parinit.}

\item{rinit}{Starting trust region radius, see \code{\link{trust}}.}

\item{rmax}{Maximum allowed trust region radius, see \code{\link{trust}}.}

\item{fits}{Number of fits (jobs).}

\item{cores}{Number of cores for job parallelization.}

\item{samplefun}{Function to sample random initial values. It is assumed,
that \option{samplefun} has a named parameter "n" which defines how many
random numbers are to be returned, such as for \code{\link{rnorm}}, which
is also the default sampling function.}

\item{resfld}{If provided, temporary files, log file, and results are saved
under that path. The current working directory is the default.}

\item{logfile}{Name of the file to which all jobs log their output. The file
is handy to investigate the different jobs in some detail. Since the jobs
are carried out in parallel, their output may occurre in non-consecutive
order. At the end of the file, a summary of the fits is given.}

\item{fitsfile}{Name of the file to which the result of all completed fits
are written to. An empy string "" suppresses the write.}

\item{stats}{If true, the same summary statistic as written to the logfile is
printed to command line.}

\item{msgtag}{A string prepending the logging output written to file.}

\item{narrowing}{If NULL, we are not in narrowing mode, see
\code{\link{msnarrow}}. In narrowing mode, this parameter indicates the
narrowing status.}

\item{...}{Additional parameters which are handed to trust() or samplefun()
  by matching parameter names. All remaining parameters are handed to the
  objective function objfun().}
}
\value{
A data frame of all completed fits sorted by their objective value.
  The data frame carries an attribute "fitlist" returning the raw output of
  trust(). This length of the fitlist equals \option{fits}. The colunm
  index in the returned data frame can be used to index the fitlist to
  retrive the corresponding result from \code{\link{trust}}.
}
\description{
Wrapper around \code{\link{trust}} allowing for multiple fits
  from randomly chosen initial values.
}
\details{
By running multiple fits starting with randomly chosen inital
  parameters, the chisquare landscape can be explored using a deterministic
  optimizer. In this case, \code{\link{trust}} is used for optimization. The
  standard procedure to obtain random initial values is to sample random
  variables from a uniform distribution (\code{\link{rnorm}}) and adding
  these to \option{center}. It is, however, possible, to employ any other
  sampling strategy by handing the respective function to mstrust(),
  \option{samplefun}.

  All started fits are either faulty, aborted, or complete. Faulty fits
  return a "try-error" object and fail somewhere outside trust(). Aborted
  fits fail withing trust(), and complete fits return from trust() correctly.
  Completed fits can still be unconverged, in case the maximum number of
  iteration is reached before the convergence criterion.

  In case a special sampling is required, a customized sampling function can
  be used. If, e.g., inital values leading to a non-physical systems are to
  be discarded upfront, the objective function can be addapted accordingly.

  On fitting, a folder for temporary files is created under \option{resfld}.
  The name of the folder ist tmp- followed by the current date and time.
  There, the result of each fit is saved. After a crash, results completed
  before the crash can be restored., see \code{\link{msrestore}}.
}
\author{
Wolfgang Mader, \email{Wolfgang.Mader@fdm.uni-freiburg.de}
}
\seealso{
\code{\link{trust}}, \code{\link{rnorm}},, \code{\link{msnarrow}},
  \code{\link{msbest}}
}

