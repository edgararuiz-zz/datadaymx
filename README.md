# Sesion de `sparklyr` durante Data Day Mexico 2019

Si planea ir a esta platica, por favor chequee este página regularmente.  Aquí vamos a publicar las instrucciones. También, este repositorio va a tener la presentación y el código que se va a usar durante la sesión.

## Tarea para usted 

- Si desea practicar los ejercicios en vivo durante la sesión, por favor asegúrese de tener los siguientes paquetes de R pre-instalados en su computadora:

```r
  install.packages("sparklyr")
  install.packages("tidyverse")
  install.packages("dbplot")
  install.packages("nycflights13")
  install.packages("janeaustenr")
```

- Asegúrese de tener Java 8 instalado en su computadora, puede bajarlo aquí: https://www.java.com/en/

- También, es necesario tener Spark instalado en su computadora.  La siguiente instrucción también funciona en Windows:

```r
  spark_install("2.0.0")
```

- Para confirmar que todo funciona, use el siguiente comando:
```r
  sc <- spark_connect(master = "local", version = "2.0.0")
```
