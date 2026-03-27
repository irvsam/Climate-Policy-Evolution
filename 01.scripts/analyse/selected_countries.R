library(sf)
library(rnaturalearth)
library(ggplot2)

map_df <- ghg_cumulative %>%
  left_join(ndgain_final_clean %>% filter(year == 2023), by = "iso3")

# Geographic Data
world <- ne_countries(scale = "medium", returnclass = "sf")
target_map <- world %>%
  inner_join(map_df, by = c("iso_a3" = "iso3")) %>%
  mutate(label_text = paste0(iso_a3, "\n", round(total_ghg, 0), " Mt"))


resilience_labeled_map <- ggplot(data = world) +
  geom_sf(fill = "grey95", color = "white") + # Background
  geom_sf(data = target_map, aes(fill = score), color = "black", size = 0.2) +
  
  # Add the Emissions Labels
  geom_text_repel(
    data = target_map,
    aes(label = label_text, geometry = geometry),
    stat = "sf_coordinates",
    size = 2.5,
    fontface = "bold",
    min.segment.length = 0, # Always draw a line if moved
    box.padding = 0.5
  ) +
  
  # Consistent Resilience Color Scale
  scale_fill_gradient(low = "#d35400", high = "#2980b9", 
                      name = "Resilience (ND-GAIN)") +
  
  theme_void() +
  labs(
    title = "Country Selection",
    subtitle = "Labels show Cumulative GHG Emissions (Mt CO2e) (2013-2023)",
  ) +
  theme(legend.position = "bottom")

print(resilience_labeled_map)
