#' Creates an app.R file that can be deployed to shinyapps.io
#' Inspired by golem::add_rstudio_files()
#'
#' @param pkg pacakge directory
#' @param open logical. Should file be opened afterwards
#'
#' @export
#'
add_shinyapps_file <- function(
    pkg = pkgload::pkg_path(),
    open = rlang::is_interactive(),
    runapp_funct = "run_app"
) {

  where_deploy <- fs::path(pkg, "app.R")

  ## Check if runapp_funct exists
  if(is_exported(runapp_funct) == FALSE){
    cli::cat_bullet(
      "Error: '", runapp_funct,
      "()' is not an exported function from this package",
      bullet = "cross", bullet_col = "red"
    )
    return(invisible())
  }

  ## Check if package is on Github (impossible to compile otherwise)
  if(github_path(pkg) == ""){
    cli::cat_bullet(
      "Error: In order to use 'shinyappsCompiled' your package should be on Github",
      bullet = "cross", bullet_col = "red"
    )
    return(invisible())
  }


  ## Check if app.R file exists
  if(fs::file_exists(where_deploy)){
    overwrite <- readline(
      paste("File 'app.R' already exists. Do you want to overwrite it? (Y/N) ")
    )
    if(tolower(overwrite) != "y") {
      return(invisible())
    } else {
      fs::file_delete(where_deploy)
      cli::cat_bullet(
        "Deleting ", crayon::blue(where_deploy),
        bullet = "tick", bullet_col = "green"
      )
    }
  }
  ## create deploy file
  fs::file_create(where_deploy)

  write_there <- function(..., here = where_deploy) {
    write(..., here, append = TRUE)
  }

  usethis::use_build_ignore("rsconnect")
  write_there("# Launch the ShinyApp")
  write_there("# To deploy, run: shinyappsCompiled::deployCompiledApp()")
  write_there("")
  write_there("options( \"golem.app.prod\" = TRUE)")
  write_there(
    paste0(
      pkgload::pkg_name(),
      "::run_app() # add parameters here (if any)"
    )
  )

  cli::cat_bullet(
    "File created at ",
    crayon::blue(where_deploy),
    bullet = "tick", bullet_col = "green"
  )
  cat("To deploy, run:\n")
  cli::cat_bullet(
    "shinyappsCompiled::deployCompiledApp()"
  )


}
