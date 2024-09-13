# Research

Esta carpeta contiene notebooks de Jupyter (`.ipynb`) utilizados para la investigación y experimentación en el proyecto GREEN. Los notebooks incluyen análisis detallados, pruebas de concepto y experimentos que exploran diferentes aspectos del proyecto, como:

## Contenido de los Notebooks

1. **`analysis.ipynb`**: 
   - Este notebook se centra en la búsqueda de relaciones entre las diferentes electrolineras para respaldar su clusterización según la zona. Incluye análisis de consumo de energía por horas y su distribución entre distintas estaciones de carga. Utiliza técnicas de visualización para identificar patrones de consumo.

2. **`clustering.ipynb`**:
   - Este notebook aborda la clusterización de estaciones de carga y estaciones meteorológicas utilizando datos geoespaciales. Se emplean datos de localización de estaciones de recarga y estaciones climáticas, así como técnicas de agrupamiento para identificar patrones espaciales y su relación con factores climáticos.

3. **`read_bcn_2.ipynb`**:
   - Enfocado en el análisis de datos históricos de carga de vehículos eléctricos en Barcelona, este notebook limpia y prepara los datos de carga, filtra información irrelevante y realiza un análisis exploratorio sobre el número de cargas y la energía consumida por estación de carga.

4. **`read_bcn.ipynb`**:
   - Similar al `read_bcn_2.ipynb`, este notebook también se centra en datos de carga de Barcelona, proporcionando un enfoque ligeramente diferente en la limpieza y preparación de los datos. Es útil para comparar diferentes enfoques de análisis de los mismos datos.

5. **`read_Colorado.ipynb`**:
   - Este notebook se centra en el análisis de datos de estaciones de carga en Colorado. Incluye funciones de visualización para analizar el consumo de energía en diferentes intervalos de tiempo y estaciones, así como la limpieza y transformación de los datos necesarios para el análisis.

6. **`read_data.ipynb`**:
   - Contiene análisis de datos de transacciones de carga de estaciones en París. El notebook incluye la lectura de datos, la limpieza de los mismos, y la preparación para su análisis, proporcionando visualizaciones y estadísticas descriptivas para entender el comportamiento de carga en la ciudad.


### Contenido

Cada notebook proporciona un enfoque específico o una prueba de concepto relacionada con los objetivos del proyecto. Puedes ejecutar estos notebooks localmente para replicar los experimentos y explorar los resultados.

### Requisitos

Para ejecutar los notebooks, asegúrate de tener instalado:
- Python 3.x
- Jupyter Notebook o Jupyter Lab
- Dependencias específicas indicadas en cada notebook

### Uso

1. Clona este repositorio:
    ```bash
    git clone https://github.com/hiiberia/GREEN.git
    ```
2. Navega a la carpeta `research`:
    ```bash
    cd GREEN/research
    ```
3. Abre el notebook de tu elección usando Jupyter:
    ```bash
    jupyter notebook nombre_del_notebook.ipynb
    ```
