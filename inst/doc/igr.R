## ----init, include = FALSE----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----load---------------------------------------------------------------------
library(igr)

## ----example-igr-valid--------------------------------------------------------
# Sample of valid and invalid Irish grid references
igrs <- c("A", "A16", "A123678", "BAD", "I12", "", "B125", "Z")

igr_is_valid(igrs)

## ----example-igr-1------------------------------------------------------------
igrs <- c("A", "D12", "J53", "M5090", "N876274", "S1234550000", "W")

igr_to_ig(igrs)

## ----example-igr-2------------------------------------------------------------
igrs <- c("A", "D 12", "J 5 3", "M 50 90", "N 876 274", "S 12345 50000", "W")

igr_to_ig(igrs)

## ----example-igr-res----------------------------------------------------------
igr_to_ig(igrs, precision = "prec")

## ----example-igr-poi----------------------------------------------------------
igr_df <- data.frame(igr = igrs)

points_sf <- st_igr_as_sf(igr_df, "igr")

points_sf

## ----example-igr-poi-plot, fig.height=4, message=FALSE, fig.alt="A map of Ireland with a dot at the south-west corner of each sample grid reference."----
if (requireNamespace("maps", quietly = TRUE) &
  requireNamespace("tmap", quietly = TRUE)) {
  library(maps)
  library(tmap)

  ie_uk_sf <- maps::map("world",
    regions = c("Ireland", "UK"),
    plot = FALSE,
    fill = TRUE
  ) |>
    sf::st_as_sf(ie_uk) |>
    sf::st_transform(29903)

  tm_shape(points_sf, ext = 1.4) +
    tm_dots(size = 1, col = "cornflowerblue") +
    tm_text("igr", ymod = 1) +
    tm_shape(ie_uk_sf) +
    tm_borders()
}

## ----example-igr-pol----------------------------------------------------------
polygons_sf <- st_igr_as_sf(igr_df, "igr", polygons = TRUE)

polygons_sf

## ----example-igr-pol-plot, fig.height=4, fig.alt="A map of Ireland with polygons spanning each sample grid reference. The polygons range in size from 100 km square to 1 m square."----
if (exists("ie_uk_sf")) {
  tm_shape(ie_uk_sf, bbox = points_sf, ext = 1.4) +
    tm_borders() +
    tm_shape(polygons_sf, ext = 1.2) +
    tm_polygons(size = 1, col = "cornflowerblue", alpha = 0.5) +
    tm_text("igr", ymod = -1)
}

## ----example-igr-avoid-baser--------------------------------------------------
some_invalid_df <- data.frame(igr = c(igrs, "BAD", "I", "", "123", "N1"))

some_invalid_df
valid_sf <- st_igr_as_sf(some_invalid_df[igr_is_valid(some_invalid_df$igr), , drop = FALSE])

valid_sf

## ----example-igr-avoid-tidyr, eval=FALSE--------------------------------------
#  valid_df <- some_invalid_df |>
#    dplyr::filter(igr_is_valid(igr)) |>
#    st_igr_as_sf()

## ----example-ig-1-------------------------------------------------------------
p <- matrix(c(0, 490000, 400000, 0, 453000, 4000), ncol = 2, byrow = TRUE)
colnames(p) <- c("x", "y")

p
ig_to_igr(p)

## ----example-ig-2-------------------------------------------------------------
ig_to_igr(p, sep = " ")

## ----example-ig-3-digits------------------------------------------------------
ig_to_igr(p, digits = 1) # 10 km precision

ig_to_igr(p, digits = 5) # 1 m precision

## ----example-ig-3-prevision---------------------------------------------------
ig_to_igr(p, precision = 10000) # 10 km precision

ig_to_igr(p, precision = 1) # 1 m precision

## ----example-ig-4-------------------------------------------------------------
p_df <- data.frame(p)

p_df
ig_to_igr(p_df)

## ----example-ig-5-------------------------------------------------------------
p_sf <- sf::st_as_sf(p_df,
  crs = 29903,
  coords = c("x", "y")
)

p_sf
st_irishgridrefs(p_sf)

## ----example-ig-6-------------------------------------------------------------
p_sf$igr <- st_irishgridrefs(p_sf, sep = " ")

p_sf

## ----example-ig-7, eval = FALSE-----------------------------------------------
#  p_sf <- p_sf |>
#    dplyr::mutate(igr = st_irishgridrefs(sep = " "))

