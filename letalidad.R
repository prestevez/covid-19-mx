require(tidyverse)

# Letalidad probabilidades

pob <- read_csv("pob_mit_proyecciones.csv")

pob %>%
  filter(AÑO == 2020, CVE_GEO == 0) -> pobnal2020

select <- dplyr::select

letalidad <- read_csv("tasa_letalidad.csv")

letalidad %>%
  mutate(letalidad = letalidad/100,
         grp = 9:1) -> letalidad


pobnal2020 %>%
  select(-ENTIDAD) %>%
  group_by(EDAD) %>%
  summarise(pob = sum(POBLACION)) %>%
  mutate(grp = unlist(lapply(1:11, function(x) rep(x, 10))),
         grp = ifelse(grp > 8, 9, grp))%>%
  group_by(grp) %>%
  summarise(pob = sum(pob)) %>%
  left_join(letalidad) -> pobnal2020_letalidad

pobnal2020_letalidad %>%
  group_by(grp) %>%
  mutate(edad = ifelse(edad < 80, paste(edad, edad+9, sep = "-"),
                       paste0(edad, "+")),
         "1%" = pob * .01 * letalidad,
         "5%" = pob * .05 * letalidad,
         "10%" = pob * .10 * letalidad,
         "20%" = pob * .20 * letalidad,
         "30%" = pob * .30 * letalidad) -> pobnal2020_letalidad_rslt


pobnal2020_letalidad_rslt %>%
  pivot_longer(-c(grp, pob, edad, letalidad), names_to = "Infectados", values_to = "Muertes") %>%
  ungroup() %>%
  mutate(Infectados = factor(Infectados, 
                             levels = c("1%", "5%", "10%", "20%", "30%"))) %>%
  filter(grp > 1) %>%
  ggplot(aes(edad, Muertes, fill = Infectados)) + 
  geom_bar(stat = "identity", position = "dodge")


# Tasas nacional por 100,000 habitantes
colSums(pobnal2020_letalidad_rslt[,-3])[-c(1,3)] -> nals
nals[-1]/nals[1] * 100000

prct_inf <- c(0.01, 0.05, 0.1, 0.2)

pobnal2020_letalidad %>%
  expand_grid(prct_inf) %>%
  filter(grp > 1) %>%
  mutate(edad = ifelse(edad < 80, paste(edad, edad+9, sep = "-"),
                       paste0(edad, "+"))) -> pobnal2020_letalidad_new

replicate(1000,
          pobnal2020_letalidad_new %>%
            split(.$edad) %>%
            map_df(~ rbinom(.x$pob, .x$pob, .x$letalidad * .x$prct_inf)) %>%
            mutate(prct_inf = c(0.01, 0.05, 0.1, 0.2)) %>%
            pivot_longer(-prct_inf, names_to = "edad", values_to = "muertes_sim"),
          simplify = FALSE) %>%
  bind_rows(.id = "rep") -> sim_deaths

sim_deaths %>%
  group_by(prct_inf, edad) %>%
  summarise(muertes = mean(muertes_sim),
            ci_low = quantile(muertes_sim, 0.025),
            ci_high = quantile(muertes_sim, .975)) %>%
  ggplot(aes(fct_rev(edad), muertes, fill = fct_rev(factor(prct_inf)))) + 
        geom_col(position = "dodge") +
  scale_fill_colorblind("Proporción de población infectada") +
  scale_y_continuous(breaks = seq(5000,75000, 10000)) +
  coord_flip() +
  theme_fivethirtyeight()
    

### z-score changes in probabilities
logit <- function(t) 1/(1 + exp(-t))

probs <- seq(0.01,0.99, .01)

plot(-6:6, logit(-6:6))

inv_logit <- function(p) log(p/(1-p))

inv_logit(probs)


