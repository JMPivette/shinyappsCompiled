#' Get Github path from repository
#'
#' @param pkg_path path to repository
#'
#' @return a character vector with Github repository information
#'
#' @examples
#' github_path()
github_path <- function(pkg_path = pkgload::pkg_path()){

  git_URL <- gert::git_remote_info(repo = pkg_path)$url
  git_DESC <- pkgload::pkg_desc(pkg_path)$get_urls()

  if(grepl("github.com", git_URL) == FALSE){
    cli::cat_bullet(
      "Warning this package is not on Github ",
      crayon::blue(git_URL),
      bullet = "warning", bullet_col = "orange"
    )
    return("")
  }

  git_URL_formatted <- format_gh_url(git_URL)
  git_DESC_formatted <- format_gh_url(git_DESC)


  if(git_URL_formatted != git_DESC_formatted){
    cli::cat_bullet(
      "Warning Git remote (",
      crayon::blue(git_URL),
      ") is different from DESCRIPTION file ",
      crayon::blue(git_DESC),")",
      bullet = "warning", bullet_col = "orange"
    )
  }

  sub(
    git_URL_formatted,
    pattern = "^github.com/",
    replacement = ""
  )

}

#' simply format github URL to remove .git extension and https or ssh header
#'
#' @param url url to reformat
#'
#' @return a character vector
#' @examples
#' format_gh_url("https://github.com/Name/repo.git")
format_gh_url <- function(url){
  url |>
    sub(
      pattern = ".*(github.com)(:|\\/)",
      replacement ="\\1/"
    ) |>
    sub(pattern = ".git$", replacement = "")

}
