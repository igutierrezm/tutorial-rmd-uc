# Reproduce data/df_02.rds

import::from(haven, labelled)
import::from(magrittr, "%>%", "%T>%")
options(survey.lonely.psu = "certainty")

df_02 <-
  list.files("data/ene", pattern = "*.rds", full.names = TRUE) %>%
  purrr::map(
    ~ readRDS(.x) %>%
      dplyr::rename_with(~ "conglomerado", dplyr::matches("id_directorio")) %>%
      dplyr::rename_with(~ "estrato",      dplyr::matches("estrato_unico")) %>%
      dplyr::mutate(
        de = activ == 2,        # 1 si está desocupado,              0 si no
        ft = activ %in% c(1, 2) # I si está en la fuerza de trabajo, 0 si no
      ) %>%
      srvyr::as_survey(
        id      = conglomerado, 
        strata  = estrato, 
        weights = fact_cal
      ) %>%
      srvyr::group_by(ano_trimestre, mes_central, sexo) %>%
      srvyr::summarise(coef = 100 * srvyr::survey_ratio(de, ft, na.rm = TRUE))
  ) %>%
  purrr::reduce(rbind) %T>%
  saveRDS("data/df_02.rds")
