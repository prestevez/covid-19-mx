library(tidyverse)
library(ggthemes)
library(lubridate)

casos <- read_csv("confirmados.csv")

casos$t <- (nrow(casos)-1):0

casos %>%
  filter(casos > 0) -> casos

m1 <- glm(casos ~ t, 
          data = casos,
          family = gaussian("log"))

summary(m1)

max_date <- max(casos$date) + 1
max_t <- max(casos$t) + 1

tibble(
  date = seq(max_date,max_date+2, 1),
  casos = NA,
  t = max_t:(max_t+2),
  predicted = predict(m1, newdata = data.frame(t = max_t:(max_t+2)), type = "response")
  ) %>%
  bind_rows(
    mutate(casos,
      predicted = predict(m1, type = "response"))) %>%
  arrange(date) -> casos_with_predictions

modelo <- paste0("Predicción casos = exp(",
                 round(m1[[1]][1], 2),
                 " + ",
                 round(m1[[1]][2], 2),
                 " x día)")

hoy <- Sys.Date()

pg <- "https://www.gob.mx/salud"

casos_with_predictions %>%
  ggplot(aes(date, casos)) + 
  geom_point() +
  theme_fivethirtyeight() +
  geom_line(aes(y = predicted, colour = "GLM")) +
  xlab("Total de casos") + 
  labs(title = "México: Casos confirmados de Covid-19",
       caption = paste0("CC-BY @prestevez. Corte a ", hoy, ", con datos de \n", pg)) +
  theme(legend.title = element_blank())

### Jackknife estimate?

lapply(1:nrow(casos), function(x){
  glm(casos ~ t, 
      data = casos[-x,],
      family = gaussian("log"))
}) -> m1_jk_ls

sapply(m1_jk_ls, function(x) coef(x)) %>% data.frame() %>%
  mutate(var = rownames(.)) %>%
  pivot_longer(-var, names_to = "rep") %>%
  group_by(var) %>%
  summarise(Estimate = mean(value),
            ci_low = quantile(value, 0.025),
            ci_high = quantile(value, 0.975)) -> m1_jk

pred_jk <- function(model, t, type = c("Estimate", "ci_low", "ci_high")){
  terms <- unlist(model[,type[1]])
  preds <- exp(terms[1] + (terms[2] * t))
  return(preds)
}


casos_with_predictions %>%
  mutate(Jackknife = pred_jk(m1_jk, t = t),
         Jackknife_low = pred_jk(m1_jk, t = t, "ci_low"),
         Jackknife_high = pred_jk(m1_jk, t = t, "ci_high")) -> casos_with_predictions_jk

casos_with_predictions_jk %>% data.frame

casos_with_predictions_jk %>%
  ggplot(aes(date, casos)) + 
  geom_point() +
  theme_fivethirtyeight() +
  geom_line(aes(y = predicted, linetype = "GLM"), colour = "red") +
  geom_line(aes(y = Jackknife, linetype = "Jackknife"), colour = "red") +
  geom_errorbar(aes(ymin = Jackknife_low,
                    ymax = Jackknife_high,
                    linetype = "Jackknife"),
                colour = "red") + 
  xlab("Total de casos") + 
  labs(title = "México: Casos confirmados de Covid-19",
       caption = paste0("CC-BY @prestevez. Corte a ", hoy, ", con datos de \n", pg)) +
  theme(legend.title = element_blank()) 

### MCMC does not appear to offer any benefits
# install.packages("MCMCpack")
# 
# library(MCMCpack)
# ls(package:MCMCpack)
# 
# m1_lm <- lm(log(casos) ~ t, data = casos)
# 
# summary(m1_lm)
# 
# casos_with_predictions %>%
#   mutate(predlm = exp(predict(m1_lm, newdata = data.frame(t = t)))) %>%
#   ggplot(aes(date, casos)) + 
#   geom_point() +
#   theme_fivethirtyeight() +
#   geom_line(aes(y = predicted, colour = "GLM")) +
#   geom_line(aes(y = predlm, colour = "LM")) +
#   xlab("Total de casos") + 
#   labs(title = "México: Casos confirmados de Covid-19",
#        caption = paste0("CC-BY @prestevez. Corte a ", hoy, ", con datos de \n", pg)) +
#   theme(legend.title = element_blank())
# 
# 
# m1_mcmc <- MCMCregress(log(casos) ~ t, data = casos)
# 
# summary(m1_mcmc)


m1p <- update(m1, family = "poisson")

summary(m1p)
summary(m1)

ggplot(casos, 
       aes(date, casos)) +
  geom_point() +
  geom_line(aes(y = predict(m1p, type = "response"), colour = "Poisson")) +
  geom_line(aes(y = predict(m1, type = "response"), colour = "GLM"))

summary(m1)

lm1 <- lm(log(casos) ~  t, data = casos)
summary(lm1)

casos %>%
  ggplot(aes(date, casos)) +
  geom_point() +
  geom_line(aes(y = exp(predict(lm1)), colour = "LM")) +
  geom_line(aes(y = predict(m1, type = "response"), colour = "GLM"))

# Modelo muertes totales y nuevas

casos_ext %>%
  filter(muertes > 0) %>%
  glm(muertes ~ t,
          data = .,
          family = gaussian("log")) -> d1


modelo_d <- paste0("Tendencia exponencial (",
                 round((exp(d1[[1]][2])-1)*100),
                 "% más muertes totales x día)")
tibble(
  date = max_date,
  muertes = NA,
  t = max_t,
  predicted = predict(d1, newdata = data.frame(t = max_t), type = "response")
) %>%
  bind_rows(
    mutate(filter(casos_ext, muertes > 0),
           predicted = predict(d1, type = "response"))) %>%
  arrange(date) -> muertes_with_predictions



muertes_with_predictions %>%
  ggplot(aes(date, muertes)) +
  geom_point() +
  theme_fivethirtyeight() +
  geom_line(aes(y = predicted, colour = modelo_d)) +
  xlab("Total de muertes") +
  labs(title = paste0("México: Total de muertes por Covid-19, ", hoy),
       subtitle = "Desde el día de la primera muerte reportada",
       caption = paste0("CC-BY @prestevez. Corte a ", hoy, ", con datos de \n", pg)) +
  theme(legend.title = element_blank()) -> p1_d

ggsave("muertes.png", p1_d, width = 7, height = 5)

d1_jk <- jk_model(d1) 

muertes_with_predictions %>%
  mutate(Jackknife = pred_jk(d1_jk, t = t),
         Jackknife_low = pred_jk(d1_jk, t = t, "ci_low"),
         Jackknife_high = pred_jk(d1_jk, t = t, "ci_high")) -> muertes_with_predictions_jk

muertes_with_predictions_jk %>%
  ggplot(aes(date, muertes)) +
  geom_point() +
  theme_fivethirtyeight() +
  geom_line(aes(y = predicted, colour = modelo_d)) +
  #geom_line(aes(y = Jackknife, linetype = "Jackknife"), colour = "red") +
  geom_errorbar(aes(ymin = Jackknife_low,
                    ymax = Jackknife_high,
                    colour = modelo_d),
                linetype = 2) +
  xlab("Total de casos") +
  labs(title = "México: Total de muertes por Covid-19",
       subtitle = paste0("Actualización: ", hoy, ". Intervalo de confianza Jackknife del 95%."),
       caption = paste0("CC-BY @prestevez. Corte a ", hoy, "\ncon datos de ", pg)) +
  theme(legend.title = element_blank()) -> p1jk_d

ggsave("muertes_jk.png", p1jk_d, width = 7, height = 5)

jk_pred_d <- filter(muertes_with_predictions_jk, t == max_t)[,c(9,10)]

# 
# read_csv("confirmados.csv") %>%
#   mutate(t = (nrow(.)-1):0) %>%
#   arrange(date) %>%
#   mutate(casos_nuevos = casos-lag(casos),
#          muertes_nuevas = muertes - lag(muertes)) %>%
#   drop_na -> casos_ext
# 
# write_csv(casos_ext, "confirmados_extended.csv")

# Muertes nuevas

casos_ext %>%
  filter(muertes > 0) %>%
  glm(muertes_nuevas ~ t,
          data = .,
          family = poisson("log")) -> dn1


modelo_dn <- paste0("Tendencia Poisson (",
                   round((exp(d1[[1]][2])-1)*100),
                   "% más casos nuevos x día)")
tibble(
  date = max_date,
  muertes_nuevas = NA,
  t = max_t,
  predicted = predict(dn1, newdata = data.frame(t = max_t), type = "response")
) %>%
  bind_rows(
    mutate(filter(casos_ext, muertes > 0),
           predicted = predict(dn1, type = "response"))) %>%
  arrange(date) -> muertes_nuevos_with_predictions


jk_model(dn1) -> dn1_jk

muertes_nuevos_with_predictions %>%
  mutate(Jackknife = pred_jk(dn1_jk, t = t),
         Jackknife_low = pred_jk(dn1_jk, t = t, "ci_low"),
         Jackknife_high = pred_jk(dn1_jk, t = t, "ci_high")) -> muertes_nuevos_with_predictions_jk



muertes_nuevos_with_predictions_jk %>%
  ggplot(aes(date, muertes_nuevas)) +
  geom_point() +
  theme_fivethirtyeight() +
  geom_line(aes(y = predicted, colour = modelo_dn)) +
  geom_errorbar(aes(ymin = Jackknife_low,
                    ymax = Jackknife_high,
                    colour = modelo_dn),
                linetype = 2) +
  xlab("Total de casos nuevos") +
  labs(title = "México: Muertes **nuevas** de Covid-19",
       subtitle = paste0("Actualización: ", hoy, ". Intervalo de confianza Jackknife del 95%."),
       caption = paste0("CC-BY @prestevez. Corte a ", hoy, "\ncon datos de ", pg)) +
  theme(legend.title = element_blank()) -> p1n_d

ggsave("muertes_nuevos.png", p1n_d, width = 7, height = 5)

jk_pred_muertes_nuevas <- filter(muertes_nuevos_with_predictions_jk, t == max_t)[,c(9,10)]
