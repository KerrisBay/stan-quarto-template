# Demonstration data generator.
# Replace this script with your real data preparation pipeline.

library(here)


N <- 80
x <- sort(runif(N, -2, 2))
alpha <- 0.7
beta <- 1.4
sigma <- 0.6
y <- rnorm(N, alpha + beta * x, sigma)

stan_data <- list(
  N = N,
  x = as.vector(x),
  y = as.vector(y)
)

dir.create(here("data"), showWarnings = FALSE, recursive = TRUE)
saveRDS(stan_data, here("data", "stan_data.rds"))

message("Wrote data/stan_data.rds")
