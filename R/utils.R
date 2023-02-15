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

#' Get Github path from repository
#'
#' @param repo path to repository
#'
#' @return a character vector with Github repository information
#'
#' @examples github_path()
github_path <- function(repo = "."){

  git_URL <- git2r::remote_url(repo) |>
    gsub(pattern = "\\.git$|^.*\\:\\/\\/", replacement = "")

  if(grepl("github.com", git_URL) == FALSE){
    cli::cat_bullet(
      "Warning this package is not on Github ",
      crayon::blue(git_URL),
      bullet = "warning", bullet_col = "orange"
    )
    return("")
  }

  git_DESC <- pkgload::pkg_desc(repo)$get_urls() |>
    gsub(pattern = "^.*\\:\\/\\/", replacement = "")

  if(git_URL != git_DESC){
    cli::cat_bullet(
      "Git remote(",
      crayon::blue(git_URL),
      ") is different from DESCRIPTION file(",
      crayon::blue(git_DESC),
      bullet = "warning", bullet_col = "orange"
    )
  }

  git_URL

}
