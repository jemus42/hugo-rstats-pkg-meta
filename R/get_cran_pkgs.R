#' Get available packages from CRAN
#'
#' Returns a single two-column tibble based on [`utils::available.packages()`].
#' @return A tibble of metadata.
#' @export
#'
#' @examples
#' get_cran_pkgs()
get_cran_pkgs <- function(chunk_size = 200, timeout = .01) {
  cran_pkgs <- rownames(available.packages(
    repos = "https://cloud.r-project.org/"
  ))
  cran_pkg_chunks <- split(cran_pkgs, ceiling(seq_along(cran_pkgs) / chunk_size))

  p <- cli::cli_progress_bar("Getting stuff", total = length(cran_pkg_chunks))
  cran_meta_full <- purrr::map_df(cran_pkg_chunks, ~{
    cli::cli_progress_update(id = p)
    res <- pkgsearch::cran_packages(.x)
    Sys.sleep(timeout)
    res
  })
  cli::cli_progress_done(id = p)


  if (!file.exists(here::here("cache"))) dir.create(here::here("cache"))

  saveRDS(cran_meta_full, here::here("cache", "cran_meta_full.rds"))

  cran_meta_full
}

#' Write (and cleanup) the CRAN package metadata
#'
#' @param metadata The metadata as returned by [`get_cran_pkgs()`].
#' @param file_out `[cran.yaml]` The output `YAML` file relative to `data/packages/`
#'
#' @return Nothign
#' @export
#'
#' @examples
#' \dontrun{
#' get_cran_pkgs() %>%
#'   write_cran_meta()
#' }
write_cran_meta <- function(metadata, file_out = "cran.yml") {
  metadata %>%
    janitor::clean_names() %>%
    dplyr::select(
      package, version, title, maintainer, description,
      date_publication, bug_reports, url
    ) %>%
    dplyr::mutate(
      maintainer = stringr::str_remove(maintainer, "\\s+<.*>"),
      date_publication = as.character(as.Date(date_publication)),
      url_cran = glue::glue("https://CRAN.R-project.org/package={package}"),
      url = stringr::str_remove_all(url, "(\\\n)|(\\s+)"),
      url = stringr::str_split(url, ","),
      url_git = purrr::map_chr(url, ~{
        res <- stringr::str_subset(.x, regex_source_repo)
        ifelse(identical(res, character()), "", res)
      }),
      url = purrr::map_chr(url, ~{
        # Try to leave only non-git, hopefully documentation websites
        res <- stringr::str_subset(.x, regex_not_website, negate = TRUE)
        ifelse(identical(res, character()), "", res)
      })
    ) %>%
    dplyr::mutate_all(~tidyr::replace_na(.x, "")) %>%
    dplyr::group_by(package) %>%
    tidyr::nest() %>%
    dplyr::pull(data) %>%
    purrr::set_names(metadata$Package) %>%
    yaml::write_yaml(here::here("data", "packages", file_out))
}

# Regexes to determine URL context
regex_source_repo <- "(github\\.com)|([Rr]-[Ff]orge)|(gitlab\\.com)|(bitbucket\\.org)"
regex_cran <- "([rR]-project\\.org)"
regex_not_website <- paste0(c(regex_source_repo, regex_cran), collapse = "|")
