# Blockchain Deployment

Este directorio contiene scripts para desplegar la infraestructura de Blockchain utilizando Hyperledger Fabric en un entorno Kubernetes. El archivo principal, `deploy_cas.sh`, automatiza la configuración de los componentes necesarios, incluyendo la creación de Autoridades Certificadoras (CAs), nodos de pares (peers), nodos de orden (orderers), canales de transacción y despliegue de contratos inteligentes.

## Contenido del Archivo

### `deploy_cas.sh`

Este script se utiliza para configurar y desplegar la red de blockchain de Hyperledger Fabric. A continuación, se describen las principales secciones del script:

1. **Configuración de Variables de Entorno**:
   - Define las imágenes y versiones de los contenedores Docker para los nodos de pares (`peer`) y nodos de orden (`orderer`).

2. **Creación de Autoridades Certificadoras (CAs)**:
   - Configura las Autoridades Certificadoras (CA) para las organizaciones (`Org1` y `Org2`) utilizando `kubectl` y la herramienta `hlf` para gestionar la infraestructura de Fabric en Kubernetes. 
   - Espera a que todas las instancias de CA estén en estado "Running".

3. **Registro de Identidades de Peers**:
   - Registra identidades para los nodos de pares (peers) en las organizaciones (`Org1` y `Org2`).

4. **Creación de Nodos de Peers**:
   - Despliega nodos de peers para `Org1` y `Org2` con `CouchDB` como base de datos de estado. Configura cada peer con las credenciales correspondientes.

5. **Despliegue del Nodos de Orden (Orderers)**:
   - Configura y despliega nodos de orden (`orderers`) para gestionar las transacciones en la red. Incluye la creación de un canal principal (main channel) y canales adicionales según sea necesario.

6. **Gestión de Canales de Transacción**:
   - Crea y configura canales para la transacción de datos entre organizaciones. Incluye la creación de canales de seguidores (follower channels) para que otras organizaciones se unan a la red.

7. **Despliegue de Smart Contracts (Chaincode)**:
   - Instala y despliega contratos inteligentes (chaincode) en los peers utilizando `kubectl` y `hlf`. Incluye la aprobación de los contratos por parte de todas las organizaciones involucradas y la confirmación final del contrato en la red.

8. **Consulta e Invocación de Transacciones**:
   - Proporciona comandos para invocar transacciones en los contratos inteligentes y consultar el estado actual de la blockchain.

## Uso del Script

1. **Preparación del Entorno**:
   - Asegúrate de tener un entorno Kubernetes configurado con acceso a `kubectl` y las herramientas necesarias de `hlf`.

2. **Ejecución del Script**:
   - Ejecuta el script `deploy_cas.sh` en el entorno configurado para desplegar automáticamente la red de blockchain.

   ```bash
   bash deploy_cas.sh
    ```
