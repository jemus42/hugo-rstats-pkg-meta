#' Create the packages.yml for installed packages
#'
#' @return A tibble
#' @export
#' @examples
#' \dontrun{
#' gen_package_yaml()
#' }
gen_package_yaml <- function() {
  packages <- rownames(utils::installed.packages())
  package_tbl <- purrr::map_dfr(packages, ~{

    description <- desc::desc(package = .x)

    tibble::tibble(
      package = .x,
      title = description$get("Title") %>% as.character(),
      #description = description$get("Description") %>% as.character(),
      urls = description$get_urls(),
      version = description$get_version() %>% as.character(),
      maintainer = description$get_maintainer()
    )

  })

  pkgs_cran <- utils::available.packages() %>%
    tibble::as_tibble() %>%
    dplyr::transmute(
      package = .data$Package,
      url_cran = glue::glue("https://CRAN.R-project.org/package={package}"),
      version_cran = Version
    )

  package_tbl %>%
    dplyr::mutate(
      maintainer = stringr::str_remove_all(maintainer, "\\s*<.*>"),
      urlkind = dplyr::case_when(
        stringr::str_detect(urls, "(github\\.com|gitlab\\.com|bitbucket|[Rr](-)?[Ff]orge|svn\\.r-project)") ~ "git",
        stringr::str_detect(urls, "(CRAN|cran|r-project)") ~ "cran",
        stringr::str_detect(urls, "(tidyverse|r-lib|tidymodels|github\\.io)\\.org") ~ "pkgdown",
        TRUE ~ "other"
      )
    ) %>%
    dplyr::filter(urlkind != "cran") %>%
    tidyr::pivot_wider(
      names_from = "urlkind", names_prefix = "url_",
      values_from = "urls", values_fn = first, values_fill = ""
    ) %>%
    dplyr::left_join(pkgs_cran, by = "package") %>%
    dplyr::mutate(
      url_cran = ifelse(is.na(url_cran), "", url_cran),
      version_cran = ifelse(is.na(version_cran), "", version_cran)
    ) %>%
    dplyr::group_by(package) %>%
    tidyr::nest() -> pkgslist

  pkgyaml <- purrr::map(pkgslist$data, unclass)
  names(pkgyaml) <- pkgslist$package

  yaml::write_yaml(pkgyaml, here::here("data/packages.yml"))
}
