## ----init, include = FALSE----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----load---------------------------------------------------------------------
library(igr)

## ----example-igr-valid--------------------------------------------------------
# Sample of valid and invalid Irish grid references
igrs <- c("A", "A16", "A123678", "BAD", "I12", "", "B125", "Z", "N12D")

igr_is_valid(igrs)

## ----example-igr-1------------------------------------------------------------
igrs <- c("A", "D12", "J53", "M5090", "N876274", "S1234550000", "R10H", "X")

igr_to_ig(igrs)

## ----example-igr-1a-----------------------------------------------------------
igr_to_ig(igrs, centroids = TRUE)

## ----example-igr-2------------------------------------------------------------
ws_igrs <- c("A", "D 12", "J 5 3", "M 50 90", "N 876 274", "S 12345 50000", "R10 H", "X")

igr_to_ig(ws_igrs)

## ----example-igr-res----------------------------------------------------------
igr_to_ig(igrs, precision = "prec")

## ----example-igr-poi----------------------------------------------------------
igr_df <- data.frame(igr = igrs)

points_sf <- st_igr_as_sf(igr_df, "igr")

points_sf

## ----example-igr-poi-plot, fig.height=4, message=FALSE, fig.alt="A map of Ireland with a dot at the south west corner of each sample grid reference."----
if (requireNamespace("maps", quietly = TRUE) &
  requireNamespace("tmap", quietly = TRUE) &
  requireNamespace("units", quietly = TRUE)) {
  library(maps)
  library(tmap)
  library(units)

  ie_uk_sf <- maps::map("world",
    regions = c("Ireland", "UK"),
    plot = FALSE,
    fill = TRUE
  ) |>
    sf::st_as_sf(ie_uk) |>
    sf::st_transform(29903)

  if (packageVersion("tmap") > "3.99") {
    tm_shape(points_sf, ext = 1.4) +
      tm_dots(size = 1, fill = "cornflowerblue") +
      tm_text("igr", ymod = 1) +
      tm_shape(ie_uk_sf) +
      tm_borders()
  } else {
    tm_shape(points_sf, ext = 1.4) +
      tm_dots(size = 1, col = "cornflowerblue") +
      tm_text("igr", ymod = 1) +
      tm_shape(ie_uk_sf) +
      tm_borders()
  }
}

## ----example-igr-pol----------------------------------------------------------
polygons_sf <- st_igr_as_sf(igr_df, "igr", polygons = TRUE)

polygons_sf

## ----example-igr-pol-plot, fig.height=4, fig.alt="A map of Ireland with polygons spanning each sample grid reference. The polygons range in size from 100 km square to 1 m square."----
if (exists("ie_uk_sf")) {
  # identify small polygons requiring highlighting
  polygons_sf$area <- sf::st_area(polygons_sf)
  small_polygons_sf <- polygons_sf[polygons_sf$area <= units::set_units(5000000, m^2), ]

  if (packageVersion("tmap") > "3.99") {
    tm_shape(ie_uk_sf, bbox = points_sf, ext = 1.4) +
      tm_borders() +
      tm_shape(polygons_sf) +
      tm_polygons(size = 1, fill = "cornflowerblue", fill_alpha = 0.5) +
      tm_text("igr", ymod = -1) +
      tm_shape(small_polygons_sf) +
      tm_bubbles(
        fill_alpha = 0, col = "orangered", lwd = 2,
        size = 0.8
      )
  } else {
    tm_shape(ie_uk_sf, bbox = points_sf, ext = 1.4) +
      tm_borders() +
      tm_shape(polygons_sf) +
      tm_polygons(size = 1, col = "cornflowerblue", alpha = 0.5) +
      tm_text("igr", ymod = -1) +
      tm_shape(small_polygons_sf) +
      tm_bubbles(
        alpha = 0, border.col = "orangered", border.lwd = 2,
        size = 0.8
      )
  }
}

## ----example-igr-avoid-baser--------------------------------------------------
some_invalid_df <- data.frame(igr = c(igrs, "BAD", "I", "", "123", "N1"))

some_invalid_df
valid_sf <- st_igr_as_sf(some_invalid_df[igr_is_valid(some_invalid_df$igr), , drop = FALSE])

valid_sf

## ----example-igr-avoid-tidyr, eval=FALSE--------------------------------------
#  valid_sf <- some_invalid_df |>
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

ig_to_igr(p, precision = 2000) # 2 km precision - tetrad form

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

