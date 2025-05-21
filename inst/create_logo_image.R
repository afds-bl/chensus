# Create a package hex sticker
pacman::p_load(hexSticker, magick, showtext, ggpubr, ggplot2)

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
mint_1 <- "#317883"
mint_1 <- "#77b6bf"
rot1 <- "#a21628"

p <- ggplot(df, aes(x = x, y = y)) +
  geom_line(color = mint_1, linewidth = 1) +                               # Normal distribution curve
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

# Create and save sticker
hexSticker::sticker(
  subplot = p,
  package = "chensus",
  p_size = 20,
  p_color = "white",
  p_x = .8,
  p_y = 1.35,
  s_x = 0.5,
  s_y = 1.25,
  s_width = 3.3,
  s_height = 3.6,
  h_fill = "#004774",
  h_color = "#c0c0c0",
  h_size = 2.3,
  white_around_sticker = TRUE,
  spotlight = FALSE,
  l_x = 0.75,
  l_y = 1.25,
  l_alpha = .8,
  l_width = 4,
  # p_family = "inter",

  filename = "man/figures/logo_white.png"
)

# Load fonts
# curl issues do not allow fetching font from internet
# Download then fetch locally
font_add(family = "Roboto", regular = "~/_home/.coderbar/Roboto-Regular.ttf")
# font_add_google("Roboto", "roboto") 
showtext_auto()

# Create the sticker
sticker(
  p,                               # Plot to display
  package = "chensus",        # Text label for the package name
  p_size = 20,                     # Package name font size
  p_color = "#cb1c32",             # Package name color (matching the red color in the plot)
  s_x = 1,                         # Position of the plot on the x-axis
  s_y = 0.8,                       # Position of the plot on the y-axis
  s_width = 1.4,                   # Width of the plot
  s_height = 1.2,                  # Height of the plot
  h_fill = "#e6f2f2",              # Background color of the hex
  h_color = mint_1,             # Border color of the hex
  h_size = 2,
  filename = "man/figures/logo_white.png"
  # p_family = "roboto"              # Font family for the package name
)

