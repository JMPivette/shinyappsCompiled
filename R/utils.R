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
#' @param pkg_path path to repository
#'
#' @return a character vector with Github repository information
#'
#' @examples github_path()
github_path <- function(pkg_path = pkgload::pkg_path()){

  git_URL <- gert::git_remote_info(repo = pkg_path)$url |>
    gsub(pattern = "\\.git$|^.*\\:\\/\\/:", replacement = "")

  if(grepl("github.com", git_URL) == FALSE){
    cli::cat_bullet(
      "Warning this package is not on Github ",
      crayon::blue(git_URL),
      bullet = "warning", bullet_col = "orange"
    )
    return("")
  }

  git_DESC <- pkgload::pkg_desc(pkg_path)$get_urls() |>
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

  sub(
    git_URL,
    pattern = "^github.com/|^.*:",
    replacement = ""
  )

}


is_valid_app_r <- function(pkg_path = pkgload::pkg_path()){
  appr_path <- fs::path(pkg_path, "app.R")

  if(!file.exists(appr_path))
    return(FALSE)

  appr_content <- readLines(fs::path(pkg_path, "app.R"))

  !any(grepl("^pkgload::load", appr_content)) &&
    any(grepl(pkgload::pkg_name(), appr_content))

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
