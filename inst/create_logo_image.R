# Create a package hex sticker

library(ggpubr)
library(ggplot2)

# Set parameters for the normal distribution
mean <- 0       # Mean of the distribution
sd <- 1         # Standard deviation of the distribution
alpha <- 0.05   # For a 95% confidence interval

# Calculate the z-score for a 95% confidence interval (two-tailed)
z <- qnorm(1 - alpha / 2)

# Lower and upper confidence interval limits
lower_limit <- - z
upper_limit <- z

# Create a data frame for the normal distribution
x_values <- seq(-3, 3, length.out = 1000)
y_values <- dnorm(x_values, mean, sd)
df <- data.frame(x = x_values, y = y_values)

# Normal distribution with confidence intervals
mint1 <- "#317883"
rot1 <- "#a21628"

p <- ggplot(df, aes(x = x, y = y)) +
  geom_line(color = mint1, linewidth = 1) +                               # Normal distribution curve
  annotate("segment", x = lower_limit, xend = lower_limit, y = 0, yend = 0.15,  # Shortened lower limit line
           color = rot1, linewidth = 1.2) +
  annotate("segment", x = upper_limit, xend = upper_limit, y = 0, yend = 0.15,  # Shortened upper limit line
           color = rot1, linewidth = 1.2) +
  geom_ribbon(aes(ymin = 0, ymax = ifelse(x >= lower_limit & x <= upper_limit, y, NA)), fill = rot1, alpha = 0.2) +
  ggpubr::theme_transparent() +
  theme(
    axis.title.y = element_blank(),    # Hide y-axis label
    axis.text.y = element_blank(),     # Hide y-axis text
    axis.ticks.y = element_blank(),
    axis.title.x = element_blank(),    # Hide x-axis label
    axis.text.x = element_blank(),     # Hide x-axis text
    axis.ticks.x = element_blank()
  )

ggsave("man/figures/dnorm.png")

