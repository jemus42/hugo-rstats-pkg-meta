# How to get all the data but not burn all the resources though

installed_pkgs <- installed.packages()
installed_pkgs <- sort(rownames(installed.packages()))
# writeLines(installed_pkgs, "input_packages.txt")

# pkgsearch? ---
installed_pkgs <- installed.packages()
installed_pkgs <- sort(rownames(installed.packages()))

cran_pkgs <- rownames(available.packages())


metadata %>%
  janitor::clean_names() %>%
  dplyr::select(
    package, version, title, maintainer, description,
    date_publication, bug_reports, url
  ) %>%
  dplyr::mutate(
    maintainer = stringr::str_remove(maintainer, "\\s+<.*>"),
    date_publication = as.character(as.Date(date_publication)),
    url_cran = glue::glue("https://CRAN.R-project.org/package={package}")
  ) -> test

regex_source_repo <- "(github\\.com)|([Rr]-[Ff]orge)|(gitlab\\.com)|(bitbucket\\.org)"
regex_cran <- "([rR]-project\\.org)"

regex_not_website <- paste0(c(regex_source_repo, regex_cran), collapse = "|")

test %>%
  select(package, url) %>%
  # The middle two packages have weird things going on in their URL field
  #filter(package %in% c("ggplot2", "betaboost", "ArrayBin", "car")) %>%
  mutate(
    url = stringr::str_remove_all(url, "(\\\n)|(\\s+)"),
    url = stringr::str_split(url, ","),
    url_git = purrr::map_chr(url, ~{
      res <- stringr::str_subset(.x, regex_source_repo)
      ifelse(identical(res, character()), "", res)
    }),
    url = purrr::map_chr(url, ~{
      res <- stringr::str_subset(.x, regex_not_website, negate = TRUE)
      ifelse(identical(res, character()), "", res)
    })
  ) %>%
  filter(stringr::str_detect(url, "^(htt|ww)", negate = TRUE), url != "") %>%
  View()
