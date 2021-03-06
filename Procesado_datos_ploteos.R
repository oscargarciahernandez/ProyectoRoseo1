library(here)
source(here('funciones_necesarias.R'),encoding = "UTF-8")

data_path<- here('data/')
archivos <- list.files(data_path, pattern = 'csv',
                       recursive = TRUE, full.names = TRUE)
r<-0.27/2 #radio del cacharro




##La funcion procesador entra dentro de cada carpeta de los datos de laboratorio y destripa
## toda la informacion creando un data frame con la informacion de V,A, Velocidad del viento 
## y la informacion del path de cada dato que da informacion de que experimento se trata. 

lista_procesada<-lapply(archivos, procesador)
column_names <- names(lista_procesada[[1]])
df <- data.frame(matrix(unlist(lista_procesada), 
                        nrow=length(lista_procesada), 
                        byrow=T),stringsAsFactors=FALSE)
colnames(df) <- column_names
df<- cbind(archivos,df)



##df_mutate es una funcion que trata los datos df, añadiendo los calculos pertinentes para
##calculo de potencia del viento, TSR, CP, etc. Hay que tener en cuenta que esta funcion añade
## unos calculos con la velocidad medida en cada experimento y luego tambien incluye los calculos
## empleando las velocidades del viento de la prueba piloto. Ya que la velocidad se modifica 
##demasiado al incluir la pared y el concentrador, por lo tanto no se puede tomar como velocidad d
## del viento para el ensayo. YO CREO¡  que incuimos error de esta manera. 

df<- df_mutate(df)


## ejecutando plote_experimento(df,grado) crea una carpeta dentro de pruebas laboratorio
## con las 5 graficas de todos los experimentos con xx grados de ajuste. 
##dado que tengo un problemon con los datos de la velocidad del viento lo que se me ha ocurrido
##es representar las graficas para tres velocidades del viento diferentes: 
## Velocidad del viento de la prueba piloto (estandar)
## velocidad de la lectura del anemometro (lectura)
## velocidad del viento media, una media entre lectura y estandar... SOCORRO¡ 

#ploteo_experimento_estandar(df,3)
#ploteo_experimento_lectura(df,3)
#ploteo_experimento_media(df,3)


### COSITAS PARA SOLUCIONAR,  TENGO UN DATO PARA CONCENTRADOR 30 GRADOS Y PARA LA VELOCIDAD MAXIMA
### QUE ME ESTA TOCANDO LOS COJONES, NO ENCAJA CON EL AJUSTE Y QUEDA FEO EL AJUSTE. 
### HAY QUE CORREGIR ESE FALLITO LO ANTES POSIBLE ANTES DE ENTRAR A CALCULAR CURVAS DE POTENCIA
### UNIR PUNTOS DE CP_MAX Y CREAR CURVA DE POTENCIA, EJE Y(WATSS) EJE X (Vviento)
## 1--> concentrador_30
## 2--> concentrador_45
## 3---> concentrador_70
## 4--> pared
## 5--> piloto


#ploteo_experimento_individual(df,3,1)


### para generar ploteos de rpm y omhnios. a ka vez que obtengo un data.frame cob los coeficientes de ajuste a y b
## los coeficientes se consiguen para la correlacion más alta, dado que estoy probando con dos regresiones
## siempre hay una más acertada que otra.
source(here('tratamiento_outliers.R'))


coeficientes_RPM<-ajuste_RPM_Resistencia_so(df,tablas_sin_outliers_ni_decreasing)
coeficientes_RPM<-data.frame(matrix(unlist(coeficientes_RPM), nrow=30, byrow=T))
names(coeficientes_RPM)<- c("Experimento","Angulo","Porcentaje","a","b")

### añado coeficientes a y b a la tabla df y calcular RPM segun regresion y TSR_vientoestandar y TSR_lectura

df<-add_coef(df,coeficientes_RPM)



###obtencion de las graficas empleando la velocidad de giro aplicando la regresion para estandar,lectura y media
#ploteo_experimento_estandar_RPM_regresion(df,3)
#ploteo_experimento_lectura_RPM_regresion(df,3)
ploteo_experimento_corr_RPM_regresion(df,3)






tabla_cpmax_tsr<-ploteo_experimento_estandar_RPM_regresion_CPmax(df,3)


#esto para crear la tabla de cpmax y TSR en el documento. 
Vmax_cpmax<- sapply(tabla_cpmax_tsr, "[", 6, )



ploteo_CPmax10(df,2)



###ploteo de la curva Potencia, Vviento. Teniendo en cuenta que hay que 
##añadir los limites de x e y para la grafica y que además
##devuelve un data.frame con los coeficientes. Para posteriormente
## hacer lo que queramos con ellos. 
## la formula de ajuste es y ~ b + a*x^3 
##de la regresion. V es para seleccionar entre velocidad medida_corregida (1) o velocidad estandar (2 u otro numero)

limitex<- c(0,11)
limitey<- c(0,20)
coeficientes_Curva_P_V<- grafica_Potencia_V(df,limitex,limitey,2)
coeficientes_Curva_P_V_medida<- grafica_Potencia_V(df,limitex,limitey,1)
coeficientes_Curva_P_V_estandar<- grafica_Potencia_V(df,limitex,limitey,2)


### Por defecto los coeficientes que se añaden a la tabla df son los coeficientes V_estandar

#df<-add_coef_P_V(df,coeficientes_Curva_P_V)



#### calculo de la energia anual producida,  CATÁSTROFE¡¡ 


##Representar las rpms en funcion de las resistencias de manera comparativa
## Para cada porcentaje
RPM_por_porcentaje(df)


