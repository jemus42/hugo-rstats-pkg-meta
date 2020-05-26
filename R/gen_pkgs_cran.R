#' Get available packages from CRAN
#'
#' Returns a single two-column tibble based on [`utils::available.packages()`].
#' @return
#' @export
#'
#' @examples
#' gen_pkgs_cran()
gen_pkgs_cran <- function() {
   utils::available.packages() %>%
    tibble::as_tibble() %>%
    dplyr::transmute(
      package = .data$Package,
      url_cran = glue::glue("https://CRAN.R-project.org/package={package}"),
      version_cran = Version
    )
}

write_cran_yaml <- function() {
  pkgs <- gen_pkgs_cran()

  pkg_list <- pkgs %>%
    group_by(package) %>%
    tidyr::nest() %>%
    dplyr::pull(data) %>%
    purrr::set_names(pkgs$package)

  if (!file.exists(here::here("data", "packages"))) {
    dir.create(here::here("data", "packages"))
  }

  yaml::write_yaml(pkg_list, here::here("data/packages/cran.yml"))

}
