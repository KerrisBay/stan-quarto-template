# Simple Quarto + CmdStanR template

This template uses **one current analysis** with fixed filenames. It separates data preparation, Stan source, sampling, and reporting.

## How to use the template

The template is set as a template in github, so...
1. Create a new repository using this template and copy the link to this repo. 
2. Open a folder where you want to put all the files
3. Ctrl+Shift+RMB, open terminal here and write `git clone https://github.com/YOUR_USERNAME/THE_LINK_TO_REPOSITORY.git`
4. Rename the *.Rproj file to match the folder name. 
5. Change the owner if necessary `git config --global --add safe.directory D:/THE_NEWLY_CREATED_DIR`


## Project workflow

1.  Install the required packages and CmdStan (once).
2.  Run `R/prepare_data.R` to create `data/stan_data.rds`.
3.  Run `fit_model.R` explicitly when you want fresh prior and posterior draws.
4.  Render `report.qmd`. Rendering loads saved fits; it does not compile or sample.

## Packages

``` r
install.packages(c(
  "cmdstanr", "posterior", "bayesplot", "ggplot2",
  "dplyr", "tidyr", "knitr", "digest", "here"
))
cmdstanr::install_cmdstan()
```

`cmdstan_model()` checks whether the model needs recompilation. If the Stan source is unchanged and the compiled executable is available, it can reuse it. Sampling is separate: every call to `$sample()` launches a new sampling run.

## Fixed output layout

``` text
fits/
├── prior/
│   ├── fit.rds
│   └── chain CSV files
├── posterior/
│   ├── fit.rds
│   └── chain CSV files
└── metadata.rds
```

Each execution of `fit_model.R` replaces the current fit objects and chain CSV outputs. Keep a backup or use version control / a separate archive if you need to retain earlier sampling runs.

The fitting script saves each new RDS to a temporary file first and then replaces the current `fit.rds` only after the new fit has completed and the object has been serialized successfully. The CmdStan CSV output directory is still a current-run directory and should not be used concurrently by multiple sampling processes.

## Reproducibility notes

- The Stan source contains a `prior_only` switch. The same priors and generative model are used for prior and posterior predictive sampling; only the likelihood contribution is switched off/on.
- Prior-only sampling still uses NUTS for continuous parameters.
- A fixed seed makes a run reproducible under comparable software and hardware conditions. It does not measure between-run Monte Carlo variability.
- `metadata.rds` records the current model/data hashes, seeds, settings, and software versions.
- The report displays the archived source copy stored at `fits/model.stan`, which is copied at fitting time. This keeps the displayed model aligned with the last successful fitting script execution.
- The example model is deliberately simple. Replace its likelihood, priors, data declarations, and generated quantities with your scientific model.


## Git

### Initialization (skip if created from the template in github)

- git init
- git add .
- git commit -m "Initial analysis"
- git branch -M main
- git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPOSITORY.git
- git push -u origin main

### Commit and push changes

- git add .
- git commit -m "Describe changes"
- git push

### Git status

- git status
- git diff

### Render website (gh-pages)

- quarto publish gh-pages