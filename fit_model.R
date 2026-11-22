# Explicit sampling entry point.
# Run this script only when you intentionally want fresh Monte Carlo draws.
# It uses fixed output locations and replaces the current fit objects.

library(cmdstanr)
library(here)
library(digest)

# ---- Settings ----------------------------------------------------------------

seed_prior <- 123
seed_posterior <- 456

sampling <- list(
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 2000,
  adapt_delta = 0.95,
  max_treedepth = 12,
  refresh = 200
)

# ---- Inputs and directories ---------------------------------------------------

model_file <- here("stan", "model.stan")
data_file  <- here("data", "stan_data.rds")

stopifnot(file.exists(model_file), file.exists(data_file))

dir.create(here("fits", "prior"), recursive = TRUE, showWarnings = FALSE)
dir.create(here("fits", "posterior"), recursive = TRUE, showWarnings = FALSE)

stan_data <- readRDS(data_file)

# Compile only if needed. CmdStanR reuses the executable when it is up to date.
mod <- cmdstan_model(
  stan_file = model_file,
  force_recompile = FALSE
)

# Archive the exact source used by this fitting script.
file.copy(model_file, here("fits", "model.stan"), overwrite = TRUE)

# ---- Prior predictive sampling ------------------------------------------------

fit_prior <- do.call(
  mod$sample,
  c(
    list(
      data = c(stan_data, list(prior_only = 1L)),
      seed = seed_prior,
      output_dir = here("fits", "prior"),
      output_basename = "prior",
      save_warmup = FALSE
    ),
    sampling
  )
)

# Save to a temporary RDS first; replace the current object only after success.
prior_tmp <- here("fits", "prior", "fit_new.rds")
prior_final <- here("fits", "prior", "fit.rds")

fit_prior$save_object(prior_tmp)

if (file.exists(prior_final)) file.remove(prior_final)
stopifnot(file.rename(prior_tmp, prior_final))

# ---- Posterior sampling -------------------------------------------------------

fit <- do.call(
  mod$sample,
  c(
    list(
      data = c(stan_data, list(prior_only = 0L)),
      seed = seed_posterior,
      output_dir = here("fits", "posterior"),
      output_basename = "posterior",
      save_warmup = FALSE
    ),
    sampling
  )
)

posterior_tmp <- here("fits", "posterior", "fit_new.rds")
posterior_final <- here("fits", "posterior", "fit.rds")

fit$save_object(posterior_tmp)

if (file.exists(posterior_final)) file.remove(posterior_final)
stopifnot(file.rename(posterior_tmp, posterior_final))

# ---- Current-run provenance --------------------------------------------------

metadata <- list(
  date = Sys.time(),
  model_file = "stan/model.stan",
  data_file = "data/stan_data.rds",
  model_sha256 = digest::digest(model_file, algo = "sha256", file = TRUE),
  data_sha256 = digest::digest(data_file, algo = "sha256", file = TRUE),
  seeds = c(prior = seed_prior, posterior = seed_posterior),
  sampling = sampling,
  R_version = R.version.string,
  cmdstan_version = cmdstan_version(),
  cmdstanr_version = as.character(packageVersion("cmdstanr")),
  posterior_version = as.character(packageVersion("posterior"))
)

metadata_tmp <- here("fits", "metadata_new.rds")
saveRDS(metadata, metadata_tmp)
if (file.exists(here("fits", "metadata.rds"))) {
  file.remove(here("fits", "metadata.rds"))
}
stopifnot(file.rename(metadata_tmp, here("fits", "metadata.rds")))

message("Sampling completed. Current fits saved under fits/prior and fits/posterior.")
