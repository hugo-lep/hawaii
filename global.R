# Data for all sessions  ---------------------------------------------------------
# * ------ library --------------------------------------------------------
print("global.R")
library(here)
library(readr)
library(shiny)

#tidyverse
#library(tidyr)
#library(purrr)

#library(dplyr)
#library(stringr)

#shiny
library(bslib)
#library(shinyjs)
#library(shinyWidgets)
#perso
library(s3db)
#renv::install("hugo-lep/obsidianR")
library(obsidianR)
library(protegR2)

#autre
#library(uuid)
#library(sodium)
#library(cookies)
#library(glue)


addResourcePath("images", "inst/app/www")

sessions <- new.env(parent = emptyenv())

# * ------ AWS connect + load config --------------------------------------
config_s3_location <- read_rds("inst/app/data/config_s3_location.rds")
config_s3_access <- read_rds("inst/app/data/config_s3_access.rds")


s3_connection_HL()
config_global <- s3readRDS_HL(object = "config_files/config_global.rds")


# ── Overrides locaux de config_global ─────────────────────────────────────
# Ces lignes surchargent les valeurs lues depuis S3 sans modifier le fichier S3.
# Pratique pour tester localement des options avant de les pousser sur S3.
# Toutes sont optionnelles — commenter celles qui ne sont pas utiles.

# ── Test local : simuler un host restreint ─────────────────────────────────
# Décommenter pour tester le contrôle d'accès dev_access en local (127.0.0.1).
# En production, c'est l'URL réelle du navigateur qui est utilisée.
# NE JAMAIS laisser décommenté sur le serveur.
# config_global$protegR2$security$override_host <- "pascan-dev.avnumbers.ca"

