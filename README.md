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

## Estructura del Repositorio

- **[`conference/`](conference/):** Documentación y archivos relacionados con la asistencia a conferencias y papers presentados en el contexto del proyecto GREEN.
- **[`data/`](data/):** Incluye conjuntos de datos utilizados en el proyecto. Estos datos no están sincronizados con la base de datos central, sino que son grupos pequeños de datos necesarios para análisis específicos o experimentos locales.
- **[`docker/`](docker/):** Archivos y configuraciones relacionadas con Docker para todo el proyecto. Contiene Dockerfiles y archivos `docker-compose.yml` que permiten construir y desplegar los componentes del proyecto, incluyendo la pipeline de Machine Learning.
- **[`events/`](events/):** Cronología de eventos específicos durante el desarrollo del proyecto, incluyendo hitos importantes y actividades clave.
- **[`green/bc/`](green/bc/):** Módulos y bibliotecas de Python listos para ser reutilizados en el módulo de Blockchain del proyecto GREEN.
- **[`green/fl/`](green/fl/):** Módulos y bibliotecas de Python para el módulo de Aprendizaje Federado (Federated Learning). Este directorio contiene el código reutilizable para implementar modelos de aprendizaje distribuido.
- **[`green/sc/`](green/sc/):** Módulos y bibliotecas de Python desarrollados para el manejo de Smart Contracts en el contexto del proyecto.
- **[`green/sim/`](green/sim/):** Módulos y bibliotecas de Python diseñados para el módulo de Simulación del proyecto, facilitando la simulación de escenarios de recarga y tráfico.
- **[`kubernetes/`](kubernetes/):** Contiene archivos YAML y otros recursos necesarios para la gestión y despliegue de los componentes del proyecto en un entorno de Kubernetes.
- **[`multimedia/`](multimedia/):** Contiene contenido multimedia generado, como videos, posters, y folletos, utilizado para la difusión del proyecto.
- **[`news/`](news/):** Carpeta para almacenar noticias encontradas, analizadas y eventos relacionados con el desarrollo del proyecto.
- **[`reports/`](reports/):** Resultados de análisis generados en diversos formatos como HTML, PDF, LaTeX, etc., documentando hallazgos y conclusiones del proyecto.
- **[`research/`](research/):** Scripts y cuadernos Jupyter (`.ipynb`) utilizados para la experimentación, prototipos y análisis exploratorios.
- **[`requirements.txt`](requirements.txt):** Archivo que especifica todas las dependencias necesarias para reproducir el entorno de desarrollo y análisis del proyecto.


## Instalación

Este repositorio no es un repositorio ejecutable, sino que incluye experimentos, archivos comentados, y documentación detallada para facilitar el entendimiento de la combinación de tecnologías utilizadas en el proyecto GREEN. Además de código, sirve como repositorio central de todo el material disponible del proyecto, como reportes, noticias, avances, y contenido multimedia.

Para instalar y configurar el entorno de desarrollo del proyecto GREEN, sigue los pasos a continuación:

1. **Clona el repositorio**:

   Primero, clona el repositorio a tu máquina local y navega al directorio del proyecto:

   ```bash
   git clone https://github.com/tu_usuario/tu_repositorio.git
   cd tu_repositorio
   ```

2. **Instala las dependencias de Python**:
   
   Utiliza el archivo requirements.txt para instalar todas las dependencias necesarias para el proyecto:

   ```bash
   pip install -r requirements.txt
   cd tu_repositorio
   ```

3. **Configura Docker y Docker Compose**:
   
   Asegúrate de tener Docker y Docker Compose instalados en tu sistema. Luego, construye y ejecuta los contenedores necesarios utilizando el siguiente comando:

   ```bash
   docker-compose -f docker/docker-compose.yml up --build
   ```

Este repositorio proporciona una infraestructura completa para experimentar y aprender sobre las tecnologías implementadas en el proyecto GREEN, integrando múltiples fuentes de información y facilitando su accesibilidad y comprensión de manera externa.


## Mapa del Repositorio

El repositorio del proyecto GREEN está organizado en diferentes carpetas y archivos que agrupan todos los recursos necesarios para desarrollar, ejecutar, y analizar las distintas funcionalidades del proyecto. Esta estructura permite un acceso fácil y ordenado a cada componente, facilitando tanto la comprensión de las tecnologías involucradas como la colaboración entre los miembros del equipo.

A continuación se presenta una descripción de la estructura del repositorio:
```
GREEN/
│
├── README.md                 # Descripción general del proyecto
├── LICENSE                   # Licencia del proyecto
│
├── data/                     # Datos del proyecto, no sincronizados con la base de datos central
│
├── docker/                   # Archivos Docker para la configuración de contenedores
│   ├── Dockerfile
│
├── kubernetes/               # Archivos YAML relacionados con Kubernetes
│   ├── deployment.yaml
│
├── news/                     # Noticias encontradas y analizadas sobre el tema
│
├── events/                   # Cronología de eventos durante el desarrollo del proyecto
│
├── multimedia/               # Contenido multimedia como videos, posters, folletos, etc.
│   ├── videos/
│   └── promotional/
│
├── conference/               # Asistencia a conferencias y papers relacionados
│
├── green/                    # Bibliotecas y módulos Python reutilizables
│   ├── blockchain (bc)/
│   ├── federated (fl)/
│   ├── contract (sc)/
│   └── simulator (sim)/
│
├── reports/                  # Análisis generados como HTML, PDF, LaTeX, etc.
│
└── research/                 # Scripts y cuadernos .ipynb de experimentación
```
