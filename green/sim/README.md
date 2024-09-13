# Urban Simulation (SUMO)

Este directorio contiene los archivos necesarios para ejecutar una simulación de estaciones de carga de vehículos eléctricos utilizando SUMO (Simulation of Urban MObility). La simulación incluye la configuración de la red de tráfico, rutas de vehículos eléctricos, y la ubicación y configuración de las estaciones de carga.

## Descripción General

La simulación se basa en el ejemplo de "chargingstations" proporcionado por los tests de SUMO, y utiliza un script adicional en Python para extraer datos de las estaciones de carga y exportarlos a archivos Excel para su posterior análisis.

## Contenido de la Carpeta

- **`Descripcion.txt`**: Describe la base de la simulación utilizada, mencionando el uso de un ejemplo preexistente de SUMO y un script de Python para extraer información de las estaciones de carga y exportarla a Excel.
- **`input_routes.rou.xml`**: Define las rutas de los vehículos eléctricos, sus parámetros de comportamiento (aceleración, velocidad máxima, eficiencia de recuperación, etc.) y los puntos de parada en las estaciones de carga.
- **`input_additional.add.xml`**: Configura estaciones de carga adicionales en la red, especificando la ubicación, capacidad de carga, eficiencia y tiempos de retraso para iniciar la carga.
- **`net.net.xml`**: Archivo de definición de la red de tráfico, que incluye la configuración de las intersecciones, carriles, conexiones y otras características relevantes de la red vial simulada.
- **`output_stations.xlsx`**: Archivo Excel que contiene los datos recopilados de cada estación de carga durante la simulación.
- **`output_vehicles.xlsx`**: Archivo Excel que almacena los datos recopilados de los vehículos eléctricos durante la simulación, como el estado de la batería y el tiempo en cada estación.
- **`sumo_run.py`**: Script en Python que ejecuta la simulación de SUMO y extrae datos de las estaciones de carga y vehículos para su análisis.
- **`sumo.sumocfg`**: Archivo de configuración de SUMO que integra todos los elementos de la simulación, incluyendo la red, las rutas, y las estaciones de carga.

## Instrucciones de Uso

1. **Preparación del Entorno**:
   - Instala SUMO y asegúrate de que el comando `sumo` está disponible en tu terminal.
   - Asegúrate de tener Python instalado y las bibliotecas necesarias para la ejecución del script `sumo_run.py`.

2. **Ejecutar la Simulación**:
   - Ejecuta la simulación de SUMO usando el archivo de configuración:
   ```bash
   sumo -c sumo.sumocfg
    ```
## Analizar Resultados

Revisa los archivos `output_stations.xlsx` y `output_vehicles.xlsx` para analizar los datos de rendimiento de las estaciones de carga y los vehículos eléctricos.

## Archivos Clave

- **`sumo_run.py`**: Script principal que ejecuta la simulación y gestiona la exportación de datos.
- **`sumo.sumocfg`**: Archivo de configuración que coordina todos los elementos de la simulación.
- **Archivos XML** (`input_routes.rou.xml`, `input_additional.add.xml`, `net.net.xml`): Configuran las rutas, las estaciones de carga y la red de tráfico.

## Recursos Adicionales

- **[SUMO Documentation](https://sumo.dlr.de/docs/index.html)**: Documentación oficial de SUMO para entender cómo configurar y ejecutar simulaciones complejas.
