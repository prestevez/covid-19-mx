Evolución Covid-19 en México
================
Patricio R Estevez-Soto
2020-03-17 10:58:52 GMT

# Evolución de casos confirmados de Covid-19 en México

![](casos.png)

Gráfica con evolución de casos confirmados de Covid-19 en México. Datos
originales tomados de la página de la [Secretaría de
Salud](https://www.gob.mx/salud/documentos/informacion-internacional-y-nacional-sobre-nuevo-coronavirus-2019-ncov).

La gráfica muestra también una linea de tendencia calculada con un
modelo exponencial:

*E\[casos | dia\] = e<sup>b<sub>0</sub> + b x dia</sup>*

La gráfica presenta una extrapolación de la línea de tendencia indicando
**cuantos casos habría en tres días asumiendo que la tendencia se
mantiene**. Sin embargo, es importante notar que **los datos tienen un
gran sesgo de medición**, pues representan solamente los **casos
detectados**—los cuales variarán en función de la cantidad de pruebas
realizadas y verificadas por la autoridad sanitaria. Por tanto, **es
posible que el modelo predictivo contenga errores importantes y que los
casos detectados sean menores (o mayores) a los esperados**.

Por tanto, considerando las limitaciones de los datos, los resultados
del modelo **no deben de considerarse como predicciones robustas**. Son
aproximaciones ingenuas para dar una idea general de cómo podría
evolucionar el fenómeno con base en los datos existentes.

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
observada hasta hoy se mantiene igual.

# Discusión

El uso de modelos exponenciales para predecir el número de casos
confirmados de Covid-19 es consistente con ejercicios [realizados en
otros países](https://doi.org/10.1016/S0140-6736\(20\)30627-9).

La tendencia exponencial del modelo sugiere que **el número de casos
confirmados se duplica cada 1.39 días**. Este ritmo es más rápido que
[el observado a nivel
global](https://ourworldindata.org/coronavirus#growth-of-cases-how-long-did-it-take-for-the-number-of-confirmed-cases-to-double),
pero es consistente con los ritmos de crecimiento observados durante las
primeras semanas de la epidemia en otros países.

Cabe recalcar que el ritmo de aumento en los casos confirmados **no es
equivalente al ritmo de crecimiento de casos totales** de Covid-19, pues
como se mencionó, los casos confirmados dependen tanto del incremento en
casos totales como de la cantidad de pruebas realizadas. Es probable que
conforme aumente la cantidad de pruebas realizadas, el ritmo de
crecimiento de los casos confirmados se haga más lento.

El modelo presentado no considera el efecto que puedan tener las medidas
de mitigación de la epidemia en la cantidad de casos confirmados en el
futuro. Como se ha mostrado en la
[evidencia](https://www.thelancet.com/journals/laninf/article/PIIS1473-3099\(20\)30144-4/fulltext)
[académica](https://www.thelancet.com/journals/langlo/article/PIIS2214-109X\(20\)30074-7/fulltext),
y se ilustra magistralmente en [el artículo de Harry Stevens en el
Washington
Post](https://www.washingtonpost.com/graphics/2020/world/corona-simulator-spanish/),
las medidas de contención y mitigación como aislamiento de pacientes,
cuarentenas a ciudades y regiones, y especialmente el distanciamiento
social, han demostrado ser efectivas para alentar el ritmo de
crecimiento de la epidemia.

**En la medida que dichas medidas se adopten con vigor en México, se
esperaría que el crecimiento de casos confirmados de Covid-19 en el país
sea más lento.**

# Aclaración

El modelo presentado es **un modelo estadístico básico** que no
considera otros supuestos epidemiológicos o médicos que podrían ser
relevantes para predecir con mayor precisión cómo evolucionará la
epidemia de Covid-19 en el país. La información es de carácter
informativo solamente.

# Reproducir

Para reproducir este análisis usando [R](https://cran.r-project.org/),
clona o descarga el repositorio y corre:

``` r
# requiere {rmarkdown}, {tidyverse} y {ggthemes}
rmarkdown::render("README.Rmd")
```
