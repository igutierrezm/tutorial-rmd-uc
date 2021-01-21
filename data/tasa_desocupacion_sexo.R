# Reproduce data/tasa_desocupacion_sexo.rds

import::from(haven, labelled)
import::from(magrittr, "%>%", "%T>%")
options(survey.lonely.psu = "certainty")

tasa_desocupacion_sexo <-
  list.files("data/ene", pattern = "*.rds", full.names = TRUE) %>%
  purrr::map(
    ~ readRDS(.x) %>%
      dplyr::rename_with(~ "conglomerado", dplyr::matches("id_directorio")) %>%
      dplyr::rename_with(~ "estrato",      dplyr::matches("estrato_unico")) %>%
      dplyr::mutate(
        trimestre_movil = lubridate::my(paste(mes_central, ano_trimestre)),
        de = cae_general %in% 4:5, # (dummy) 1 si está desocupado
        ft = cae_general %in% 1:5  # (dummy) 1 si está en la fuerza de trabajo
      ) %>%
      srvyr::as_survey(
        id      = conglomerado, 
        strata  = estrato, 
        weights = fact_cal
      ) %>%
      srvyr::group_by(trimestre_movil, sexo) %>%
      srvyr::summarise(coef = 100 * srvyr::survey_ratio(de, ft))
  ) %>%
  purrr::reduce(rbind) %T>%
  saveRDS("data/tasa_desocupacion_sexo.rds")
