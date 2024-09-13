# Data Repository

Este directorio contiene diversos conjuntos de datos utilizados para el análisis de consumo de electricidad y condiciones meteorológicas en diferentes ciudades, incluyendo Barcelona y varias ciudades principales de los Estados Unidos. Estos datos son fundamentales para las simulaciones y análisis del proyecto GREEN, que busca optimizar la infraestructura de recarga de vehículos eléctricos.

## Descripción de los Archivos de Datos

### Archivos de Barcelona

1. **`barcelona_daily_2018_12_31_to_2020_12_31_meteostat_net.csv`**:
   - Contiene datos meteorológicos diarios de Barcelona desde el 31 de diciembre de 2018 hasta el 31 de diciembre de 2020.
   - Las columnas incluyen información como la temperatura máxima y mínima, la precipitación, la velocidad del viento, y otros indicadores climáticos relevantes para cada día.

2. **`barcelona_hourly_2018_12_31_to_2020_12_31_meteostat_net.csv`**:
   - Contiene datos meteorológicos horarios de Barcelona para el mismo período (2018-2020).
   - Incluye medidas de temperatura, humedad, velocidad del viento, presión, y otras variables climáticas a nivel horario.

3. **`Bcn_1h.csv`**:
   - Proporciona datos agregados de carga eléctrica y consumo energético de Barcelona en intervalos de una hora.
   - Utilizado para analizar patrones de demanda eléctrica y correlacionarlos con condiciones meteorológicas.

4. **`Bcn_15min.csv`**:
   - Contiene datos de consumo eléctrico de Barcelona a intervalos de 15 minutos.
   - Este nivel de granularidad permite un análisis más detallado del comportamiento del consumo energético y su variación a lo largo del tiempo.

### Archivos de Ciudades de EE.UU.

1. **`us-top-10-cities-electricity-weather.csv`**:
   - Incluye datos combinados de consumo eléctrico y condiciones meteorológicas para las 10 principales ciudades de Estados Unidos.
   - Contiene información como el uso total de electricidad, precios de la electricidad, y métricas meteorológicas.

2. **`us-top-10-cities-electricity-weather-alta-demanda.csv`**:
   - Datos filtrados de las ciudades de EE.UU. con alta demanda de electricidad, incluyendo detalles sobre el consumo energético y las condiciones climáticas en períodos de alta demanda.

3. **`us-top-10-cities-electricity-weather-baja-demanda.csv`**:
   - Datos filtrados para las mismas ciudades de EE.UU. pero durante períodos de baja demanda de electricidad.

4. **`us-top-10-cities-electricity-weather-media-demanda.csv`**:
   - Datos correspondientes a períodos de demanda media en las principales ciudades de EE.UU.

5. **`us-top-10-cities-electricity-weather-interesantes.csv`**:
   - Un subconjunto de datos relevantes para análisis específicos de patrones de consumo y meteorología en las principales ciudades de EE.UU.

## Uso de los Datos

Estos archivos de datos se utilizan para:

- **Simulaciones de Consumo de Energía**: Proporcionan información necesaria para modelar y simular escenarios de consumo eléctrico en distintas ciudades.
- **Análisis Correlacional**: Permiten estudiar la relación entre las condiciones meteorológicas y la demanda de electricidad.
- **Optimización de Infraestructura de Carga**: Ayudan a determinar las mejores ubicaciones para las estaciones de recarga de vehículos eléctricos basadas en patrones de consumo energético.
