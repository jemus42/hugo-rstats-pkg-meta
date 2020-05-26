# How to get all the data but not burn all the resources though

installed_pkgs <- installed.packages()
installed_pkgs <- sort(rownames(installed.packages()))
# writeLines(installed_pkgs, "input_packages.txt")

# pkgsearch? ---
installed_pkgs <- installed.packages()
installed_pkgs <- sort(rownames(installed.packages()))

cran_pkgs <- rownames(available.packages())
