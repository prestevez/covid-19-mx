Evolución Covid-19 en México
================
Patricio R Estevez-Soto
2020-03-17 09:21:02 GMT

# Evolución de casos confirmados de Covid-19 en México

![](casos.png)

Gráfica con evolución de casos confirmados de Covid-19 en México. Datos
originales tomados de la página de la [Secretaría de
Salud](https://www.gob.mx/salud/documentos/informacion-internacional-y-nacional-sobre-nuevo-coronavirus-2019-ncov).

La gráfica muestra también una linea de tendencia calculada con un
modelo exponencial:

\[
E[casos | dia] = e^{\beta0 + \beta \times dia}
\]

La gráfica presenta una extrapolación de la línea de tendencia indicando
**cuantos casos habría en tres días asumiendo que la tendencia se
mantiene**. Sin embargo, es importante notar que **los datos tienen un
gran sesgo de medición**, pues representan solamente los casos
detectados—los cuales variarán en función de la cantidad de pruebas
realizadas y verificadas por la autoridad sanitaria. Por tanto, **es
posible que el modelo predictivo contenga errores importantes y que los
casos detectados sean menores (o mayores) a los esperados**.

Por tanto, considerando las limitaciones de los datos, los resultados
del modelo **no deben de considerarse como predicciones robustas**. Son
aproximaciones extremadamente ingenuas para dar una idea general de cómo
podría evolucionar el fenómeno con base en los datos existentes.

Parámetros del modelo predictivo:

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

# Precisión predictiva

El modelo se actualiza cada día conforme se publican los datos de casos
confirmados. En esta sección se presenta la diferencia entre el número
de casos observados hoy contra el número de casos que se esperaban hoy
según el modelo del día anterior.

| Fecha      | Observados | Predicción | Error |
| :--------- | ---------: | ---------: | ----: |
| 2020-03-15 |         53 |      51.89 |  1.11 |
| 2020-03-16 |         82 |      73.72 |  8.28 |

# Casos esperados mañana

Mañana se esperan **116** casos confirmados de Covid-19 si la tendencia
observada hasta hoy se mantiente igual.

# Caso italiano

Un ejercicio similar elaborado por expertos para el caso italiano puede
encontrarse en Ramuzzi y Ramuzzi (2020).

Remuzzi, A. y Remuzzi, G. (2020) ‘COVID-19 and Italy: what next?’ *The
Lancet* \[online\] doi:
[10.1016/S0140-6736(20)30627-9](https://doi.org/10.1016/S0140-6736\(20\)30627-9)

# Reproducir

Para reproducir este análisis usando [R](https://cran.r-project.org/),
clona o descarga el repositorio y corre:

``` r
# requiere {rmarkdown}, {tidyverse} y {ggthemes}
rmarkdown::render("README.Rmd")
```
