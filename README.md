Evolución de Covid-19 en México
================
[Patricio R Estevez-Soto](https://twitter.com/prestevez).
Actualizado: 2020-03-23 08:42:28 GMT

# Crecimiento de casos confirmados de Covid-19 en México

![](casos.png)

Gráfica con evolución de casos confirmados de Covid-19 en México. Datos
originales tomados de la página de la [Secretaría de
Salud](https://www.gob.mx/salud/documentos/informacion-internacional-y-nacional-sobre-nuevo-coronavirus-2019-ncov).

La gráfica muestra también una linea de tendencia calculada con un
modelo exponencial:

*E\[casos | dia\] = e<sup>b<sub>0</sub> + b x dia</sup>*

La gráfica presenta una extrapolación de la línea de tendencia indicando
**cuantos casos habría en un día asumiendo que la tendencia se
mantiene**. Sin embargo, es importante notar que **los datos tienen un
gran sesgo de medición**, pues representan solamente los **casos
detectados**—los cuales variarán en función de la cantidad de pruebas
realizadas y verificadas por la autoridad sanitaria. Por tanto, **es muy
probable que el modelo predictivo contenga errores importantes y que los
casos detectados sean menores (o mayores) a los esperados**.

Considerando las limitaciones de los datos, los resultados del modelo
**no deben de considerarse como predicciones robustas**. Son
aproximaciones ingenuas para dar una idea general de cómo podría
evolucionar el fenómeno con base en los datos existentes.

Parámetros del modelo predictivo:

    ## 
    ## Call:
    ## glm(formula = casos ~ t, family = gaussian("log"), data = casos)
    ## 
    ## Deviance Residuals: 
    ##      Min        1Q    Median        3Q       Max  
    ## -11.4130   -3.6141   -0.2124    2.3445   11.4760  
    ## 
    ## Coefficients:
    ##              Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept) -0.233077   0.133248  -1.749   0.0942 .  
    ## t            0.250495   0.005909  42.391   <2e-16 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## (Dispersion parameter for gaussian family taken to be 36.12251)
    ## 
    ##     Null deviance: 179872.96  on 23  degrees of freedom
    ## Residual deviance:    794.71  on 22  degrees of freedom
    ## AIC: 158.11
    ## 
    ## Number of Fisher Scoring iterations: 5

# Precisión predictiva

El modelo se actualiza cada día conforme se publican los datos de casos
confirmados. En esta sección se presenta la diferencia entre el número
de casos observados hoy contra el número de casos que se esperaban hoy
según el modelo del día anterior.

| Fecha      | Observados | Predicción |   Error |
| :--------- | ---------: | ---------: | ------: |
| 2020-03-15 |         53 |      51.89 |    1.11 |
| 2020-03-16 |         82 |      73.72 |    8.28 |
| 2020-03-17 |         93 |     115.68 | \-22.68 |
| 2020-03-18 |        118 |     134.77 | \-16.77 |
| 2020-03-19 |        164 |     163.96 |    0.04 |
| 2020-03-20 |        203 |     218.34 | \-15.34 |
| 2020-03-21 |        251 |     273.56 | \-22.56 |
| 2020-03-22 |        316 |     335.79 | \-19.79 |

# Casos esperados mañana

Mañana se esperan **415** casos confirmados de Covid-19 si la tendencia
observada hasta hoy se mantiene igual. Sin embargo, esta cifra muy
probablemente esté equivocada, pues el modelo usado es extremadamente
simple. El objetivo es tener una vaga noción de la cifra esperada.

# Discusión

El uso de modelos exponenciales para predecir el número de casos
confirmados de Covid-19 es consistente con ejercicios [realizados en
otros países](https://doi.org/10.1016/S0140-6736\(20\)30627-9).

La tendencia exponencial del modelo sugiere que **el número de casos
confirmados se duplica cada 2.77 días**. Este ritmo es más rápido que
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
considera supuestos epidemiológicos o médicos relevantes para predecir
con mayor precisión cómo evolucionará la epidemia de Covid-19 en el
país. La información es de carácter informativo solamente.

[Modelar epidemias de forma precisa es complejo y
difícil](https://twitter.com/danitte/status/1240330754460008448), aun
más en el caso de una enfermedad nueva como la Covid-19. Por tanto,
reitero que mi objetivo no es modelar cuál va a ser el comportamiento de
largo alcance de la epidemia.

Mi objetivo es mucho más modesto: solo se busca dar una idea general de
cuántos casos confirmados de Covid-19 podrían reportarse mañana según la
tendencia observada hasta el presente, reconociendo que dicha predicción
está sujeta a errores de medición y modelado.

# Reproducir

Para reproducir este análisis usando [R](https://cran.r-project.org/),
clona o descarga el repositorio y corre:

``` r
# requiere {rmarkdown}, {tidyverse} y {ggthemes}
rmarkdown::render("README.Rmd")
```

# Actualizaciones

  - **19-03-2020**: La extrapolación se redujo a 1 día dados los errores
    de predicción del modelo. Se expandió la sección de aclaración. Se
    corrigió el cálculo del tiempo en el que se espera que se dupliquen
    el total de casos confirmados. El cálculo anterior estaba sesgado
    hacia abajo (el tiempo calculado era menor, el cálculo anterior era
    2/exp(Beta) = t, debe ser log(2)/Beta = t).

# Licencia

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Licencia Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />Esta
obra está bajo una
<a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Licencia
Creative Commons Atribución 4.0 Internacional</a>.
