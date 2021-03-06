# dMod -- Dynamic Modeling and Parameter Estimation in ODE Models

The framework provides functions to generate ODEs of reaction networks, parameter transformations, observation functions, residual functions, etc. The framework follows the paradigm that derivative information should be used for optimization whenever possible. Therefore, all major functions produce and can handle expressions for symbolic derivatives.

## Simple example: enzyme kinetics

### Load required packages

```r
library(deSolve)
library(dMod)
```

### Generate an ODE model of enzyme kinetics with enzyme degradation

```r
f <- NULL
f <- addReaction(from = "E + S", to = "C", rate = c("production of complex" = "k1*E*S"), f)
f <- addReaction(from = "C", to = "E + S", rate = c("decay of complex" = "k2*C"), f)
f <- addReaction(from = "C", to = "E + P", rate = c("production of product" = "k3*C"), f)
f <- addReaction(from = "E", to = ""     , rate = c("enzyme degradation" = "k4*E"), f)
model <- generateModel(f, modelname = "enzymeKinetics")
```

### Define observables and generate observation function `g`

```r
observables <- c(product = "P", substrate = "S + C", enzyme = "E + C")

# Generate observation function
g <- Y(observables, f, compile = TRUE, modelname = "obsfn")
```

### Define parameter transformation for two experimental conditions

```r
# Get all parameters
innerpars <- getSymbols(c(f, names(f)))
# Symbolically write down a log-transform
trafo1 <- trafo2 <- structure(paste0("exp(log", innerpars, ")"), names = innerpars)
# Set some initial parameters
trafo1["C"] <- trafo2["C"] <- "0"
trafo1["P"] <- trafo2["P"] <- "0"
# Set the degradation rate in the first condition to 0
trafo1["k4"] <- "0"
# Get names of the new parameters
outerpars <- getSymbols(c(trafo1, trafo2))

# Generate parameter transformation functions
pL <- list(noDegradation = P(trafo1), 
           withDegradation = P(trafo2))

conditions <- names(pL)
```

### Define the model prediction function

```r
# Generate low-level prediction functions
xL <- lapply(conditions, function(cond) Xs(model$func, model$extended))
names(xL) <- conditions

# Generate a high-level prediction function: trafo -> prediction -> observation
x <- function(times, pouter, fixed=NULL, ...) {
  
  out <- lapply(conditions, function(cond) {
    pinner <- pL[[cond]](pouter, fixed)
    prediction <- xL[[cond]](times, pinner, ...)
    observation <- g(prediction, pinner, attach.input = TRUE)
    return(observation)
  }); names(out) <- conditions
  return(out)
  
}

# Initialize with randomly chosen parameters
set.seed(1)
pouter <- structure(rnorm(length(outerpars), -2, .5), names = outerpars)
times <- 0:100

plotPrediction(x(times, pouter))
```

![plot of chunk prediction](figure/prediction-1.png) 

### Define data to be fitted by the model

```r
data <- list(
  noDegradation = data.frame(
    name = c("product", "product", "product", "substrate", "substrate", "substrate"),
    time = c(0, 25, 100, 0, 25, 100),
    value = c(0.0025, 0.2012, 0.3080, 0.3372, 0.1662, 0.0166),
    sigma = 0.02),
  withDegradation = data.frame(
    name = c("product", "product", "product", "substrate", "substrate", "substrate", "enzyme", "enzyme", "enzyme"),
    time = c(0, 25, 100, 0, 25, 100, 0, 25, 100),
    value = c(-0.0301,  0.1512, 0.2403, 0.3013, 0.1635, 0.0411, 0.4701, 0.2001, 0.0383),
    sigma = 0.02)
)
timesD <- sort(unique(unlist(lapply(data, function(d) d$time))))

# Compare data to prediction
plotCombined(x(times, pouter), data)
```

![plot of chunk data](figure/data-1.png) 

### Define an objective function to be minimized and run minimization by `trust()`

```r
obj <- function(pouter, fixed=NULL, deriv=TRUE) {
  
  prediction <- x(timesD, pouter, fixed = fixed, deriv = deriv)
  
  # Apply res() and wrss() to compute residuals and the weighted residual sum of squares
  out.data <- lapply(names(data), function(cn) wrss(res(data[[cn]], prediction[[cn]])))
  out.data <- Reduce("+", out.data)
  
  # Working with weak prior (helps avoiding runaway solutions of the optimization problem)
  out.prior <- constraintL2(pouter, prior, sigma = 10)
  
  out <- out.prior + out.data
  
  # Comment in if you want to see the contribution of prior and data
  # e.g. in profile() and plotProfile()
  attr(out, "valueData") <- out.data$value
  attr(out, "valuePrior") <- out.prior$value
  
  return(out)
  
}

# Optimize the objective function
prior <- structure(rep(0, length(pouter)), names = names(pouter))
myfit <- trust(obj, pouter, rinit = 1, rmax = 10)

plotCombined(x(times, myfit$argument), data)
```

![plot of chunk trust](figure/trust-1.png) 


### Compute the profile likelihood to analyze parameter identifiability

```r
library(parallel)
bestfit <- myfit$argument
profiles <- do.call(c, mclapply(names(bestfit), function(n) profile(obj, bestfit, n, limits=c(-10, 10)), mc.cores=4))

# Take a look at each parameter
plotProfile(profiles)
```

![plot of chunk profiles](figure/profiles-1.png) 

```r
# Compare parameters and their confidence intervals
plotProfile(profiles) + facet_wrap(~name, ncol = 1)
```

![plot of chunk profiles](figure/profiles-2.png) 



