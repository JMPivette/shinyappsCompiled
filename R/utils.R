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


is_valid_app_r <- function(pkg_path = pkgload::pkg_path()){
  appr_path <- fs::path(pkg_path, "app.R")

  if(!file.exists(appr_path))
    return(FALSE)

  appr_content <- readLines(appr_path)

  expected_content <- paste0(
    "^library\\(",
    pkgload::pkg_name(pkg_path)
  )

  !any(grepl("^pkgload::load", appr_content)) &&
    any(grepl(expected_content, appr_content))

}

red_bullet <- function(...){
  cli::cat_bullet(
    ...,
    bullet = "cross", bullet_col = "red"
  )
}

green_bullet <- function(...){
  cli::cat_bullet(
    ...,
    bullet = "tick", bullet_col = "green"
  )
}

gh_token <- function(){
  if(Sys.getenv("GITHUB_PAT") != ""){
    Sys.getenv("GITHUB_PAT")
  } else {
    gh::gh_token()
  }
}
