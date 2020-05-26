# How to get all the data but not burn all the resources though

installed_pkgs <- installed.packages()
installed_pkgs <- sort(rownames(installed.packages()))
# writeLines(installed_pkgs, "input_packages.txt")

# pkgsearch? ---
installed_pkgs <- installed.packages()
installed_pkgs <- sort(rownames(installed.packages()))

cran_pkgs <- rownames(available.packages())

#cran_meta <- pkgsearch::cran_packages(installed_pkgs)
cran_meta <- pkgsearch::cran_packages(cran_pkgs)

cran_meta %>%
  janitor::clean_names() %>%
  select(
    package, version, title, maintainer, description,
    date_publication, bug_reports, url
  ) %>%
  mutate(
    date_publication = as.character(as.Date(date_publication)),
    url_cran = glue::glue("https://CRAN.R-project.org/package={package}")
  ) %>%
  mutate_all(~replace_na(.x, "")) %>%
  group_by(package) %>%
  tidyr::nest() %>%
  pull(data) %>%
  purrr::set_names(cran_meta$Package) %>%
  yaml::write_yaml(here::here("data", "packages", "installed_cran.yml"))


