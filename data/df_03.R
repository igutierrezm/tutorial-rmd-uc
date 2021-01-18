# Reproduce data/df_03.rds

import::from(magrittr, "%>%", "%T>%")
options(survey.lonely.psu = "certainty")

df_03 <-
  list.files("data/ene", pattern = "*.rds", full.names = TRUE) %>%
  purrr::map(
    ~ readRDS(.x) %>%
      dplyr::rename_with(~ "conglomerado", dplyr::matches("id_directorio")) %>%
      dplyr::rename_with(~ "estrato",      dplyr::matches("estrato_unico")) %>%
      srvyr::as_survey(
        id      = conglomerado, 
        strata  = estrato, 
        weights = fact_cal
      ) %>%
      srvyr::group_by(ano_trimestre, mes_central, cae_general) %>%
      srvyr::summarise(ocupados = survey_total())
  ) %>%
  purrr::reduce(rbind) %T>%
  saveRDS("data/df_03.rds")