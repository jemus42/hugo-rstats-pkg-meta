gen_package_yaml <- function() {
  require(stringr)
  require(dplyr)
  # packages data file ----
  packages <- rownames(installed.packages())

  packages_cran <- available.packages() %>%
    as_tibble() %>%
    transmute(
      package = Package,
      url_cran = glue::glue("https://CRAN.R-project.org/package={package}")
    )


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

  package_tbl %>%
    mutate(
      name = package,
      maintainer = str_remove_all(maintainer, "\\s*<.*>"),
      urlkind = case_when(
        str_detect(urls, "(github\\.com|gitlab\\.com|bitbucket|[Rr](-)?[Ff]orge|svn\\.r-project)") ~ "git",
        str_detect(urls, "(CRAN|cran|r-project)") ~ "cran",
        str_detect(urls, "(tidyverse|r-lib|tidymodels|github\\.io)\\.org") ~ "pkgdown",
        TRUE ~ "other"
      )
    ) %>%
    filter(urlkind != "cran") %>%
    tidyr::pivot_wider(
      names_from = "urlkind", names_prefix = "url_",
      values_from = "urls", values_fn = first, values_fill = ""
    ) %>%
    left_join(packages_cran, by = "package") %>%
    mutate(url_cran = ifelse(is.na(url_cran), "", url_cran)) %>%
    group_by(package) %>%
    tidyr::nest() -> pkgslist

  pkgyaml <- purrr::map(pkgslist$data, unclass)
  names(pkgyaml) <- pkgslist$package

  yaml::write_yaml(pkgyaml, here::here("data/packages.yml"))
}

gen_package_yaml()
