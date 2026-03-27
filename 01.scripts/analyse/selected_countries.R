
world <- ne_countries(scale = "medium", returnclass = "sf")
map_df <- ghg_cumulative %>%
  left_join(ndgain_final_clean %>% filter(year == 2023), by = "iso3")

target_map <- world %>%
  inner_join(map_df, by = c("iso_a3" = "iso3")) %>%
  mutate(label_text = paste0(iso_a3, "\n", format(round(total_ghg, 0), big.mark=","), " Mt"))

# Create a specific coordinate for the Maldives point
mdv_coord <- data.frame(
  iso3 = "MDV", 
  lon = 73.5, 
  lat = 3.2
) %>%
  left_join(map_df, by = "iso3") %>%
  st_as_sf(coords = c("lon", "lat"), crs = 4326)

resilience_labeled_map <- ggplot(data = world) +
  geom_sf(fill = "grey95", color = "white") + 
  
  # Main Polygons
  geom_sf(data = target_map, aes(fill = score), color = "black", size = 0.2) +
  
  # Point overlay for Maldives (so the color is visible)
  geom_sf(data = mdv_coord, aes(color = score), size = 3, show.legend = FALSE) +
  geom_sf(data = mdv_coord, color = "black", size = 3, shape = 1, stroke = 0.5) +
  
  # White background behind text
  geom_label_repel(
    data = target_map,
    aes(label = label_text, geometry = geometry),
    stat = "sf_coordinates",
    size = 2.5,
    fontface = "bold",
    label.padding = unit(0.15, "lines"), # Tighten the box
    label.size = 0,                      # Remove the black border of the box
    fill = alpha("white", 0.7),          # Make the box semi-transparent
    min.segment.length = 0, 
    box.padding = 0.8,
    max.overlaps = Inf                   # Ensure all labels show up
  ) +
  
  # Consistent Resilience Color Scale for both points and polygons
  scale_fill_gradient(low = "#d35400", high = "#2980b9", 
                      name = "Resilience (ND-GAIN)") +
  scale_color_gradient(low = "#d35400", high = "#2980b9") +
  
  theme_void() +
  labs(
    title = "Selected Countries and their GHG Emissions (since 2013)",
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14),
    plot.margin = margin(10, 10, 10, 10)
  )

print(resilience_labeled_map)