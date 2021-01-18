# Reproduce data/df_03.rds

import::from(dplyr, group_by, matches, mutate, rename_with, summarise, "%>%")
import::from(purrr, map, reduce)
import::from(srvyr, as_survey, survey_total)

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
      group_by(ano_trimestre, mes_central, cae_general) %>%
      summarise(ocupados = survey_total())
  ) %>%
  reduce(rbind) %>%
  saveRDS("data/df_03.rds")