# Reproduce data/df_01.rds

import::from(dplyr, group_by, matches, mutate, rename_with, summarise, "%>%")
import::from(purrr, map, reduce)
import::from(srvyr, as_survey, survey_ratio)

options(survey.lonely.psu = "certainty")

list.files("data/ene", pattern = "*.rds", full.names = TRUE) %>%
  map(
    ~ readRDS(.x) %>%
      rename_with(~ "conglomerado", matches("id_directorio")) %>%
      rename_with(~ "estrato",      matches("estrato_unico")) %>%
      as_survey(
        id      = conglomerado, 
        strata  = estrato, 
        weights = fact_cal
      ) %>%
      mutate(
        de = activ == 2,        # 1 si está desocupado,              0 si no
        ft = activ %in% c(1, 2) # I si está en la fuerza de trabajo, 0 si no
      ) %>%
      group_by(ano_trimestre, mes_central) %>%
      summarise(
        coef = 100 * survey_ratio(de, ft, na.rm = TRUE)
      )
  ) %>%
  reduce(rbind) %>%
  saveRDS("data/df_01.rds")