x1 <- matrix(c(0, 400000), ncol = 2)
x2 <- matrix(unlist(c(x = c(0, 490000, 123456), y = c(400000, 0, 123456))), ncol = 2)


xe1 <- matrix(0, 500000)


test_that("basic generations", {
  expect_equal(ig_to_igr(x1), c("A000000"))
  expect_equal(ig_to_igr(x2), c("A000000", "Z900000", "R234234"))
})

test_that("all resolutions 100km > 1m", {
  expect_equal(ig_to_igr(x1, precision = 100000), c("A"))
  expect_equal(ig_to_igr(x1, precision = 10000), c("A00"))
  expect_equal(ig_to_igr(x1, precision = 2000), c("A00A"))
  expect_equal(ig_to_igr(x1, precision = 1000), c("A0000"))
  expect_equal(ig_to_igr(x1, precision = 100), c("A000000"))
  expect_equal(ig_to_igr(x1, precision = 10), c("A00000000"))
  expect_equal(ig_to_igr(x1, precision = 1), c("A0000000000"))

  expect_equal(ig_to_igr(x2, precision = 100000), c("A", "Z", "R"))
  expect_equal(ig_to_igr(x2, precision = 2000), c("A00A", "Z90A", "R22G"))
  expect_equal(ig_to_igr(x2, precision = 1), c("A0000000000", "Z9000000000", "R2345623456"))
})

test_that("x and y Irish Grid coordinates", {
  expect_error(ig_to_igr(matrix(1)), class = "not_x_y")
})

test_that("sep", {
  expect_equal(ig_to_igr(x1, sep = " "), c("A 000 000"))
  expect_equal(ig_to_igr(x2, sep = "---"), c("A---000---000", "Z---900---000", "R---234---234"))
  expect_equal(ig_to_igr(x2, precision = 2000, sep = "-"), c("A-0-0-A", "Z-9-0-A", "R-2-2-G"))
})

test_that("numeric x and y", {
  expect_error(ig_to_igr(matrix(c("a", 0), ncol = 2), class = "non_numeric_x_y"))
  expect_error(ig_to_igr(matrix(c(0, "qqq"), ncol = 2), class = "non_numeric_x_y"))
})

test_that("Warning for invalid Irish Grid coordinates", {
  expect_warning(ig_to_igr(matrix(c(0, -1), ncol = 2)), "-1")
  expect_warning(ig_to_igr(matrix(c(0, 500001), ncol = 2)), "500001")
  expect_warning(ig_to_igr(matrix(c(-1, 400000), ncol = 2)), "-1")
  expect_warning(ig_to_igr(matrix(unlist(c(x = c(0, 0, 0), y = c(1, -1, 699999))), ncol = 2)), "-1.*699999")
})

test_that("invalid digits detected", {
  expect_error(ig_to_igr(matrix(c(0, 1), ncol = 2), digits = -1), class = "unsupported_digits")
  expect_error(ig_to_igr(matrix(c(0, 1), ncol = 2), digits = 1.1), class = "unsupported_digits")
  expect_error(ig_to_igr(matrix(c(0, 1), ncol = 2), digits = 6), class = "unsupported_digits")
  expect_error(ig_to_igr(matrix(c(0, 1), ncol = 2), digits = "A"), class = "unsupported_digits")
})

test_that("invalid precision detected", {
  expect_error(ig_to_igr(matrix(c(0, 1), ncol = 2), precision = 0), class = "unsupported_precision")
  expect_error(ig_to_igr(matrix(c(0, 1), ncol = 2), precision = 2), class = "unsupported_precision")
  expect_error(ig_to_igr(matrix(c(0, 1), ncol = 2), precision = 5000), class = "unsupported_precision")
  expect_error(ig_to_igr(matrix(c(0, 1), ncol = 2), precision = "A"), class = "unsupported_precision")
})

test_that("no precision detected", {
  expect_error(ig_to_igr(x1, digits = NA, precision = NULL), class = "no_precision")
})