data {
  int<lower=1> N;
  vector[N] x;
  vector[N] y;
  int<lower=0, upper=1> prior_only;
}

parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;
}

model {
  // Priors
  alpha ~ normal(0, 1.5);
  beta  ~ normal(0, 1);
  sigma ~ exponential(1);

  // Switch likelihood off for prior predictive sampling
  if (prior_only == 0) {
    y ~ normal(alpha + beta * x, sigma);
  }
}

generated quantities {
  vector[N] y_rep;

  for (n in 1:N) {
    y_rep[n] = normal_rng(alpha + beta * x[n], sigma);
  }
}
