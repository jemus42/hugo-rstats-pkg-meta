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
