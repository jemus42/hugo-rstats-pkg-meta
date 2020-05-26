# hugo-rstats-pkg-meta

> The catchies title of them all.

I don't know where this is going yet, please move along.

## Motivation

The goal is to auto-generate a file (or multiple files?) that are suitable as [Hugo data templates](https://gohugo.io/templates/data-templates/).  
The idea is to collect some basic metadata about R packages and have easy access to said data via the use of Hugo templates and/or shortcodes.

Currently I have generated *something* that at least collects _all_ the CRAN packages and basic metadata, but of course it would also be neat of GitHub-only packages would be included as well, but I have no idea how to handle that yet.

Initially, for my own use, that data was based on my locally installed packages, but since I hope to automate the process via GitHub Actions, this does not seem feasible.

## Current Status

- [`data/packages.yml`](data/packages.yml): Derived from my locally installed packages and used by my hugo shortcode.
- [`data/packages/cran.yml`](data/packages/cran.yml): Collected via `available.packages()` and `pkgsearch::cran_packages()`, so it should contain _all_ CRAN packages, but not with cleaned up URLs yet. Also, this file is >10MB.


## Usage

To use this data with a Hugo site, you'll have to include it either as a theme component or a Hugo module in your `config.toml`:

```toml
[module]
  [[module.imports]]
    path = "github.com/jemus42/hugo-rstats-pkg-meta"
```
