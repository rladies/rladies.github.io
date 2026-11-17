# Re-snapshot one renv profile against a dated Posit Package Manager snapshot.
#
# Run this on the runner image CI uses: PPM builds binaries per platform, and a
# snapshot taken on macOS records versions that have no Linux binary yet, which
# sends CI back to compiling from source.

profile <- Sys.getenv("RENV_PROFILE")
snapshot_date <- Sys.getenv("SNAPSHOT_DATE")
stopifnot(nzchar(profile), nzchar(snapshot_date))

repos <- c(CRAN = paste0("https://packagemanager.posit.co/cran/", snapshot_date))

description <- read.dcf("DESCRIPTION")
field <- paste0("Config/renv/profiles/", profile, "/dependencies")
if (!field %in% colnames(description)) {
  stop("DESCRIPTION declares no dependencies for profile '", profile, "'")
}

dependencies <- trimws(strsplit(description[1, field], ",")[[1]])
dependencies <- dependencies[nzchar(dependencies)]

remotes <- character()
if ("Remotes" %in% colnames(description)) {
  remotes <- trimws(strsplit(description[1, "Remotes"], ",")[[1]])
  # Remotes may be written as `user/repo`, `user/repo@ref`, `github::user/repo`
  # or `pkg=user/repo`; the package name is what we match dependencies against.
  named <- sub("=.*$", "", remotes)
  sources <- sub("^.*=", "", remotes)
  names(remotes) <- ifelse(
    named == remotes,
    basename(sub("@.*$", "", sub("^.*::", "", sources))),
    named
  )
}

specs <- ifelse(dependencies %in% names(remotes), remotes[dependencies], dependencies)

# The runner's R is configured with PPM's `latest` repository. renv records
# the repository each package came from, so without overriding it the lockfile
# pins versions against a moving repository and they stop being served as
# binaries as soon as CRAN moves on.
Sys.setenv(RENV_CONFIG_REPOS_OVERRIDE = repos[["CRAN"]])

# renv resets repos as it works, so set them before every call.
options(repos = repos, renv.config.auto.snapshot = FALSE)
renv::install(specs, prompt = FALSE)

options(repos = repos)
# renv itself is excluded: the project bootstraps from the renv/activate.R that
# is committed, so its version is pinned by that file, not by the snapshot.
renv::update(exclude = "renv", prompt = FALSE)

options(repos = repos)
renv::snapshot(prompt = FALSE, type = "explicit")
