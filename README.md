---
title: "Evolución Covid-19 en México"
author: "Patricio R Estevez-Soto"
date: "2020-03-17"
output: md_document
---

# Evolución de casos confirmados de Covid-19 en México


```r
library(tidyverse)
library(ggthemes)
library(lubridate)

casos <- read_csv("confirmados.csv")
```

```
## Parsed with column specification:
## cols(
##   date = col_date(format = ""),
##   casos = col_double()
## )
```

```r
casos$t <- (nrow(casos)-1):0

casos %>%
  filter(casos > 0) %>%
  arrange(date) -> casos

m1 <- glm(casos ~ t, 
          data = casos,
          family = gaussian("log"))

max_date <- max(casos$date) + 1
max_t <- max(casos$t) + 1

modelo <- paste0("Tendencia exponencial (",
                 round((exp(m1[[1]][2])-1)*100),
                 "% más casos x día)")
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

hoy <- max_date - 1

pg <- "https://www.gob.mx/salud/documentos/informacion-internacional-y-nacional-sobre-nuevo-coronavirus-2019-ncov"

casos_with_predictions %>%
  ggplot(aes(date, casos)) + 
  geom_point() +
  theme_fivethirtyeight() +
  geom_line(aes(y = predicted, colour = modelo)) +
  xlab("Total de casos") + 
  labs(title = "México: Casos confirmados de Covid-19",
       caption = paste0("CC-BY @prestevez. Corte a ", hoy, ", con datos de \n", pg)) +
  theme(legend.title = element_blank()) -> p1

ggsave("casos.png", p1, width = 7, height = 5)
```

```
## Warning: Removed 3 rows containing missing values (geom_point).
```


![](casos.png)

Gráfica con evolución de casos confirmados de Covid-19 en México. Datos originales tomados de la página de la [Secretaría de Salud](https://www.gob.mx/salud/documentos/informacion-internacional-y-nacional-sobre-nuevo-coronavirus-2019-ncov). 

La gráfica muestra también una linea de tendencia calculada con un modelo no lineal:
$$
E[casos | dia] = e^{\beta0 + \beta \times dia}
$$

Resultados del modelo:


```r
summary(m1)
```

```
## 
## Call:
## glm(formula = casos ~ t, family = gaussian("log"), data = casos)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -3.6161  -0.4251   2.7609   3.9794   4.6654  
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept) -2.19103    0.39331  -5.571 4.22e-05 ***
## t            0.36536    0.02297  15.907 3.16e-11 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for gaussian family taken to be 11.74525)
## 
##     Null deviance: 7816.00  on 17  degrees of freedom
## Residual deviance:  187.91  on 16  degrees of freedom
## AIC: 99.303
## 
## Number of Fisher Scoring iterations: 8
```

La gráfica presenta una extrapolación de la línea de tendencia indicando cuantos casos habría en tres días *asumiendo que la tendencia se mantiene*. Sin embargo, es importante notar que los datos tienen un gran sesgo de medición, pues representan solamente los casos detectados---los cuales variarán en función de la cantidad de pruebas realizadas y verificadas por la autoridad sanitaria. Por tanto, *es posible que el modelo predictivo contenga errores importantes y que los casos detectados sean menores (o mayores) a los esperados*.

Por tanto, considerando las limitaciones de los datos, los resultados del modelo no deben de considerarse como predicciones robustas. Son aproximaciones extremadamente simples para dar una idea genera de cómo podría evolucionar el fenómeno con base en los datos existentes.

# Precisión predictiva

El modelo se actualiza cada día conforme se publican los datos de casos confirmados. En esta sección se presenta la diferencia entre el número de casos observados hoy contra el número de casos que se esperaban hoy según el modelo del día anterior.


```r
casos %>%
  filter(!t == (max_t-1)) %>%
  glm(casos ~ t, data = ., family = gaussian("log")) -> m1_yesterday

casos %>%
  filter(t == (max_t-1)) %>%
  predict(m1_yesterday, newdata = ., type = "response") -> predicted_today
  
casos %>%
  filter(t == (max_t-1)) %>%
  transmute(Fecha = date, Observados = casos) %>%
  mutate(Predicción = predicted_today,
         Error = Observados-Predicción) %>%
  write_csv("predicciones.csv", append = TRUE, col_names = FALSE)

read_csv("predicciones.csv") %>%
  knitr::kable(., digits = 2)
```



|Fecha      | Observados| Predicción| Error|
|:----------|----------:|----------:|-----:|
|2020-03-15 |         53|      51.89|  1.11|
|2020-03-16 |         82|      73.72|  8.28|
 
Mañana se esperan 116 casos confirmados de Covid-19 si la tendencia observada hasta hoy se mantiente igual.


# Caso italiano

Un ejercicio similar elaborados por expertos para el caso italiano puede encontrarse en Ramuzzi y Ramuzzi (2020).

Remuzzi, A. y Remuzzi, G. (2020) 'COVID-19 and Italy: what next?' *The Lancet* [online] doi: [10.1016/S0140-6736(20)30627-9](https://doi.org/10.1016/S0140-6736(20)30627-9)




