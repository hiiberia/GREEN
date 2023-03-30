<div align="center">
<h1> GREEN </h1>
  <a href="https://green.hi-iberia.es/">
    <img src="https://green.hi-iberia.es/wp-content/uploads/2023/03/green-github-e1680181398897.png">
  </a> 
  
<h3> inteliGencia colaboRativa para ciudadEs sostENibles </h3>
</div>

## ¿Qué es  [GREEN](https://green.hi-iberia.es)?

[![Website](https://img.shields.io/website?label=Green%20Web&logo=wordpress&up_message=online&url=https%3A%2F%2Fgreen.hi-iberia.es%2F)](https://green.hi-iberia.es)
[![Youtube](https://img.shields.io/youtube/channel/views/UCVIFpO7f6Sgedn85Z8YD_xA?label=Playlist&style=social)](https://youtube.com/playlist?list=PLZTVw7aFUwDrXejautXrym9g4RuMne1TP)
[![Twitter](https://img.shields.io/twitter/follow/GREEN_hiiberia?style=social)](https://twitter.com/GREEN_hiiberia)

El proyecto Green es una plataforma de inteligencia artificial que busca desarrollar una solución industrial para explotar datos de IoT (objetos conectados a internet) mediante la combinación de tecnologías como **Federated Learning**, **Blockchain** y **Smart Contracts**. Su objetivo principal es optimizar y acelerar las transacciones de servicios de recarga de vehículos eléctricos de manera descentralizada, segura y transparente. 

La plataforma permite generar un **modelo de predicción de la demanda energética** requerida en las estaciones de recarga (ER). De esta manera, los gestores de las estaciones de recarga (GER) puedan negociar un precio ajustado a sus necesidades con el Proveedor de la Red Eléctrica (PRE), sin que los datos de los clientes se vean comprometidos y manteniendo una competencia justa.

Síguenos en nuestro [canal de YouTube de HI Iberia](https://www.youtube.com/@hiiberiaingenieriayproyect9929) para estar al día de nuevas actualizaciones y tutoriales.

Visita regularmente [nuestra página Web](https://green.hi-iberia.es), publicamos artículos diariamente.

## Estructura del repositorio:
- [`airflow`](airflow/): Archivos relacionados con Airflow para todo el proyecto
- [`data`](data/): Datos del proyecto. No sincronizado con la base de datos central, únicamente pequeños grupos de datos necesarios.
- [`docker`](docker/): Archivos relacionados con Docker para todo el proyecto. Podría hacer uso de los archivos Docker para cada uno de los componentes de la ML pipeline.
- [`docs`](docs/): Cualquier documentación de apoyo, como diccionarios de datos, manuales, documentación de los paquetes (autogenerada a partir de docstrings) y cualquier otro material explicativo.
- [`green_blockchain`](green/bc/): Bibliotecas/módulos Python listos y reutilizables para el módulo de Blockchain. 
- [`green_contract`](green/sc/): Bibliotecas/módulos Python listos y reutilizables para el módulo de Smart Contracts. 
- [`green_federated`](green/fl/): Bibliotecas/módulos Python listos y reutilizables para el módulo Federated Learning. Este es el tipo de código python que importas.
- [`green_simulator`](green/sim/): Bibliotecas/módulos Python listos y reutilizables para el módulo de Simulación. 
- [`kubernetes`](kubernetes/): Archivos relacionados con Kubernetes. Los archivos Yaml se almacenarían aquí.
- [`scripts`](scripts/): Donde se colocan los scripts, tanto Python como bash.
- [`reports`](reports/): Análisis generados como HTML, PDF, LaTeX, etc.
- [`research`](research/): Scripts y cuadernos .ipynb de experimentación.
- [`test`](test/): Pruebas para tu código y evalución del proyecto
- [setup.py](setup.py): Fichero de instalación de las funciones desarrolladas dentro de [green](green_python/) como un nuevo paquete.
- [requirements.txt](requirements.txt): El archivo de requisitos para reproducir el entorno de análisis


## Instalación
### Git
Para el desarrollo de código se requiere instalar git en la máquina en la que se realice desarrollo de código.
...
### Docker 
1. Instalar la versión adecuada de docker desde la página web de [docker](https://www.docker.com/get-started). La versión Docker Desktop es la adecuada si se desea instalar sobre un ordenador personal.
2. Generar carpetas necesarias para el almacenamiento de los archivos:
   ```
   mkdir GREEN
   cd GREEN
   mkdir postgres-data
   ```
3. Clonar repositorio de GIT.
   ```
   git clone https://extranet.hi-iberia.es:8444/8ai/green/green.git
   ```
4. Desplegar contenedores:
   ```
   cd green/docker
   docker-compose up -d
   ```
5. Acceder al contenedor principal
   ```
   docker exec -it green_home_service bash
   ```
6. Una vez dentro, ejecutar el siguiente comando para instalar el paquete de mapre
   ```
   pip install -e .
   ```
7. Ahora podemos ejecutar los diferentes scripts.


### Conda
1. Instalar el servicio de gestión de paquetes de conda (anaconda, miniconda, etc)
2. Crear el entorno de conda utilizando el fichero yml.
    ```
    conda env create -f environment.yml
    ```
3. Una vez instalado el entorno y activandolo con `conda activate green`, desde la raiz del proyecto ejecutar el siguiente comando:
    ```
    pip install -e .
    ```
    Esto permitirá generar un nuevo paquete [green] que contenga las diferentes funciones escritas dentro de la carpeta [green](green_python/).

4. Ejecutar los diferentes scripts o notebooks de forma sencilla.



```
.
├── data
│   ├── external       <- Datos de terceras fuentes.
│   ├── interim        <- Datos intermedios que se han transformado.
│   ├── processed      <- Los conjuntos de datos canónicos definitivos para la modelización.
│   └── raw            <- El volcado de datos original e inmutable.
│
├── docker
│
├── docs               <- Diccionarios de datos, manuales y cualquier otro material explicativo.
│
├── kubernetes
│
│
├── README.md          <- El README de nivel superior para los desarrolladores que utilicen este proyecto.
│
├── reports            <- Análisis generados como HTML, PDF, LaTeX, etc.
│   └── figures        <- Generación de gráficos y cifras para su uso en informes
│
├── requirements.txt   <- El archivo de requisitos para reproducir el entorno de análisis
│
├── research           <- Scripts y cuadernos (.ipynb) de experimentación.
│   ├── deliver
│   ├── develop
│   └── templates
│
├── scripts            <- Scripts, tanto Python como bash.
│
├── setup.py           <- Hace que el proyecto pip instalable (pip install -e .) por lo que green puede ser importado
│
└── green
    │
    ├── simulator
    │   ├── data           <- Scripts para descargar o generar datos
    │   ├── models         <- Scripts para entrenar modelos y luego utilizar modelos entrenados para hacer predicciones
    │   ├── __pycache__
    │   └── visualization  <- Scripts para crear visualizaciones exploratorias y orientadas a resultados
    │
    ├── blockchain
    │   ├── data           <- Scripts para descargar o generar datos
    │   ├── models         <- Scripts para entrenar modelos y luego utilizar modelos entrenados para hacer predicciones
    │   └── visualization  <- Scripts para crear visualizaciones exploratorias y orientadas a resultados
    │
    ├── contract
    │   ├── data           <- Scripts para descargar o generar datos
    │   ├── models         <- Scripts para entrenar modelos y luego utilizar modelos entrenados para hacer predicciones
    │   └── visualization  <- Scripts para crear visualizaciones exploratorias y orientadas a resultados
    │
    └── federated
        ├── data           <- Scripts para descargar o generar datos
        ├── __init__.py    <- Convierte green en un módulo de Python
        ├── models         <- Scripts para entrenar modelos y luego utilizar modelos entrenados para hacer predicciones
        ├── __pycache__
        └── visualization  <- Scripts para crear visualizaciones exploratorias y orientadas a resultados

```
