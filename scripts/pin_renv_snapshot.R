# Pin the root renv.lock and renv/settings.json to the running R version and a
# Posit Package Manager snapshot.
#
# The profile lockfiles are written by renv::snapshot (see refresh_renv.R). The
# root lockfile is not re-snapshotted -- it exists so that setup-r's
# `r-version: renv` resolves the same R version the profiles were built with --
# so its two fields are set here instead.

snapshot_date <- Sys.getenv("SNAPSHOT_DATE")
stopifnot(nzchar(snapshot_date))

r_version <- paste(R.version$major, R.version$minor, sep = ".")
repo <- paste0("https://packagemanager.posit.co/cran/", snapshot_date)

lockfile <- renv::lockfile_read("renv.lock")
lockfile$R$Version <- r_version
lockfile$R$Repositories <- list(CRAN = repo)
renv::lockfile_write(lockfile, "renv.lock")

renv::settings$r.version(r_version)

cat("pinned renv.lock to R", r_version, "snapshot", snapshot_date, "\n")
