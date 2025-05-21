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
mint_plus2 <- "#1f4b52"
rot1 <- "#a21628"
swiss_red <- "#D52B1E"
dark_grey <- "#444444"
bl_grau <- "#808080"
rot0 <- "#cb1c32"

p <- ggplot(df, aes(x = x, y = y)) +
  geom_line(color = mint_plus2, linewidth = 1) +                               # Normal distribution curve
  annotate("segment", x = lower_limit, xend = lower_limit, y = 0, yend = 0.15,  # Shortened lower limit line
           color = rot0, linewidth = 1.2) +
  annotate("segment", x = upper_limit, xend = upper_limit, y = 0, yend = 0.15,  # Shortened upper limit line
           color = rot0, linewidth = 1.2) +
  geom_ribbon(aes(ymin = 0, ymax = ifelse(x >= lower_limit & x <= upper_limit, y, NA)), fill = rot0, alpha = 0.2) +
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

# Load fonts
# curl issues do not allow fetching font from internet
# Download then fetch locally
font_add(family = "Roboto", regular = "~/_home/.coderbar/Roboto-Regular.ttf")
font_add(family = "Montserrat", regular = "~/_home/.coderbar/Montserrat-Regular.ttf")
font_add(family = "Montserrat Semi", regular = "~/_home//.coderbar/Montserrat-SemiBold.ttf")
showtext_auto()

sticker(
  p,                               # Plot to display
  package = "chensus",             # Text label for the package name
  p_size = 24,                     # Larger package name font size
  p_y = 1.3,
  p_color = rot0,             # Package name color
  s_x = 1,                        # Plot x position (unchanged)
  s_y = 0.7,                      # Plot y position (unchanged)
  s_width = 1.1,                  # Smaller plot width (down from 1.4)
  s_height = 0.9,                 # Smaller plot height (down from 1.2)
  h_fill = "#FFFFFF",             # Background color
  h_color = mint_plus2,           # Border color
  h_size = 3,                    # Thicker border (up from 2)
  filename = "man/figures/logo.png",
  p_family = "Montserrat Semi"            # Optional font family
)

