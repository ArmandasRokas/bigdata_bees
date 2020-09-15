library(purrr)

x <- data.frame(a = c(1:10),
            b = c(seq(100, 140, 10), rep(NA_real_, 5)) )
x
fill_in <- function(prev, new, growth = 0.03) {
  if_else(!is.na(new), new, prev * (1 + growth))
}

#options(pillar.sigfig = 5)

x %>%
  mutate(b = accumulate(b, fill_in))



my <- data.frame(a = c(10,11,10,11), b = c(0,3,3,4))
fill_in <- function(prev, new, deltas) {
  #if_else(!is.na(new), new, prev * (1 + growth))
  prev+deltas
}

my %>%
  mutate(a = accumulate(a, fill_in,b ))
?accumulate
