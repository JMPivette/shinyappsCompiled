#' Is fct exported from package stored in pkg_path
#'
#' @param fct a function name (run_app for example)
#' @param pkg_path where the package is stored
#'
#' @return a boolean
#'
#' @examples is_exported("run_app")
is_exported <- function(fct,
                        pkg_path = pkgload::pkg_path()){

  expected_line <- paste0("export(", fct, ")")

  expected_line %in% readLines(fs::path(pkg_path, "NAMESPACE"))

}
