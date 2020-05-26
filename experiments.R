# How to get all the data but not burn all the resources though

installed_pkgs <- installed.packages()
installed_pkgs <- sort(rownames(installed.packages()))
# writeLines(installed_pkgs, "input_packages.txt")

# pkgsearch? ---
installed_pkgs <- installed.packages()
installed_pkgs <- sort(rownames(installed.packages()))

cran_pkgs <- rownames(available.packages())

#cran_meta <- pkgsearch::cran_packages(installed_pkgs)
t1 <- Sys.time()
cran_meta <- pkgsearch::cran_packages(cran_pkgs)
t2 <- Sys.time()








write_cran_meta(cran_meta_full)
