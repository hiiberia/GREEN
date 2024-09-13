# Docker Configuration

Este directorio contiene los archivos necesarios para construir y desplegar los contenedores Docker utilizados en el proyecto GREEN. La configuración de Docker permite crear un entorno de desarrollo consistente para el proyecto, incluyendo un servicio principal de Python que corre en un contenedor Docker.

## Descripción de Archivos

### `docker-compose.yml`

Este archivo define los servicios de Docker que componen la aplicación, incluyendo las configuraciones necesarias para construir y ejecutar los contenedores. Los detalles principales son:

- **Version**: Utiliza la versión '3' de Docker Compose.
- **Servicios**:
  - **`home_service`**: Servicio principal que corre una imagen de Python preconfigurada para el proyecto GREEN.
    - **Image**: Utiliza la imagen `green/python:latest` como base.
    - **Build**: Especifica el contexto de construcción del Dockerfile, apuntando al archivo `Dockerfile` en la carpeta `docker`.
    - **Container Name**: El contenedor es nombrado como `green_home_service`.
    - **Volumes**: Monta el directorio del proyecto (`../`) dentro del contenedor en la ruta `/GREEN`.
    - **Command**: Ejecuta un comando que mantiene el contenedor en ejecución indefinidamente (`/bin/sh -c "while sleep 1000; do :; done"`).

### `Dockerfile`

Este archivo define cómo se construye la imagen de Docker para el servicio principal del proyecto GREEN. Aunque no se proporcionaron los detalles específicos del archivo, generalmente incluye:

- **Base Image**: Una imagen de Python o del sistema operativo necesario para el entorno de desarrollo.
- **Instalación de Dependencias**: Instrucciones para instalar las dependencias necesarias del proyecto.
- **Copiado de Archivos**: Copia de los archivos del proyecto dentro del contenedor.
- **Comandos de Ejecución**: Configura el comando principal que se ejecutará al iniciar el contenedor.

## Instrucciones de Uso

1. **Construir y Ejecutar los Contenedores**:

   Para construir y ejecutar los contenedores definidos en el archivo `docker-compose.yml`, navega al directorio principal del proyecto y ejecuta:

   ```bash
   docker-compose up --build

2. **Detener los Contenedores**:
    
    Para detener todos los contenedores en ejecución, utiliza:
   ```bash
   docker-compose down

## Volúmenes

El volumen configurado en `docker-compose.yml` permite el acceso compartido al código del proyecto dentro del contenedor, asegurando que cualquier cambio realizado en el código fuente se refleje directamente en el contenedor.

## Propósito

Esta configuración de Docker se utiliza para:

- Proporcionar un entorno de desarrollo reproducible y consistente.
- Aislar las dependencias y configuración del proyecto.
- Facilitar el despliegue de servicios en entornos controlados.
