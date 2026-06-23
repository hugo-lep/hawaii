print("protegR2_load_modules_servers")

# ══════════════════════════════════════════════════════════════════════════════
# protegR2_load_modules_servers()
#
# Point d'entrée pour initialiser tous les modules Shiny côté serveur.
# Cette fonction est appelée par protegR2_server() juste après que l'utilisateur
# est authentifié.
#
# Paramètres :
#   sessions        — environnement global qui trace les sessions actives
#   input_main_app  — objet input de la session principale (passé depuis protegR2_server)
#   main_session    — objet session de la session principale
#
# Convention pour les modules de config : passer sessions, input_main_app et
# main_session à mod_config_server() afin qu'il puisse gérer les comptes,
# réinitialiser des mots de passe, etc.
# ══════════════════════════════════════════════════════════════════════════════

protegR2_load_modules_servers <- function(sessions,
                                          input_main_app,
                                          main_session) {


  # ── Modules principaux ─────────────────────────────────────────────────────

  voyage_data <- s3readRDS_HL("itinéraires/hawaii_2026.rds")
  mod_itinerary_server("hawaii_m", voyage_data)

  # ── Module de configuration ────────────────────────────────────────────────
  # Reçoit sessions et main_session pour gérer les utilisateurs et les rôles.

  mod_config_server("config",
                    sessions       = sessions,
                    input_main_app = input_main_app,
                    main_session   = main_session)

  # ── Modal de configuration — styles "sidebar", "fluid", "fixed", "fillable" ──
  #
  # ⚠️  SUPPRIMER CE BLOC si ton style est "navbar" ou "sidebarHL".
  #     Ces deux styles intègrent la configuration directement dans leur
  #     navigation (nav_menu() pour navbar, hl_nav_group() pour sidebarHL)
  #     et n'utilisent pas le bouton engrenage flottant (gear = FALSE).
  #
  #     Pour TOUS les autres styles (sidebar, fluid, fixed, fillable),
  #     garder ce bloc — il gère le clic sur le bouton ⚙ (gear = TRUE).
  #
  # Pourquoi un modal plutôt qu'un onglet dans la navigation principale ?
  #   Les styles sidebar/fluid/fixed/fillable n'ont pas de zone dédiée pour
  #   la configuration dans leur structure de navigation. Plutôt que d'ajouter
  #   des onglets de config au navset principal, on les isole dans un modal
  #   accessible via le bouton engrenage flottant (bas droite, inputId =
  #   "open_config_modal"). Le modal est reconstruit à chaque ouverture selon
  #   le rôle de l'utilisateur — il ne montre que les onglets accessibles.

  observeEvent(input_main_app$open_config_modal, {

    # ── Guard mode local ────────────────────────────────────────────────────
    # En mode local les mots de passe sont définis dans protegR2_local_users.R
    # et ne peuvent pas être modifiés via l'interface. Le bouton engrenage est
    # normalement masqué par gear = FALSE dans le template, mais ce guard évite
    # d'ouvrir un modal vide si le bouton était quand même déclenché.
    backend <- main_session$userData$config_global$protegR2$user_config_backend %||% "none"
    if (backend == "local") return()

    role <- main_session$userData$user_info$user_role()

    config_panels <- list(
      nav_panel(title = "Votre compte", value = "your_account", mod_config_ui1("config"))
    )
    if (role %in% c("admin", "super_admin", "dev")) {
      config_panels <- c(config_panels, list(
        nav_panel(title = "Administration", value = "admin_access", mod_config_ui2("config"))
      ))
    }
    if (role %in% c("super_admin", "dev")) {
      config_panels <- c(config_panels, list(
        nav_panel(title = "Super Admin", value = "super_admin_access", mod_config_ui3("config"))
      ))
    }
    if (role == "dev") {
      config_panels <- c(config_panels, list(
        nav_panel(title = "Dev", value = "dev_access", mod_config_ui4("config"))
      ))
    }

    showModal(modalDialog(
      title     = tagList(icon("gear"), " Configuration"),
      do.call(navset_tab, config_panels),
      size      = "l",
      easyClose = TRUE,
      footer    = modalButton("Fermer")
    ))
  })

}
