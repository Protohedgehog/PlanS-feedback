##------------------------------------------------------------------------------##
##                         PIXELATING FEEDBACK ON PLAN S                        ##
##------------------------------------------------------------------------------##


## R version 3.5.3 (2019-03-11)

## Author: Lisa Hehnke (dataplanes.org | @DataPlanes)


#-------#
# Setup #
#-------#

# Install and load packages using pacman
if (!require("pacman")) install.packages("pacman")
library(pacman)

p_load(emo, extrafont, ggthemes, httr, maps, readxl, tidyverse)

# Download data from Zenodo
url <- "https://zenodo.org/record/3250081/files/Feedback%20on%20the%20draft%20implementation%20guidance%20of%20Plan%20S.xlsx"
GET(url, write_disk(tf <- tempfile(fileext = ".xlsx")))

# Import data
feedback_df <- read_excel(tf)


#-----------#
# Set theme #
#-----------#

map_theme <- ggthemes::theme_map() + 
  theme(legend.background = element_rect(fill = "#212121", colour = NA),
        legend.key = element_blank(),
        legend.position = c(0.05, 0.15),
        legend.text = element_text(colour = "#ffffff", size = 12),
        legend.title = element_text(colour = "#ffffff", size = 12),
        plot.background = element_rect(fill = "#212121", colour = NA), 
        plot.caption = element_text(colour = "#ffffff", size = 8, vjust = 5, hjust = 0.98),
        plot.margin = margin(12, 0, 0, 12),
        plot.subtitle = element_text(colour = "#ffffff", face = "plain", size = 12),
        text = element_text(family = "Lato", color = "green"),
        title = element_text(face = "bold", size = 18))


#-----------------#
# Feedback counts #
#-----------------#

counts <- feedback_df %>%
  rename(country = `Where are you based?`) %>%
  select(country) %>%
  na.omit() %>%
  count(country, sort = TRUE) %>%
  rename(feedback_count = n) %>% 
  ungroup() %>%
  mutate(country = gsub("United States", "USA", country), 
         country = gsub("United Kingdom", "UK:Great Britain", country))


#------------------#
# Create dot frame #
#------------------#

## Credits for the original approach go to Taras Kaduk (https://taraskaduk.com/2017/11/26/pixel-maps/).

resolution <- 3
lat <- tibble(lat = seq(-90, 90, by = resolution))
long <- tibble(long = seq(-180, 180, by = resolution))

dots <- merge(lat, long, all = TRUE) %>%
  mutate(country = maps::map.where("world", long, lat),
         lakes = maps::map.where("lakes", long, lat)) %>% 
  filter(!is.na(country) & is.na(lakes)) %>%
  select(-lakes) %>%
  left_join(counts, by = "country") %>%
  mutate(feedback_count = replace_na(feedback_count, 0)) %>%
  add_row(lat = 54, long = 0, country = "Netherlands", feedback_count = 72) # manually add Netherlands


#----------------#
# Plot pixel map #
#----------------#

## Design inspired by Ilja Sperling (https://dadascience.design/post/r-pixel-symbol-map-magic-with-ggplot/).

ggplot() +
  geom_point(data = dots, aes(x = long, y = lat), color = "black", size = 1) + 
  geom_point(data = dots %>% filter(feedback_count >= 1), aes(x = long, y = lat, color = feedback_count), size = 1) + 
  coord_sf(datum = NA, crs = 54009, clip = "on", ylim = c(-50, 90), xlim = c(-160, 170)) +
  scale_color_gradient("Count", low = "darkgreen", high = "green", breaks = c(0, 20, 40, 60)) +
  labs(title = str_c("Public feedback on Plan S ", emo::ji("unlock")),
       subtitle = str_c("Made with ", emo::ji("pencil"), " from zenodo.org"), 
       caption = "@DataPlanes") +
  map_theme + guides(colour = guide_legend(keywidth = 0.15, keyheight = 0.15, default.unit = "inch", 
                                           override.aes = list(shape = 19)))
