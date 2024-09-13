# Smart Contracts

Este directorio contiene el contrato inteligente (`newChaincodeGreen.go`) desarrollado para el proyecto GREEN, implementado en Go utilizando Hyperledger Fabric. El contrato inteligente define varias funciones para gestionar métricas y modelos en un ledger distribuido.

## Descripción del Contrato Inteligente

El contrato inteligente implementa funciones clave para inicializar y gestionar un ledger de blockchain que almacena métricas y modelos de datos. A continuación se detallan las funciones principales:

### Funciones del Contrato

1. **InitLedger**: 
   - Inicializa el ledger con un conjunto de métricas y modelos de ejemplo.
   - Esta función es normalmente llamada durante la configuración inicial del contrato inteligente para preparar el ledger con datos predeterminados.

2. **AddMetric**: 
   - Añade una nueva métrica al ledger.
   - Acepta como parámetros los detalles de la métrica que se desea añadir (como SHA, nombre, tipo, valor, y fecha de creación).

3. **GetAllMetrics**: 
   - Recupera todas las métricas almacenadas en el ledger.
   - Devuelve una lista completa de todas las métricas disponibles, útil para análisis y visualización.

4. **AddModel**: 
   - Añade un nuevo modelo al ledger.
   - Los modelos pueden incluir algoritmos o representaciones estadísticas que son relevantes para el proyecto.

5. **GetModel**: 
   - Recupera un modelo específico basado en su SHA.
   - Permite buscar un modelo concreto almacenado en el ledger mediante su identificador único (SHA).

6. **GetAllModels**: 
   - Obtiene todos los modelos almacenados en el ledger.
   - Devuelve una lista de todos los modelos registrados, permitiendo a los usuarios acceder a cualquier modelo disponible.

### Funciones Auxiliares

7. **getTLSProperties**: 
   - Configura las propiedades de TLS para el servidor del chaincode.
   - Asegura la comunicación segura en la red mediante la configuración adecuada de los certificados TLS.

8. **getEnvOrDefault**: 
   - Obtiene un valor de una variable de entorno o devuelve un valor por defecto si la variable no está establecida.
   - Facilita la configuración del entorno de ejecución del contrato inteligente.

9. **getBoolOrDefault**: 
   - Convierte un valor de string a booleano o devuelve un valor por defecto.
   - Utilizado para gestionar configuraciones booleanas en el entorno del contrato.

## Requisitos

- **Hyperledger Fabric**: Asegúrate de tener instalado y configurado Hyperledger Fabric.
- **Go Programming Language**: El contrato inteligente está implementado en Go, por lo que necesitarás Go instalado en tu sistema.
- **Docker**: Utilizado para la creación de contenedores de desarrollo y despliegue.

## Despliegue del Contrato Inteligente

Para desplegar este contrato inteligente en una red de Hyperledger Fabric, sigue estos pasos:

1. **Compila el Contrato Inteligente**:
   ```bash
   go mod tidy
   go build -o mychaincode
   ```
2. **Empaqueta el Contrato Inteligente**:
   ```bash
   peer lifecycle chaincode package mychaincode.tar.gz --path . --lang golang --label mychaincode_v1
   ```
3. **Instala el Contrato Inteligente en los Peers**:
   ```bash
   peer lifecycle chaincode install mychaincode.tar.gz
   ```
4. **Aprobar el Contrato Inteligente**: Utiliza los comandos de aprobación específicos de tu organización para aprobar el contrato en el canal correspondiente
5. **Confirmar y Ejecutar el Contrato Inteligente**: Después de que todas las organizaciones hayan aprobado el contrato inteligente, utiliza los comandos de confirmación para activarlo en la red.

## Archivos Relacionados

- **`Dockerfile`**: Configuración para construir una imagen Docker del contrato inteligente.
- **`go.mod`** y **`go.sum`**: Gestión de dependencias para el proyecto Go.
- **`mychaincode`**: Binario compilado del contrato inteligente.

