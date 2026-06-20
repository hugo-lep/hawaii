renv::install("hugo-lep/protegR2@dev")
renv::install("hugo-lep/utilsHL")
renv::install("hugo-lep/obsidianR")

library(protegR2)
protegR2_init()


renv::install("usethis")
library(usethis)
usethis::use_git()
renv::remove("bslibHL")
renv::snapshot()
use_github()

