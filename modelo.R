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

require(MASS)

m1nb <- glm.nb(casos ~ t, data = casos)
summary(m1nb)

lrtest <- lmtest::lrtest

lrtest(m1p, m1nb)

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
  filter(muertes > 0)


# 
# 
# m1 <- glm(casos ~ t,
#           data = casos,
#           family = gaussian("log"))
# 
# 
# modelo <- paste0("Tendencia exponencial (",
#                  round((exp(m1[[1]][2])-1)*100),
#                  "% más casos x día)")
# tibble(
#   date = max_date,
#   casos = NA,
#   t = max_t,
#   predicted = predict(m1, newdata = data.frame(t = max_t), type = "response")
# ) %>%
#   bind_rows(
#     mutate(casos,
#            predicted = predict(m1, type = "response"))) %>%
#   arrange(date) -> casos_with_predictions
# 
# hoy <- max_date - 1
# 
# pg <- "https://www.gob.mx/salud"
# 
# casos_with_predictions %>%
#   ggplot(aes(date, casos)) +
#   geom_point() +
#   theme_fivethirtyeight() +
#   geom_line(aes(y = predicted, colour = modelo)) +
#   xlab("Total de casos") +
#   labs(title = paste0("México: Casos confirmados de Covid-19, ", hoy),
#        caption = paste0("CC-BY @prestevez. Corte a ", hoy, ", con datos de \n", pg)) +
#   theme(legend.title = element_blank()) -> p1
# 
# ggsave("casos.png", p1, width = 7, height = 5)

# 
# lapply(1:nrow(casos), function(x){
#   glm(casos ~ t, 
#       data = casos[-x,],
#       family = gaussian("log"))
# }) -> m1_jk_ls
# 
# sapply(m1_jk_ls, function(x) coef(x)) %>% data.frame() %>%
#   mutate(var = rownames(.)) %>%
#   pivot_longer(-var, names_to = "rep") %>%
#   group_by(var) %>%
#   summarise(Estimate = mean(value),
#             ci_low = quantile(value, 0.025),
#             ci_high = quantile(value, 0.975)) -> m1_jk
# 
# pred_jk <- function(model, t, type = c("Estimate", "ci_low", "ci_high")){
#   terms <- unlist(model[,type[1]])
#   preds <- exp(terms[1] + (terms[2] * t))
#   return(preds)
# }
# 
# 
# casos_with_predictions %>%
#   mutate(Jackknife = pred_jk(m1_jk, t = t),
#          Jackknife_low = pred_jk(m1_jk, t = t, "ci_low"),
#          Jackknife_high = pred_jk(m1_jk, t = t, "ci_high")) -> casos_with_predictions_jk
# 
# casos_with_predictions_jk %>%
#   ggplot(aes(date, casos)) + 
#   geom_point() +
#   theme_fivethirtyeight() +
#   geom_line(aes(y = predicted, colour = modelo)) +
#   #geom_line(aes(y = Jackknife, linetype = "Jackknife"), colour = "red") +
#   geom_errorbar(aes(ymin = Jackknife_low,
#                     ymax = Jackknife_high,
#                     colour = modelo),
#                 linetype = 2) + 
#   xlab("Total de casos") + 
#   labs(title = "México: Casos confirmados de Covid-19",
#        subtitle = paste0("Actualización: ", hoy, ". Intervalo de confianza Jackknife del 95%."),
#        caption = paste0("CC-BY @prestevez. Corte a ", hoy, "\ncon datos de ", pg)) +
#   theme(legend.title = element_blank()) -> p1jk
# 
# ggsave("casos_jk.png", p1jk, width = 7, height = 5)
# 
# jk_pred <- filter(casos_with_predictions_jk, t == max_t)[,c(7,8)]

# 
# read_csv("confirmados.csv") %>%
#   mutate(t = (nrow(.)-1):0) %>%
#   arrange(date) %>%
#   mutate(casos_nuevos = casos-lag(casos),
#          muertes_nuevas = muertes - lag(muertes)) %>%
#   drop_na -> casos_ext
# 
# write_csv(casos_ext, "confirmados_extended.csv")
# 
# n1 <- glm(casos_nuevos ~ t,
#           data = casos_ext,
#           family = poisson("log"))
# 
# 
# modelo_n <- paste0("Tendencia Poisson (",
#                    round((exp(n1[[1]][2])-1)*100),
#                    "% más casos nuevos x día)")
# tibble(
#   date = max_date,
#   casos_nuevos = NA,
#   t = max_t,
#   predicted = predict(n1, newdata = data.frame(t = max_t), type = "response")
# ) %>%
#   bind_rows(
#     mutate(casos_ext,
#            predicted = predict(n1, type = "response"))) %>%
#   arrange(date) -> casos_nuevos_with_predictions
# 
# 
# ### Jackknife estimate?
# 
# lapply(1:nrow(casos_ext), function(x){
#   glm(casos_nuevos ~ t, 
#       data = casos_ext[-x,],
#       family = poisson())
# }) -> n1_jk_ls
# 
# sapply(n1_jk_ls, function(x) coef(x)) %>% data.frame() %>%
#   mutate(var = rownames(.)) %>%
#   pivot_longer(-var, names_to = "rep") %>%
#   group_by(var) %>%
#   summarise(Estimate = mean(value),
#             ci_low = quantile(value, 0.025),
#             ci_high = quantile(value, 0.975)) -> n1_jk
# 
# casos_nuevos_with_predictions %>%
#   mutate(Jackknife = pred_jk(n1_jk, t = t),
#          Jackknife_low = pred_jk(n1_jk, t = t, "ci_low"),
#          Jackknife_high = pred_jk(n1_jk, t = t, "ci_high")) -> casos_nuevos_with_predictions_jk
# 
# 
# casos_nuevos_with_predictions_jk %>%
#   ggplot(aes(date, casos_nuevos)) +
#   geom_point() +
#   theme_fivethirtyeight() +
#   geom_line(aes(y = predicted, colour = modelo_n)) +
#   geom_errorbar(aes(ymin = Jackknife_low,
#                     ymax = Jackknife_high,
#                     colour = modelo_n),
#                 linetype = 2) + 
#   xlab("Total de casos nuevos") +
#   labs(title = "México: Casos confirmados **nuevos** de Covid-19",
#        subtitle = paste0("Actualización: ", hoy, ". Intervalo de confianza Jackknife del 95%."),
#        caption = paste0("CC-BY @prestevez. Corte a ", hoy, "\ncon datos de ", pg)) +
#   theme(legend.title = element_blank()) -> p1n
# 
# ggsave("casos_nuevos.png", p1n, width = 7, height = 5)
# 
# jk_pred_nuevos <- filter(casos_nuevos_with_predictions_jk, t == max_t)[,c(9,10)]