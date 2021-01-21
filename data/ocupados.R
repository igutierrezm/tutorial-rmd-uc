# Reproduce data/ocupados.rds

import::from(haven, labelled)
import::from(magrittr, "%>%", "%T>%")
options(survey.lonely.psu = "certainty")

ocupados <-
  list.files("data/ene", pattern = "*.rds", full.names = TRUE) %>%
  purrr::map(
    ~ readRDS(.x) %>%
      dplyr::rename_with(~ "conglomerado", dplyr::matches("id_directorio")) %>%
      dplyr::rename_with(~ "estrato",      dplyr::matches("estrato_unico")) %>%
      dplyr::mutate(
        trimestre_movil = lubridate::my(paste(mes_central, ano_trimestre)),
        ocupado = cae_general %in% 1:3 # (dummy) 1 si está ocupado
      ) %>%
      srvyr::as_survey(
        id      = conglomerado,
        strata  = estrato,
        weights = fact_cal
      ) %>%
      srvyr::group_by(trimestre_movil) %>%
      srvyr::summarise(coef = srvyr::survey_total(ocupado)) %>%
      dplyr::ungroup()
  ) %>%
  purrr::reduce(rbind) #%T>%
  # saveRDS("data/ocupados.rds")
