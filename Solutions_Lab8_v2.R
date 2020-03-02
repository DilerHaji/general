############ EEB 5050
#### WalkThrough Code for Lab 8
############

library(R2jags)

#######----------------- PART A1 -----------------########
plants <- read.csv("../plantdamage_surv(3).csv")

head(plants)

## Write JAGS code
# The code below is a way to include the JAGS code in your script
# while exporting it to a .R file in your working directory
# I show this method here as a demonstration of how to keep everything altogether
sink("JAGS_plants.R")
cat("
    model{
  # Process model
  for(i in 1:n.obs) {
    logit(p[i]) <- b0 + b1*light[i] + b2*damage[i] + b3*damage[i]*light[i]
    survs[i] ~ dbin(p[i], 4)
  }
  # Priors
  b0 ~ dnorm(0, 0.001)
  b1 ~ dnorm(0, 0.001)
  b2 ~ dnorm(0, 0.001)
  b3 ~ dnorm(0, 0.001)
    }
    ") ; sink()


## Get data ready for JAGS  <-  needs to be a list
jags.plants <- list(
  survs = plants$survs,
  light = (plants$light == "L")*1, # notice that this creates a simple dummy variable where 1 = Light
  damage = plants$damage,
  n.obs = length(plants$light)
  )

## Run the JAGS code
model.plants <- jags(data = jags.plants, 
                    parameters.to.save = c("b0","b1","b2","b3"),
                    model.file = "JAGS_plants.R",
                    n.chains = 3,
                    n.iter = 20000,
                    n.burnin = 5000,
                    n.thin = 10)
model.plants

# We can also compare to the MLE estimate (A3)
surv.mat <- matrix(data = c(jags.plants$survs, 4 - jags.plants$survs), ncol = 2)
summary(glm(surv.mat ~ light + damage + light*damage, data = jags.plants, family = "binomial"))
# Even though the results look a bit different, the inference is the same.

#######----------------- PART A2 -----------------########
cats <- read.csv("../caterpillars(3).csv")

head(cats)

## Write JAGS code
sink("JAGS_cats.R")
cat("
    model{
    # Process model
    for(i in 1:n.obs) {
    log(lambda[i]) <- b0 + b1*size[i] + b2*diet[i] + b3*size[i]*diet[i]
    abundance[i] ~ dpois(lambda[i])
    }
    # Priors
    b0 ~ dnorm(0, 0.001)
    b1 ~ dnorm(0, 0.001)
    b2 ~ dnorm(0, 0.001)
    b3 ~ dnorm(0, 0.001)
    }
    ") ; sink()

## Get data ready for JAGS  <-  needs to be a list
jags.cats <- list(
  abundance = cats$Abundance,
  size = cats$SizeHa,
  diet = (cats$Diet == "Specialist")*1,
  n.obs = length(cats$ForestName)
  )

## Run the JAGS code
model.cats <- jags(data = jags.cats, 
                    parameters.to.save = c("b0","b1","b2","b3"),
                    model.file = "JAGS_cats.R",
                    n.chains = 3,
                    n.iter = 10000,
                    n.burnin = 2000,
                    n.thin = 10)
model.cats

## And here is the MLE version:
summary(glm(abundance ~ size + diet + size*diet, family = "poisson", data = jags.cats))
# Note again that the results are similar but not identical. For one, it's clear that
# these data are over-dispersed and so a Poisson isn't a great fit for the data,
# and that a negative binomial would be a better fit.
# Note also that JAGS has trouble with estimating very small parameterrs (e.g., b1)
# Which is why it's *always* good to center and standardize your independent variables
# in order to encourage fitting.

#######----------------- PART B1 -----------------########
bbwo <- read.csv("../homeranges(1).csv")

head(bbwo)
plot(bbwo$Snag_density, bbwo$Home_range, pch = 16)

## Write JAGS code
sink("JAGS_bbwo1.R")
cat("
    model{
    # Process model
    for(i in 1:n.obs) {
    mu[i] <- b0 + b1*snag[i]
    hr[i] ~ dlnorm(mu[i], tau)
    }
    # Priors
    b0 ~ dnorm(0, 0.001)
    b1 ~ dnorm(0, 0.001)
    tau ~ dgamma(0.001, 0.001)
    sigma <- 1/sqrt(tau)
    }
    ") ; sink()

## Get data ready for JAGS  <-  needs to be a list
jags.bbwo <- list(
  hr = bbwo$Home_range,
  snag = bbwo$Snag_density,
  n.obs = length(bbwo$Home_range)
  )

## Run the JAGS code
model.bbwo1 <- jags(data = jags.bbwo, 
                    parameters.to.save = c("b0","b1","sigma"),
                    model.file = "JAGS_bbwo1.R",
                    n.chains = 3,
                    n.iter = 10000,
                    n.burnin = 2000,
                    n.thin = 10)
model.bbwo1
# b1 is really not telling us very much with just these data points alone

## Plot the relationship
plot(bbwo$Snag_density, bbwo$Home_range, pch = 16)
x.lin <- 0:50
y.post <- exp(model.bbwo1$BUGSoutput$mean$b0 + model.bbwo1$BUGSoutput$mean$b1*x.lin)
lines(x.lin, y.post, col = "red")

#### NOTE: there are many ways to parameterize a log-normal. The following works just the same:

## Write JAGS code
sink("JAGS_bbwo1b.R")
cat("
    model{
    # Process model
    for(i in 1:n.obs) {
    mu[i] <- b0 + b1*snag[i]
    log.hr[i] ~ dnorm(mu[i],tau)
    }
    # Priors
    b0 ~ dnorm(0, 0.001)
    b1 ~ dnorm(0, 0.001)
    tau ~ dgamma(0.001, 0.001)
    sigma <- 1/sqrt(tau)
    }
    ") ; sink()
jags.bbwo2 <- list(
  log.hr = log(bbwo$Home_range), # notice here that we are logging our response variable
  snag = bbwo$Snag_density,
  n.obs = length(bbwo$Home_range)
)
model.bbwo1b <- jags(data = jags.bbwo2, 
                    parameters.to.save = c("b0","b1","sigma"),
                    model.file = "JAGS_bbwo1b.R",
                    n.chains = 3,
                    n.iter = 10000,
                    n.burnin = 2000,
                    n.thin = 10)
model.bbwo1b
# Notice that the betas are the same, but the tau is different. Why?


#######----------------- PART B2 -----------------########

## Write JAGS code
sink("JAGS_bbwo2.R")
cat("
    model{
    # Process model
    for(i in 1:n.obs) {
    mu[i] <- b0 + b1*snag[i]
    hr[i] ~ dlnorm(mu[i], tau)
    }
    # Priors
    b0 ~ dnorm(4.23, 1/(0.24^2))
    b1 ~ dnorm(-0.59, 1/(0.16^2))
    tau ~ dgamma(0.001, 0.001)
    sigma <- 1/sqrt(tau)
    }
    ") ; sink()

## Run the JAGS code
model.bbwo2 <- jags(data = jags.bbwo, 
                    parameters.to.save = c("b0","b1","sigma"),
                    model.file = "JAGS_bbwo2.R",
                    n.chains = 3,
                    n.iter = 10000,
                    n.burnin = 2000,
                    n.thin = 10)
model.bbwo2
# Notice that our estimates have changed and our sd of b1 has reduced, but that 
# it has all been pulled in toward the prior

#######----------------- PART B3 -----------------########
## Plot the relationship
y.post2 <- exp(model.bbwo2$BUGSoutput$mean$b0 + model.bbwo2$BUGSoutput$mean$b1*x.lin) # mean line
# 95% credible intervals
mod1.post <- array(dim = c(length(model.bbwo1$BUGSoutput$sims.list$b0), length(x.lin)))
mod2.post <- array(dim = c(length(model.bbwo2$BUGSoutput$sims.list$b0), length(x.lin)))
for(i in 1:length(x.lin)) {
  mod1.post[,i] <- exp(model.bbwo1$BUGSoutput$sims.list$b0 + model.bbwo1$BUGSoutput$sims.list$b1*x.lin[i])
  mod2.post[,i] <- exp(model.bbwo2$BUGSoutput$sims.list$b0 + model.bbwo2$BUGSoutput$sims.list$b1*x.lin[i])
}
mod1.quant <- apply(mod1.post, 2, quantile, probs = c(0.025, 0.975))
mod2.quant <- apply(mod2.post, 2, quantile, probs = c(0.025, 0.975))

# Plotting together
# Red CI and line = model with only the 10 points
# Blue CI and line = model with informed priors
plot(bbwo$Snag_density, bbwo$Home_range, pch = 16, 
     xlim = c(0, 50), xlab = "Snag density", ylab = "Home range size (ha)")
polygon(x = c(x.lin, rev(x.lin)), 
        y = c(mod1.quant[1, ], rev(mod1.quant[2, ])), 
        col = "#FF000020", border = NA)
polygon(x = c(x.lin, rev(x.lin)), 
        y = c(mod2.quant[1, ], rev(mod2.quant[2, ])), 
        col = "#0000FF20", border = NA)
lines(x.lin, y.post, col = "red")
lines(x.lin, y.post2, col = "blue")

## Plotting posterior probabilities for b1
plot(0,0,type = "n", xlim = c(-1,0.2), ylim = c(0, 25), xlab = "b1", ylab = "[b1]")
lines(density(model.bbwo1$BUGSoutput$sims.list$b1), col = "red", lwd = 3) # Model 1
lines(density(model.bbwo2$BUGSoutput$sims.list$b1), col = "blue", lwd = 3) # Model 2
x.seq <- seq(-1, 0.2, by = 0.001)
lines(x.seq, dnorm(x.seq, mean = -0.59, sd = 0.16), col = "green", lwd = 3) # informed prior

# What's going on here? The new data do not appear to have a slope that is very similar to 
# the previous data. The posterior mean for model 2 is pulled a bit to the left by the prior,
# but you can see that the posterior for model 2 is still very different than the prior.
# Also, it's intersting that the posterior for model 2 is far more certain than for model 1.
# This probably has to do with the fact that the informed prior for the intercept is actually
# supported in model 2, so model 2 has a better idea of what the true intercept is, so with this
# extra knowledge, it does a better job at modeling the slope.
