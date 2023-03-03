#' Deploy a compiled app to Shinyapps.io
#'
#' @param pkg path to package to upload
#' @param new_deploy Boolean. if TRUE creates a new deployment even if
#' @param ... additinal parameters passed to rsconnect::deployApp
#'
#' @export
deploy_compiled_app <- function(pkg = pkgload::pkg_path(),
                                new_deploy = FALSE,
                                ...){
  pk_name <- pkgload::pkg_name(pkg)
  ## check that app.R is correct and doesn't include build
  if(is_valid_app_r(pkg) == FALSE){
    red_bullet(
      "File 'app.R' doesn't seems to be valid. Please run ",
      crayon::yellow("'shinyappsCompiled::add_shinyapps_file()'"),
      " to overwrite"
    )
    return(invisible())
  }
  ## check that application is on Github
  gh_repo <- github_path(pkg)

  if(gh_repo == ""){
    red_bullet(
      "Error: In order to use 'shinyappsCompiled' your package should be on Github"
    )
    return(invisible())
  }

  ## Warn for uncommitted changes
  if(nrow(gert::git_status(pkg) != 0)){
    challenge_uncommited_changes <- readline(
      "There are uncommitted changes. Are you sure you want to deploy (Y/N) "
    )
    if(tolower(challenge_uncommited_changes) != "y") {
      return(invisible())
    }
  }

  ## Check if last commit has been pushed and ask to push if needed
  if(gert::git_ahead_behind()$ahead != 0){
    challenge_push <- readline(
      "Last commit hasn't been pushed to remote. Do you want to git push (Y/N) "
    )
    if(tolower(challenge_push) == "y") {
      gert::git_push(repo = pkg)
    } else {
      red_bullet("Deployment stopped")
      return(invisible())
    }
    green_bullet("Commit pushed to Github.")
  } else {
    green_bullet("Remote is up to date with last commit")
  }

  ## install from github (with right SHA)
  unloadNamespace(pk_name)
  commit_sha <- gert::git_commit_id()
  github_sha <- packageDescription(pk_name)$GithubSHA1

  if(is.null(github_sha) || commit_sha != github_sha){
    cli::cat_bullet("Installing ", gh_repo, " from Github")

    devtools::install_github(
      repo = gh_repo,
      ref = commit_sha,
      force = TRUE,
      quiet = TRUE,
      auth_token = gh_token()
    )
  }

  green_bullet(
    "Package installed from Github ",
    crayon::blue(
      paste(gh_repo, "@", commit_sha)
    )
  )

  ## Deploy App

  deploy_app(
    pkg,
    new_deploy = new_deploy,
    ...
  )

  invisible(0)
}


deploy_app <- function(
    pkg = pkgload::pkg_path(),
    new_deploy,
    ...){
  ## Synchronise with server
  cli::cat_bullet(
    "Sync application list with shinyapps.io server..."
  )
  try(rsconnect::syncAppMetadata(pkg))

  ## Check if has already been deployed.
  deployments <- rsconnect::deployments(pkg) [,c("account","name")]
  accounts <- rsconnect::accounts()

  if(new_deploy == TRUE || nrow(deployments) == 0){
    new_deploy_app(pkg, accounts, ...)
  } else if (nrow(deployments) == 1){
    rsconnect::deployApp(
      appDir = pkg,
      appFiles = "app.R",
      ...
    )
  } else {
    select_deploy_app(pkg, deployments, ...)
  }
}

new_deploy_app <- function(pkg, accounts, ...){

  account_name <- NULL
  if (nrow(accounts) > 1){
    account_choice <- readline(
      paste0(
        "Several Shinyapps accounts are available. Please select one: \n\t",
        paste(seq_along(accounts$name), ":", accounts$name, collapse = ',\n\t'),
        "\n"
      )
    )

    account_choice <- as.numeric(account_choice)
    account_name <- accounts$name[[account_choice]]
  }

  default_pkg_name <- pkgload::pkg_name(pkg)

  app_name <- readline(
    paste0(
      "Enter an application name ",
      "or press enter to use default name (",
      default_pkg_name, ") "
    )
  )

  if (app_name == "")
    app_name <- default_pkg_name

  rsconnect::deployApp(
    appDir = pkg,
    appFiles = "app.R",
    appName = app_name,
    account = account_name,
    ...
  )
}

select_deploy_app <- function(pkg, deployments, ...){
  deploy_choice <- readline(
    paste0(
      "Several deployments are available. Please select one: \n\t",
      paste(seq_along(deployments$name), ":",
            deployments$account, "/", deployments$name,
            collapse = ',\n\t'),
      "\n"
    )
  ) |>
    as.numeric()

  rsconnect::deployApp(
    appDir = pkg,
    appFiles = "app.R",
    appName = deployments$name[[deploy_choice]],
    account = deployments$account[[deploy_choice]],
    ...
  )

}

