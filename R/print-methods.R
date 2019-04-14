#' @importFrom insight print_color
#' @export
print.looic <- function(x, digits = 2, ...) {
  insight::print_color("# LOOIC and ELPD with Standard Error\n\n", "blue")

  out <- paste0(c(
    sprintf("  LOOIC: %.*f [%.*f]", digits, x$LOOIC, digits, x$LOOIC_SE),
    sprintf("   ELPD: %.*f [%.*f]", digits, x$ELPD, digits, x$ELPD_SE)),
    collapse = "\n"
  )

  cat(out)
  cat("\n")
}



#' @importFrom insight print_color
#' @export
print.r2_lm <- function(x, digits = 3, ...) {
  insight::print_color("# R2 for linear models\n\n", "blue")

  out <- paste0(c(
    sprintf("       R2: %.*f", digits, x$R2),
    sprintf("  adj. R2: %.*f", digits, x$R2_adjusted)),
    collapse = "\n"
  )

  cat(out)
  cat("\n")
}



#' @importFrom insight print_color
#' @export
print.r2_nakagawa <- function(x, digits = 3, ...) {
  insight::print_color("# R2 for mixed models\n\n", "blue")

  out <- paste0(c(
    sprintf("  Conditional R2: %.*f", digits, x$R2_conditional),
    sprintf("     Marginal R2: %.*f", digits, x$R2_marginal)),
    collapse = "\n"
  )

  cat(out)
  cat("\n")
}



#' @importFrom insight print_color
#' @export
print.r2_bayes <- function(x, digits = 3, ...) {
  insight::print_color("# Bayesian R2 with Standard Error\n\n", "blue")

  out <- sprintf("  Conditional R2: %.*f [%.*f]", digits, x$R2_Bayes, digits, attr(x, "std.error")[["R2_Bayes"]])

  if ("R2_Bayes_marginal" %in% names(x)) {
    out <- paste0(c(out,  sprintf("     Marginal R2: %.*f [%.*f]", digits, x$R2_Bayes_marginal, digits, attr(x, "std.error")[["R2_Bayes_marginal"]])), collapse = "\n")
  }

  cat(out)
  cat("\n")
}



#' @export
print.perf_pca_rotate <- function(x, cutoff = 0.1, digits = 3, ...) {

  insight::print_color(sprintf("# Rotated loadings from Principal Component Analysis (%s-rotation)\n\n", attr(x, "rotation", exact = TRUE)), "blue")

  xs <- attr(x, "variance", exact = TRUE)
  x <- round(x, digits = digits)

  x <- as.data.frame(apply(x, MARGIN = c(1, 2), function(.y) {
    if (abs(.y) < cutoff)
      ""
    else
      as.character(.y)
  }), stringsAsFactors = FALSE)

  xs <- as.data.frame(t(as.data.frame(round(xs, digits = digits))))

  colnames(xs) <- sprintf("PC%i", 1:ncol(xs))
  rownames(xs) <- c("Proportion variance", "Cumulative variance", "Proportion explained", "Cumulative explained")

  print(x, quote = FALSE, ...)
  insight::print_color("\n(Explained) Variance\n", "cyan")
  print(xs, ...)
}



#' @export
print.perf_pca <- function(x, digits = 3, ...) {
  x <- as.data.frame(round(x, digits = digits))
  rownames(x) <- c("Standard deviation", "Eigenvalue", "Proportion variance", "Cumulative variance")
  print(x, ...)
}



#' @importFrom insight print_color
#' @export
print.icc <- function(x, digits = 3, ...) {
  insight::print_color("# Intraclass Correlation Coefficient\n\n", "blue")

  out <- paste0(c(
    sprintf("     Adjusted ICC: %.*f", digits, x$ICC_adjusted),
    sprintf("  Conditional ICC: %.*f", digits, x$ICC_conditional)),
    collapse = "\n"
  )

  cat(out)
  cat("\n")
}



#' @importFrom insight print_color
#' @export
print.check_zi <- function(x, ...) {
  insight::print_color("# Check for zero-inflation\n\n", "blue")
  cat(sprintf("   Observed zeros: %i\n", x$observed.zeros))
  cat(sprintf("  Predicted zeros: %i\n", x$predicted.zeros))
  cat(sprintf("            Ratio: %.2f\n\n", x$ratio))

  lower <- 1 - x$tolerance
  upper <- 1 + x$tolerance

  if (x$ratio < lower)
    message("Model is underfitting zeros (probable zero-inflation).")
  else if (x$ratio > upper)
    message("Model is overfitting zeros.")
  else
    message("Model seems ok, ratio of observed and predicted zeros is within the tolerance range.")
}



#' @export
print.check_overdisp <- function(x, digits = 3, ...) {
  x$dispersion_ratio <- sprintf("%.*f", digits, x$dispersion_ratio)
  x$chisq_statistic <- sprintf("%.*f", digits, x$chisq_statistic)

  x$p_value <- pval <- round(x$p_value, digits = digits)
  if (x$p_value < .001) x$p_value <- "< 0.001"

  maxlen <- max(
    nchar(x$dispersion_ratio),
    nchar(x$chisq_statistic),
    nchar(x$p_value)
  )

  insight::print_color("# Overdispersion test\n\n", "blue")
  cat(sprintf("       dispersion ratio = %s\n", format(x$dispersion_ratio, justify = "right", width = maxlen)))
  cat(sprintf("  Pearson's Chi-Squared = %s\n", format(x$chisq_statistic, justify = "right", width = maxlen)))
  cat(sprintf("                p-value = %s\n\n", format(x$p_value, justify = "right", width = maxlen)))

  if (pval > 0.05)
    message("No overdispersion detected.")
  else
    message("Overdispersion detected.")
}



#' @importFrom insight print_color
#' @export
print.icc_decomposed <- function(x, digits = 2, ...) {
  # print model information
  cat("# Random Effect Variances and ICC\n\n")

  reform <- attr(x, "re.form", exact = TRUE)
  if (is.null(reform))
    reform <- "all random effects"
  else
    reform <- deparse(reform)

  cat(sprintf("Conditioned on: %s\n\n", reform))

  prob <- attr(x, "ci", exact = TRUE)

  cat(insight::print_color("## Variance Ratio (comparable to ICC)\n", "blue"))

  icc.val <- sprintf("%.*f", digits, x$ICC_decomposed)

  ci.icc.lo <- sprintf("%.*f", digits, x$ICC_CI[1])
  ci.icc.hi <- sprintf("%.*f", digits, x$ICC_CI[2])

  # ICC
  cat(sprintf(
    "Ratio: %s  CI %i%%: [%s %s]\n",
    icc.val,
    as.integer(round(prob * 100)),
    ci.icc.lo,
    ci.icc.hi
  ))

  cat(insight::print_color("\n## Variances of Posterior Predicted Distribution\n", "blue"))

  null.model <- sprintf("%.*f", digits, attr(x, "var_rand_intercept", exact = TRUE))

  ci.null <- attr(x, "ci.var_rand_intercept", exact = TRUE)
  ci.null.lo <- sprintf("%.*f", digits, ci.null$CI_low)
  ci.null.hi <- sprintf("%.*f", digits, ci.null$CI_high)

  full.model <- sprintf("%.*f", digits, attr(x, "var_total", exact = TRUE))

  ci.full <- attr(x, "ci.var_total", exact = TRUE)
  ci.full.lo <- sprintf("%.*f", digits, ci.full$CI_low)
  ci.full.hi <- sprintf("%.*f", digits, ci.full$CI_high)

  ml <- max(nchar(null.model), nchar(full.model))
  ml.ci <- max(nchar(ci.full.lo), nchar(ci.null.lo))
  mh.ci <- max(nchar(ci.full.hi), nchar(ci.null.hi))

  # Conditioned on fixed effects
  cat(sprintf(
    "Conditioned on fixed effects: %*s  CI %i%%: [%*s %*s]\n",
    ml,
    null.model,
    as.integer(round(prob * 100)),
    ml.ci,
    ci.null.lo,
    mh.ci,
    ci.null.hi
  ))

  # Conditioned on random effects
  cat(sprintf(
    "Conditioned on rand. effects: %*s  CI %i%%: [%*s %*s]\n",
    ml,
    full.model,
    as.integer(round(prob * 100)),
    ml.ci,
    ci.full.lo,
    mh.ci,
    ci.full.hi
  ))

  cat(insight::print_color("\n## Difference in Variances\n", "red"))

  res <- sprintf("%.*f", digits, attr(x, "var_residual", exact = TRUE))

  ci.res <- attr(x, "ci.var_residual", exact = TRUE)
  ci.res.lo <- sprintf("%.*f", digits, ci.res$CI_low)
  ci.res.hi <- sprintf("%.*f", digits, ci.res$CI_high)

  # ICC
  cat(sprintf(
    "Difference: %s  CI %i%%: [%s %s]\n",
    res,
    as.integer(round(prob * 100)),
    ci.res.lo,
    ci.res.hi
  ))
}