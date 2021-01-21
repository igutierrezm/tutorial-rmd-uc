# Reproduce data/ene/*
# Nota: Asume que todas las BBDD están en data-raw/ene/, en formato .dta

import::from(dplyr, matches, "%>%") 
import::from(haven, read_dta) 
import::from(purrr, map)
list.files("data-raw/ene") %>%
  map(
    ~ paste0("data-raw/ene/", .x) %>%
      read_dta(
        col_select = c(
          activ,
          ano_trimestre,
          cae_general,
          fact_cal, 
          mes_central,
          sexo,
          matches(c("estrato",      "estrato_unico")),
          matches(c("conglomerado", "id_directorio"))
        )
      ) %>%
      saveRDS(paste0("data/ene/", gsub(".dta", ".rds", .x)))
  )
