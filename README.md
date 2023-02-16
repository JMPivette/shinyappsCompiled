
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shinyappsCompiled

<!-- badges: start -->
<!-- badges: end -->

The goal of shinyappsCompiled is to deploy Golem application that
contains C++ code to shinyapps.io By default this is not possible
because compilation of C++ can’t be done when the application is
launched.

Instead, the package must be installed and compiled during the
deployment process.

This is achieved by pushing the code to Github (private or public) and
then installing the application using `devtools::install_github()`.

## Installation

You can install the development version of shinyappsCompiled from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("JMPivette/shinyappsCompiled")
```

## Add or modify ‘app.R’

This function creates or overwrites app.R that is used during the
deployment process

``` r
add_shinyapps_file()
```

## Deploy App to Shinyapps.io

Repo is first installed from Github and then uploaded and compiled in
shinyapps.io

``` r
deploy_compiled_app()
```
