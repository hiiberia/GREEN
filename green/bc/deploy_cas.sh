export PEER_IMAGE=hyperledger/fabric-peer
export PEER_VERSION=2.4.6

export ORDERER_IMAGE=hyperledger/fabric-orderer
export ORDERER_VERSION=2.4.6


########################
# CAs Org 1 & Org 2
kubectl hlf ca create --storage-class=local-path --capacity=1Gi --name=org1-ca \
    --enroll-id=enroll --enroll-pw=enrollpw --hosts=org1-ca.green-bc --istio-port=443 -n green-bc
    
kubectl hlf ca create --storage-class=local-path --capacity=1Gi --name=org2-ca \
    --enroll-id=enroll --enroll-pw=enrollpw --hosts=org2-ca.green-bc --istio-port=443 -n green-bc

kubectl wait --timeout=180s -n green-bc --for=condition=Running fabriccas.hlf.kungfusoftware.es --all
########################


########################
# CAs Peers | Org1 & Org2 peer identities

kubectl hlf ca register --name=org1-ca --user=peer --secret=peerpw --type=peer \
 --enroll-id enroll --enroll-secret=enrollpw --mspid Org1MSP -n green-bc --ca-url https://org1-ca.green-bc:7054

kubectl hlf ca register --name=org2-ca --user=peer --secret=peerpw --type=peer \
 --enroll-id enroll --enroll-secret=enrollpw --mspid Org2MSP -n green-bc --ca-url https://org2-ca.green-bc:7054
 
########################


########################

kubectl hlf peer create --statedb=couchdb --image=$PEER_IMAGE --version=$PEER_VERSION --storage-class=local-path --enroll-id=peer --mspid=Org1MSP \
        --enroll-pw=peerpw --capacity=5Gi --name=org1-peer0 --ca-name=org1-ca.green-bc --ca-host=org1-ca.green-bc --ca-port=7054 \
        --hosts=org1-peer0.green-bc --istio-port=443 -n green-bc


kubectl hlf peer create --statedb=couchdb --image=$PEER_IMAGE --version=$PEER_VERSION --storage-class=local-path --enroll-id=peer --mspid=Org1MSP \
        --enroll-pw=peerpw --capacity=5Gi --name=org1-peer1 --ca-name=org1-ca.green-bc --ca-host=org1-ca.green-bc --ca-port=7054 \
        --hosts=org1-peer1.green-bc --istio-port=443 -n green-bc
        


kubectl hlf peer create --statedb=couchdb --image=$PEER_IMAGE --version=$PEER_VERSION --storage-class=local-path --enroll-id=peer --mspid=Org2MSP \
        --enroll-pw=peerpw --capacity=5Gi --name=org2-peer0 --ca-name=org2-ca.green-bc --ca-host=org2-ca.green-bc --ca-port=7054 \
        --hosts=org2-peer0.green-bc --istio-port=443 -n green-bc


kubectl hlf peer create --statedb=couchdb --image=$PEER_IMAGE --version=$PEER_VERSION --storage-class=local-path --enroll-id=peer --mspid=Org2MSP \
        --enroll-pw=peerpw --capacity=5Gi --name=org2-peer1 --ca-name=org2-ca.green-bc --ca-host=org2-ca.green-bc --ca-port=7054 \
        --hosts=org2-peer1.green-bc --istio-port=443 -n green-bc
        

kubectl wait --timeout=180s -n green-bc --for=condition=Running fabricpeers.hlf.kungfusoftware.es --all


##############################

##############################
# Deploy the Orderer


kubectl hlf ca create --storage-class=local-path --capacity=1Gi --name=ord-ca \
    --enroll-id=enroll --enroll-pw=enrollpw --hosts=ord-ca.green-bc --istio-port=443 -n green-bc


kubectl wait --timeout=180s --for=condition=Running fabriccas.hlf.kungfusoftware.es -n green-bc --all


##############################

kubectl hlf ca register --name=ord-ca --user=orderer --secret=ordererpw \
    --type=orderer --enroll-id enroll --enroll-secret=enrollpw --mspid=OrdererMSP --ca-url="https://ord-ca.green-bc:7054" -n green-bc


##############################


kubectl hlf ordnode create --image=$ORDERER_IMAGE --version=$ORDERER_VERSION \
    --storage-class=local-path --enroll-id=orderer --mspid=OrdererMSP --ca-host=ord-ca.green-bc --ca-port=7054 \
    --enroll-pw=ordererpw --capacity=2Gi --name=ord-node1 --ca-name=ord-ca.green-bc \
    --hosts=ord-node1.green-bc --istio-port=443 -n green-bc

kubectl wait --timeout=180s --for=condition=Running fabricorderernodes.hlf.kungfusoftware.es -n green-bc --all


############################
# Prepare connection string

kubectl hlf inspect --output ordservice.yaml -o OrdererMSP # Cambiar los endpoints de CA

kubectl hlf ca register --name=ord-ca --user=admin --secret=adminpw \
    --type=admin --enroll-id enroll --enroll-secret=enrollpw --mspid=OrdererMSP --ca-url="https://ord-ca.green-bc:7054" -n green-bc
    
kubectl hlf ca enroll --name=ord-ca --user=admin --secret=adminpw --mspid OrdererMSP \
        --ca-name ca  --output admin-ordservice.yaml --ca-url="https://ord-ca.green-bc:7054" -n green-bc
        
kubectl hlf utils adduser --userPath=admin-ordservice.yaml --config=ordservice.yaml --username=admin --mspid=OrdererMSP


############################
# Crear un canal

kubectl hlf ca enroll --name=ord-ca --namespace=green-bc \
    --user=admin --secret=adminpw --mspid OrdererMSP \
    --ca-name tlsca  --output orderermsp.yaml  --ca-url="https://ord-ca.green-bc:7054" -n green-bc


## Org1
kubectl hlf ca register --name=org1-ca --namespace=green-bc --user=admin --secret=adminpw \
    --type=admin --enroll-id enroll --enroll-secret=enrollpw --mspid=Org1MSP --ca-url="https://org1-ca.green-bc:7054" -n green-bc

kubectl hlf ca enroll --name=org1-ca --namespace=green-bc \
    --user=admin --secret=adminpw --mspid Org1MSP \
    --ca-name ca  --output org1msp.yaml --ca-url="https://org1-ca.green-bc:7054" -n green-bc

## Org2
kubectl hlf ca register --name=org2-ca --namespace=green-bc --user=admin --secret=adminpw \
    --type=admin --enroll-id enroll --enroll-secret=enrollpw --mspid=Org2MSP --ca-url="https://org2-ca.green-bc:7054" -n green-bc

kubectl hlf ca enroll --name=org2-ca --namespace=green-bc \
    --user=admin --secret=adminpw --mspid Org2MSP \
    --ca-name ca  --output org2msp.yaml --ca-url="https://org2-ca.green-bc:7054" -n green-bc
    
## Create secret
kubectl create secret generic wallet --namespace=green-bc \
        --from-file=org1msp.yaml=$PWD/org1msp.yaml \
        --from-file=org2msp.yaml=$PWD/org2msp.yaml \
        --from-file=orderermsp.yaml=$PWD/orderermsp.yaml
        
        
## Main Channel
export PEER_ORG_SIGN_CERT=$(kubectl get -n green-bc fabriccas org1-ca -o=jsonpath='{.status.ca_cert}')
export PEER_ORG_TLS_CERT=$(kubectl get -n green-bc fabriccas org1-ca -o=jsonpath='{.status.tlsca_cert}')
export IDENT_8=$(printf "%8s" "")
export ORDERER_TLS_CERT=$(kubectl get -n green-bc fabriccas ord-ca -o=jsonpath='{.status.tlsca_cert}' | sed -e "s/^/${IDENT_8}/" )
export ORDERER0_TLS_CERT=$(kubectl get -n green-bc fabricorderernodes ord-node1 -o=jsonpath='{.status.tlsCert}' | sed -e "s/^/${IDENT_8}/" )
echo "PEER_ORG_SIGN_CERT=$PEER_ORG_SIGN_CERT"
echo "PEER_ORG_TLS_CERT=$PEER_ORG_TLS_CERT"
echo "ORDERER_TLS_CERT=$ORDERER_TLS_CERT"
echo "ORDERER0_TLS_CERT=$ORDERER0_TLS_CERT"

kubectl apply -n green-bc -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricMainChannel
metadata:
  name: demo
spec:
  name: demo
  adminOrdererOrganizations:
    - mspID: OrdererMSP
  adminPeerOrganizations:
    - mspID: Org1MSP
  channelConfig:
    application:
      acls: null
      capabilities:
        - V2_0
      policies: null
    capabilities:
      - V2_0
    orderer:
      batchSize:
        absoluteMaxBytes: 1048576
        maxMessageCount: 10
        preferredMaxBytes: 524288
      batchTimeout: 2s
      capabilities:
        - V2_0
      etcdRaft:
        options:
          electionTick: 10
          heartbeatTick: 1
          maxInflightBlocks: 5
          snapshotIntervalSize: 16777216
          tickInterval: 500ms
      ordererType: etcdraft
      policies: null
      state: STATE_NORMAL
    policies: null
  externalOrdererOrganizations: []
  peerOrganizations:
    - mspID: Org1MSP
      caName: "org1-ca"
      caNamespace: "green-bc"
    - mspID: Org2MSP
      caName: "org2-ca"
      caNamespace: "green-bc"
  identities:
    OrdererMSP:
      secretKey: orderermsp.yaml
      secretName: wallet
      secretNamespace: green-bc
    Org1MSP:
      secretKey: org1msp.yaml
      secretName: wallet
      secretNamespace: green-bc
    Org2MSP:
      secretKey: org2msp.yaml
      secretName: wallet
      secretNamespace: green-bc
  externalPeerOrganizations: []
  ordererOrganizations:
    - caName: "ord-ca"
      caNamespace: "green-bc"
      externalOrderersToJoin:
        - host: ord-node1
          port: 7053
      mspID: OrdererMSP
      ordererEndpoints:
        - ord-node1:7050
      orderersToJoin: []
  orderers:
    - host: ord-node1
      port: 7050
      tlsCert: |-
${ORDERER0_TLS_CERT}

EOF

# Follower channel - Org1

export IDENT_8=$(printf "%8s" "")
export ORDERER0_TLS_CERT=$(kubectl get fabricorderernodes -n green-bc ord-node1 -o=jsonpath='{.status.tlsCert}' | sed -e "s/^/${IDENT_8}/" )

kubectl apply -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricFollowerChannel
metadata:
  name: demo-org1msp
spec:
  anchorPeers:
    - host: org1-peer0.green-bc
      port: 7051
  hlfIdentity:
    secretKey: org1msp.yaml
    secretName: wallet
    secretNamespace: green-bc
  mspId: Org1MSP
  name: demo
  externalPeersToJoin: []
  orderers:
    - certificate: |
${ORDERER0_TLS_CERT}
      url: grpcs://ord-node1.green-bc:7050
  peersToJoin:
    - name: org1-peer0
      namespace: green-bc
    - name: org1-peer1
      namespace: green-bc
EOF



#############################
# Prepare

kubectl hlf inspect --output org1.yaml -o Org1MSP -o OrdererMSP # Cambiar los *ca.green-bc:443 -> *ca.green-bc:7054


kubectl hlf ca enroll --name=org1-ca --user=admin --secret=adminpw --mspid Org1MSP \
        --ca-name ca  --output peer-org1.yaml -n green-bc --ca-url="https://org1-ca.green-bc:7054" --namespace=green-bc 

       
kubectl hlf utils adduser --userPath=peer-org1.yaml --config=org1.yaml --username=admin --mspid=Org1MSP


##############################
# Chaincode Gen

# bash gen_chaincode_files.sh


export PACKAGE_ID=$(kubectl hlf chaincode calculatepackageid --path=chaincode.tgz --language=node --label=$CHAINCODE_LABEL)
echo "PACKAGE_ID=$PACKAGE_ID"
export CHAINCODE_NAME=asset
export CHAINCODE_LABEL=asset


kubectl hlf chaincode install --path=./chaincode.tgz \
    --config=org1.yaml --language=golang --label=$CHAINCODE_LABEL --user=admin --peer=org1-peer0.green-bc
    
kubectl hlf chaincode install --path=./chaincode.tgz \
    --config=org1.yaml --language=golang --label=$CHAINCODE_LABEL --user=admin --peer=org1-peer1.green-bc
    
#########################
# Deploy CaS

kubectl hlf externalchaincode sync --image=kfsoftware/chaincode-external:latest \
    --ca-name org1-ca \
    --ca-namespace green-bc \
    --enroll-id enroll \
    --enroll-secret enrollpw \
    --name=$CHAINCODE_NAME \
    --namespace=green-bc \
    --package-id=$PACKAGE_ID \
    --tls-required=false \
    --replicas=1
    
    
# Query installed

kubectl hlf chaincode queryinstalled --config=org1.yaml --user=admin --peer=org1-peer0.green-bc


# Approve Chaincode
export SEQUENCE=8
export VERSION="1.7"
kubectl hlf chaincode approveformyorg --config=org1.yaml --user=admin --peer=org1-peer0.green-bc \
    --package-id=$PACKAGE_ID \
    --version "$VERSION" --sequence "$SEQUENCE" --name=asset \
    --policy="OR('Org1MSP.member')" --channel=demo
    
# Commit Chaincode

kubectl hlf chaincode commit --config=org1.yaml --user=admin --mspid=Org1MSP \
    --version "$VERSION" --sequence "$SEQUENCE" --name=asset \
    --policy="OR('Org1MSP.member')" --channel=demo
    
# Invoke Transaction
kubectl hlf chaincode invoke --config=org1.yaml \
    --user=admin --peer=org1-peer0.green-bc \
    --chaincode=asset --channel=demo \
    --fcn=initLedger -a '[]'
    
# Query
kubectl hlf chaincode query --config=org1.yaml \
    --user=admin --peer=org1-peer0.green-bc \
    --chaincode=asset --channel=demo \
    --fcn=GetAllAssets -a '[]'
    
    
    
# Follower channel - Org2

export IDENT_8=$(printf "%8s" "")
export ORDERER0_TLS_CERT=$(kubectl get fabricorderernodes -n green-bc ord-node1 -o=jsonpath='{.status.tlsCert}' | sed -e "s/^/${IDENT_8}/" )

kubectl apply -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricFollowerChannel
metadata:
  name: demo-org2msp
spec:
  anchorPeers:
    - host: org2-peer0.green-bc
      port: 7051
  hlfIdentity:
    secretKey: org2msp.yaml
    secretName: wallet
    secretNamespace: green-bc
  mspId: Org2MSP
  name: demo
  externalPeersToJoin: []
  orderers:
    - certificate: |
${ORDERER0_TLS_CERT}
      url: grpcs://ord-node1.green-bc:7050
  peersToJoin:
    - name: org2-peer0
      namespace: green-bc
    - name: org2-peer1
      namespace: green-bc
EOF


#############################
# Prepare

kubectl hlf inspect --output org2.yaml -o Org2MSP -o OrdererMSP # Cambiar los *ca.green-bc:443 -> *ca.green-bc:7054


kubectl hlf ca enroll --name=org2-ca --user=admin --secret=adminpw --mspid Org2MSP \
        --ca-name ca  --output peer-org2.yaml -n green-bc --ca-url="https://org2-ca.green-bc:7054" --namespace=green-bc 

       
kubectl hlf utils adduser --userPath=peer-org2.yaml --config=org2.yaml --username=admin --mspid=Org2MSP



##############################
# Chaincode Gen

# bash gen_chaincode_files.sh


export PACKAGE_ID=$(kubectl hlf chaincode calculatepackageid --path=chaincode.tgz --language=node --label=$CHAINCODE_LABEL)
echo "PACKAGE_ID=$PACKAGE_ID"
export CHAINCODE_NAME=asset
export CHAINCODE_LABEL=asset


kubectl hlf chaincode install --path=./chaincode.tgz \
    --config=org2.yaml --language=golang --label=$CHAINCODE_LABEL --user=admin --peer=org2-peer0.green-bc
    
kubectl hlf chaincode install --path=./chaincode.tgz \
    --config=org2.yaml --language=golang --label=$CHAINCODE_LABEL --user=admin --peer=org2-peer1.green-bc
    
    
    
# Query installed

kubectl hlf chaincode queryinstalled --config=org2.yaml --user=admin --peer=org2-peer0.green-bc


# Approve Chaincode
export SEQUENCE=8
export VERSION="1.8"
kubectl hlf chaincode approveformyorg --config=org2.yaml --user=admin --peer=org2-peer0.green-bc \
    --package-id=$PACKAGE_ID \
    --version "$VERSION" --sequence "$SEQUENCE" --name=asset \
    --policy="OR('Org1MSP.member')" --channel=demo
    
    
###################
# AMPLIAR LA RED A 5 ORGs
###################
# CAs Org 3 & Org 4 & Org 5
kubectl hlf ca create --storage-class=local-path --capacity=1Gi --name=org3-ca \
    --enroll-id=enroll --enroll-pw=enrollpw --hosts=org3-ca.green-bc --istio-port=443 -n green-bc
    
kubectl hlf ca create --storage-class=local-path --capacity=1Gi --name=org4-ca \
    --enroll-id=enroll --enroll-pw=enrollpw --hosts=org4-ca.green-bc --istio-port=443 -n green-bc
    
kubectl hlf ca create --storage-class=local-path --capacity=1Gi --name=org5-ca \
    --enroll-id=enroll --enroll-pw=enrollpw --hosts=org5-ca.green-bc --istio-port=443 -n green-bc

kubectl wait --timeout=180s -n green-bc --for=condition=Running fabriccas.hlf.kungfusoftware.es --all


####

kubectl hlf ca register --name=org3-ca --user=peer --secret=peerpw --type=peer \
 --enroll-id enroll --enroll-secret=enrollpw --mspid Org3MSP -n green-bc --ca-url https://org3-ca.green-bc:7054

kubectl hlf ca register --name=org4-ca --user=peer --secret=peerpw --type=peer \
 --enroll-id enroll --enroll-secret=enrollpw --mspid Org4MSP -n green-bc --ca-url https://org4-ca.green-bc:7054
 
kubectl hlf ca register --name=org5-ca --user=peer --secret=peerpw --type=peer \
 --enroll-id enroll --enroll-secret=enrollpw --mspid Org5MSP -n green-bc --ca-url https://org5-ca.green-bc:7054
 
 
####


kubectl hlf peer create --statedb=couchdb --image=$PEER_IMAGE --version=$PEER_VERSION --storage-class=local-path --enroll-id=peer --mspid=Org3MSP \
        --enroll-pw=peerpw --capacity=5Gi --name=org3-peer0 --ca-name=org3-ca.green-bc --ca-host=org3-ca.green-bc --ca-port=7054 \
        --hosts=org3-peer0.green-bc --istio-port=443 -n green-bc


kubectl hlf peer create --statedb=couchdb --image=$PEER_IMAGE --version=$PEER_VERSION --storage-class=local-path --enroll-id=peer --mspid=Org3MSP \
        --enroll-pw=peerpw --capacity=5Gi --name=org3-peer1 --ca-name=org3-ca.green-bc --ca-host=org3-ca.green-bc --ca-port=7054 \
        --hosts=org3-peer1.green-bc --istio-port=443 -n green-bc
        


kubectl hlf peer create --statedb=couchdb --image=$PEER_IMAGE --version=$PEER_VERSION --storage-class=local-path --enroll-id=peer --mspid=Org4MSP \
        --enroll-pw=peerpw --capacity=5Gi --name=org4-peer0 --ca-name=org4-ca.green-bc --ca-host=org4-ca.green-bc --ca-port=7054 \
        --hosts=org4-peer0.green-bc --istio-port=443 -n green-bc


kubectl hlf peer create --statedb=couchdb --image=$PEER_IMAGE --version=$PEER_VERSION --storage-class=local-path --enroll-id=peer --mspid=Org4MSP \
        --enroll-pw=peerpw --capacity=5Gi --name=org4-peer1 --ca-name=org4-ca.green-bc --ca-host=org4-ca.green-bc --ca-port=7054 \
        --hosts=org4-peer1.green-bc --istio-port=443 -n green-bc
        
        
kubectl hlf peer create --statedb=couchdb --image=$PEER_IMAGE --version=$PEER_VERSION --storage-class=local-path --enroll-id=peer --mspid=Org5MSP \
        --enroll-pw=peerpw --capacity=5Gi --name=org5-peer0 --ca-name=org5-ca.green-bc --ca-host=org5-ca.green-bc --ca-port=7054 \
        --hosts=org5-peer0.green-bc --istio-port=443 -n green-bc


kubectl hlf peer create --statedb=couchdb --image=$PEER_IMAGE --version=$PEER_VERSION --storage-class=local-path --enroll-id=peer --mspid=Org5MSP \
        --enroll-pw=peerpw --capacity=5Gi --name=org5-peer1 --ca-name=org5-ca.green-bc --ca-host=org5-ca.green-bc --ca-port=7054 \
        --hosts=org5-peer1.green-bc --istio-port=443 -n green-bc
        
        

        

kubectl wait --timeout=180s -n green-bc --for=condition=Running fabricpeers.hlf.kungfusoftware.es --all

#######
# Create secrets

## Org3
kubectl hlf ca register --name=org3-ca --namespace=green-bc --user=admin --secret=adminpw \
    --type=admin --enroll-id enroll --enroll-secret=enrollpw --mspid=Org3MSP --ca-url="https://org3-ca.green-bc:7054" -n green-bc

kubectl hlf ca enroll --name=org3-ca --namespace=green-bc \
    --user=admin --secret=adminpw --mspid org3MSP \
    --ca-name ca  --output org3msp.yaml --ca-url="https://org3-ca.green-bc:7054" -n green-bc

## Org4
kubectl hlf ca register --name=org4-ca --namespace=green-bc --user=admin --secret=adminpw \
    --type=admin --enroll-id enroll --enroll-secret=enrollpw --mspid=Org4MSP --ca-url="https://org4-ca.green-bc:7054" -n green-bc

kubectl hlf ca enroll --name=org4-ca --namespace=green-bc \
    --user=admin --secret=adminpw --mspid org4MSP \
    --ca-name ca  --output org4msp.yaml --ca-url="https://org4-ca.green-bc:7054" -n green-bc
    
## Org5
kubectl hlf ca register --name=org5-ca --namespace=green-bc --user=admin --secret=adminpw \
    --type=admin --enroll-id enroll --enroll-secret=enrollpw --mspid=org5MSP --ca-url="https://org5-ca.green-bc:7054" -n green-bc

kubectl hlf ca enroll --name=org5-ca --namespace=green-bc \
    --user=admin --secret=adminpw --mspid org5MSP \
    --ca-name ca  --output org5msp.yaml --ca-url="https://org5-ca.green-bc:7054" -n green-bc
    
    
## Create secret
kubectl create secret generic wallet --namespace=green-bc \
        --from-file=org1msp.yaml=$PWD/org1msp.yaml \
        --from-file=org2msp.yaml=$PWD/org2msp.yaml \
        --from-file=org3msp.yaml=$PWD/org3msp.yaml \
        --from-file=org4msp.yaml=$PWD/org4msp.yaml \
        --from-file=org5msp.yaml=$PWD/org5msp.yaml \
        --from-file=orderermsp.yaml=$PWD/orderermsp.yaml



#######
# Update the channel

export PEER_ORG_SIGN_CERT=$(kubectl get -n green-bc fabriccas org1-ca -o=jsonpath='{.status.ca_cert}')
export PEER_ORG_TLS_CERT=$(kubectl get -n green-bc fabriccas org1-ca -o=jsonpath='{.status.tlsca_cert}')
export IDENT_8=$(printf "%8s" "")
export ORDERER_TLS_CERT=$(kubectl get -n green-bc fabriccas ord-ca -o=jsonpath='{.status.tlsca_cert}' | sed -e "s/^/${IDENT_8}/" )
export ORDERER0_TLS_CERT=$(kubectl get -n green-bc fabricorderernodes ord-node1 -o=jsonpath='{.status.tlsCert}' | sed -e "s/^/${IDENT_8}/" )
echo "PEER_ORG_SIGN_CERT=$PEER_ORG_SIGN_CERT"
echo "PEER_ORG_TLS_CERT=$PEER_ORG_TLS_CERT"
echo "ORDERER_TLS_CERT=$ORDERER_TLS_CERT"
echo "ORDERER0_TLS_CERT=$ORDERER0_TLS_CERT"

kubectl apply -n green-bc -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricMainChannel
metadata:
  name: electrolineras-rapidas
spec:
  name: electrolineras-rapidas
  adminOrdererOrganizations:
    - mspID: OrdererMSP
  adminPeerOrganizations:
    - mspID: Org1MSP
  channelConfig:
    application:
      acls: null
      capabilities:
        - V2_0
      policies: null
    capabilities:
      - V2_0
    orderer:
      batchSize:
        absoluteMaxBytes: 1048576
        maxMessageCount: 10
        preferredMaxBytes: 524288
      batchTimeout: 2s
      capabilities:
        - V2_0
      etcdRaft:
        options:
          electionTick: 10
          heartbeatTick: 1
          maxInflightBlocks: 5
          snapshotIntervalSize: 16777216
          tickInterval: 500ms
      ordererType: etcdraft
      policies: null
      state: STATE_NORMAL
    policies: null
  externalOrdererOrganizations: []
  peerOrganizations:
    - mspID: Org1MSP
      caName: "org1-ca"
      caNamespace: "green-bc"
    - mspID: Org2MSP
      caName: "org2-ca"
      caNamespace: "green-bc"
    - mspID: Org3MSP
      caName: "org3-ca"
      caNamespace: "green-bc"
    - mspID: Org4MSP
      caName: "org4-ca"
      caNamespace: "green-bc"
    - mspID: Org5MSP
      caName: "org5-ca"
      caNamespace: "green-bc"
  identities:
    OrdererMSP:
      secretKey: orderermsp.yaml
      secretName: wallet
      secretNamespace: green-bc
    Org1MSP:
      secretKey: org1msp.yaml
      secretName: wallet
      secretNamespace: green-bc
    Org2MSP:
      secretKey: org2msp.yaml
      secretName: wallet
      secretNamespace: green-bc
    Org3MSP:
      secretKey: org3msp.yaml
      secretName: wallet
      secretNamespace: green-bc
    Org4MSP:
      secretKey: org4msp.yaml
      secretName: wallet
      secretNamespace: green-bc
    Org5MSP:
      secretKey: org5msp.yaml
      secretName: wallet
      secretNamespace: green-bc
  externalPeerOrganizations: []
  ordererOrganizations:
    - caName: "ord-ca"
      caNamespace: "green-bc"
      externalOrderersToJoin:
        - host: ord-node1
          port: 7053
      mspID: OrdererMSP
      ordererEndpoints:
        - ord-node1:7050
      orderersToJoin: []
  orderers:
    - host: ord-node1
      port: 7050
      tlsCert: |-
${ORDERER0_TLS_CERT}

EOF

kubectl apply -n green-bc -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricMainChannel
metadata:
  name: electrolineras-lentas
spec:
  name: electrolineras-lentas
  adminOrdererOrganizations:
    - mspID: OrdererMSP
  adminPeerOrganizations:
    - mspID: Org1MSP
  channelConfig:
    application:
      acls: null
      capabilities:
        - V2_0
      policies: null
    capabilities:
      - V2_0
    orderer:
      batchSize:
        absoluteMaxBytes: 1048576
        maxMessageCount: 10
        preferredMaxBytes: 524288
      batchTimeout: 2s
      capabilities:
        - V2_0
      etcdRaft:
        options:
          electionTick: 10
          heartbeatTick: 1
          maxInflightBlocks: 5
          snapshotIntervalSize: 16777216
          tickInterval: 500ms
      ordererType: etcdraft
      policies: null
      state: STATE_NORMAL
    policies: null
  externalOrdererOrganizations: []
  peerOrganizations:
    - mspID: Org1MSP
      caName: "org1-ca"
      caNamespace: "green-bc"
    - mspID: Org2MSP
      caName: "org2-ca"
      caNamespace: "green-bc"
    - mspID: Org3MSP
      caName: "org3-ca"
      caNamespace: "green-bc"
    - mspID: Org4MSP
      caName: "org4-ca"
      caNamespace: "green-bc"
    - mspID: Org5MSP
      caName: "org5-ca"
      caNamespace: "green-bc"
  identities:
    OrdererMSP:
      secretKey: orderermsp.yaml
      secretName: wallet
      secretNamespace: green-bc
    Org1MSP:
      secretKey: org1msp.yaml
      secretName: wallet
      secretNamespace: green-bc
    Org2MSP:
      secretKey: org2msp.yaml
      secretName: wallet
      secretNamespace: green-bc
    Org3MSP:
      secretKey: org3msp.yaml
      secretName: wallet
      secretNamespace: green-bc
    Org4MSP:
      secretKey: org4msp.yaml
      secretName: wallet
      secretNamespace: green-bc
    Org5MSP:
      secretKey: org5msp.yaml
      secretName: wallet
      secretNamespace: green-bc
  externalPeerOrganizations: []
  ordererOrganizations:
    - caName: "ord-ca"
      caNamespace: "green-bc"
      externalOrderersToJoin:
        - host: ord-node1
          port: 7053
      mspID: OrdererMSP
      ordererEndpoints:
        - ord-node1:7050
      orderersToJoin: []
  orderers:
    - host: ord-node1
      port: 7050
      tlsCert: |-
${ORDERER0_TLS_CERT}

EOF


# Follower channel - Org1

export IDENT_8=$(printf "%8s" "")
export ORDERER0_TLS_CERT=$(kubectl get fabricorderernodes -n green-bc ord-node1 -o=jsonpath='{.status.tlsCert}' | sed -e "s/^/${IDENT_8}/" )

kubectl apply -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricFollowerChannel
metadata:
  name: electrolineras-rapidas-org1msp
spec:
  anchorPeers:
    - host: org1-peer0.green-bc
      port: 7051
  hlfIdentity:
    secretKey: org1msp.yaml
    secretName: wallet
    secretNamespace: green-bc
  mspId: Org1MSP
  name: electrolineras-rapidas
  externalPeersToJoin: []
  orderers:
    - certificate: |
${ORDERER0_TLS_CERT}
      url: grpcs://ord-node1.green-bc:7050
  peersToJoin:
    - name: org1-peer0
      namespace: green-bc
    - name: org1-peer1
      namespace: green-bc
EOF

kubectl apply -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricFollowerChannel
metadata:
  name: electrolineras-lentas-org1msp
spec:
  anchorPeers:
    - host: org1-peer0.green-bc
      port: 7051
  hlfIdentity:
    secretKey: org1msp.yaml
    secretName: wallet
    secretNamespace: green-bc
  mspId: Org1MSP
  name: electrolineras-lentas
  externalPeersToJoin: []
  orderers:
    - certificate: |
${ORDERER0_TLS_CERT}
      url: grpcs://ord-node1.green-bc:7050
  peersToJoin:
    - name: org1-peer0
      namespace: green-bc
    - name: org1-peer1
      namespace: green-bc
EOF

#### Org2

kubectl apply -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricFollowerChannel
metadata:
  name: electrolineras-rapidas-org2msp
spec:
  anchorPeers:
    - host: org2-peer0.green-bc
      port: 7051
  hlfIdentity:
    secretKey: org2msp.yaml
    secretName: wallet
    secretNamespace: green-bc
  mspId: Org2MSP
  name: electrolineras-rapidas
  externalPeersToJoin: []
  orderers:
    - certificate: |
${ORDERER0_TLS_CERT}
      url: grpcs://ord-node1.green-bc:7050
  peersToJoin:
    - name: org2-peer0
      namespace: green-bc
    - name: org2-peer1
      namespace: green-bc
EOF

kubectl apply -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricFollowerChannel
metadata:
  name: electrolineras-lentas-org2msp
spec:
  anchorPeers:
    - host: org2-peer0.green-bc
      port: 7051
  hlfIdentity:
    secretKey: org2msp.yaml
    secretName: wallet
    secretNamespace: green-bc
  mspId: Org2MSP
  name: electrolineras-lentas
  externalPeersToJoin: []
  orderers:
    - certificate: |
${ORDERER0_TLS_CERT}
      url: grpcs://ord-node1.green-bc:7050
  peersToJoin:
    - name: org2-peer0
      namespace: green-bc
    - name: org2-peer1
      namespace: green-bc
EOF

### Org3

kubectl apply -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricFollowerChannel
metadata:
  name: electrolineras-rapidas-org3msp
spec:
  anchorPeers:
    - host: org3-peer0.green-bc
      port: 7051
  hlfIdentity:
    secretKey: org3msp.yaml
    secretName: wallet
    secretNamespace: green-bc
  mspId: Org3MSP
  name: electrolineras-rapidas
  externalPeersToJoin: []
  orderers:
    - certificate: |
${ORDERER0_TLS_CERT}
      url: grpcs://ord-node1.green-bc:7050
  peersToJoin:
    - name: org3-peer0
      namespace: green-bc
    - name: org3-peer1
      namespace: green-bc
EOF

kubectl apply -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricFollowerChannel
metadata:
  name: electrolineras-lentas-org3msp
spec:
  anchorPeers:
    - host: org3-peer0.green-bc
      port: 7051
  hlfIdentity:
    secretKey: org3msp.yaml
    secretName: wallet
    secretNamespace: green-bc
  mspId: Org3MSP
  name: electrolineras-lentas
  externalPeersToJoin: []
  orderers:
    - certificate: |
${ORDERER0_TLS_CERT}
      url: grpcs://ord-node1.green-bc:7050
  peersToJoin:
    - name: org3-peer0
      namespace: green-bc
    - name: org3-peer1
      namespace: green-bc
EOF


### Org4

kubectl apply -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricFollowerChannel
metadata:
  name: electrolineras-rapidas-org4msp
spec:
  anchorPeers:
    - host: org4-peer0.green-bc
      port: 7051
  hlfIdentity:
    secretKey: org4msp.yaml
    secretName: wallet
    secretNamespace: green-bc
  mspId: Org4MSP
  name: electrolineras-rapidas
  externalPeersToJoin: []
  orderers:
    - certificate: |
${ORDERER0_TLS_CERT}
      url: grpcs://ord-node1.green-bc:7050
  peersToJoin:
    - name: org4-peer0
      namespace: green-bc
    - name: org4-peer1
      namespace: green-bc
EOF

kubectl apply -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricFollowerChannel
metadata:
  name: electrolineras-lentas-org4msp
spec:
  anchorPeers:
    - host: org4-peer0.green-bc
      port: 7051
  hlfIdentity:
    secretKey: org4msp.yaml
    secretName: wallet
    secretNamespace: green-bc
  mspId: Org4MSP
  name: electrolineras-lentas
  externalPeersToJoin: []
  orderers:
    - certificate: |
${ORDERER0_TLS_CERT}
      url: grpcs://ord-node1.green-bc:7050
  peersToJoin:
    - name: org4-peer0
      namespace: green-bc
    - name: org4-peer1
      namespace: green-bc
EOF


### Org5

kubectl apply -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricFollowerChannel
metadata:
  name: electrolineras-rapidas-org5msp
spec:
  anchorPeers:
    - host: org5-peer0.green-bc
      port: 7051
  hlfIdentity:
    secretKey: org5msp.yaml
    secretName: wallet
    secretNamespace: green-bc
  mspId: Org5MSP
  name: electrolineras-rapidas
  externalPeersToJoin: []
  orderers:
    - certificate: |
${ORDERER0_TLS_CERT}
      url: grpcs://ord-node1.green-bc:7050
  peersToJoin:
    - name: org5-peer0
      namespace: green-bc
    - name: org5-peer1
      namespace: green-bc
EOF

kubectl apply -f - <<EOF
apiVersion: hlf.kungfusoftware.es/v1alpha1
kind: FabricFollowerChannel
metadata:
  name: electrolineras-lentas-org5msp
spec:
  anchorPeers:
    - host: org5-peer0.green-bc
      port: 7051
  hlfIdentity:
    secretKey: org5msp.yaml
    secretName: wallet
    secretNamespace: green-bc
  mspId: Org5MSP
  name: electrolineras-lentas
  externalPeersToJoin: []
  orderers:
    - certificate: |
${ORDERER0_TLS_CERT}
      url: grpcs://ord-node1.green-bc:7050
  peersToJoin:
    - name: org5-peer0
      namespace: green-bc
    - name: org5-peer1
      namespace: green-bc
EOF


####################
# Prepare connection strings

# Org3

kubectl hlf inspect --output org3.yaml -o Org3MSP -o OrdererMSP # Cambiar los *ca.green-bc:443 -> *ca.green-bc:7054


kubectl hlf ca enroll --name=org3-ca --user=admin --secret=adminpw --mspid Org3MSP \
        --ca-name ca  --output peer-org3.yaml -n green-bc --ca-url="https://org3-ca.green-bc:7054" --namespace=green-bc 

       
kubectl hlf utils adduser --userPath=peer-org3.yaml --config=org3.yaml --username=admin --mspid=Org3MSP
sed -i 's/ca\.green-bc:443/ca\.green-bc:7054/g' org3.yaml


# Org4

kubectl hlf inspect --output org4.yaml -o Org4MSP -o OrdererMSP # Cambiar los *ca.green-bc:443 -> *ca.green-bc:7054


kubectl hlf ca enroll --name=org4-ca --user=admin --secret=adminpw --mspid Org4MSP \
        --ca-name ca  --output peer-org4.yaml -n green-bc --ca-url="https://org4-ca.green-bc:7054" --namespace=green-bc 

       
kubectl hlf utils adduser --userPath=peer-org4.yaml --config=org4.yaml --username=admin --mspid=Org4MSP
sed -i 's/ca\.green-bc:443/ca\.green-bc:7054/g' org4.yaml

# Org5
kubectl hlf inspect --output org5.yaml -o Org5MSP -o OrdererMSP # Cambiar los *ca.green-bc:443 -> *ca.green-bc:7054


kubectl hlf ca enroll --name=org5-ca --user=admin --secret=adminpw --mspid Org5MSP \
        --ca-name ca  --output peer-org5.yaml -n green-bc --ca-url="https://org5-ca.green-bc:7054" --namespace=green-bc 

       
kubectl hlf utils adduser --userPath=peer-org5.yaml --config=org5.yaml --username=admin --mspid=Org5MSP
sed -i 's/ca\.green-bc:443/ca\.green-bc:7054/g' org5.yaml


############

export PACKAGE_ID=$(kubectl hlf chaincode calculatepackageid --path=chaincode.tgz --language=node --label=$CHAINCODE_LABEL)
echo "PACKAGE_ID=$PACKAGE_ID"
export CHAINCODE_NAME=asset
export CHAINCODE_LABEL=asset


kubectl hlf chaincode install --path=./chaincode.tgz \
    --config=org3.yaml --language=golang --label=$CHAINCODE_LABEL --user=admin --peer=org3-peer0.green-bc
    
kubectl hlf chaincode install --path=./chaincode.tgz \
    --config=org3.yaml --language=golang --label=$CHAINCODE_LABEL --user=admin --peer=org3-peer1.green-bc
    
kubectl hlf chaincode install --path=./chaincode.tgz \
    --config=org4.yaml --language=golang --label=$CHAINCODE_LABEL --user=admin --peer=org4-peer0.green-bc
    
kubectl hlf chaincode install --path=./chaincode.tgz \
    --config=org4.yaml --language=golang --label=$CHAINCODE_LABEL --user=admin --peer=org4-peer1.green-bc
    
kubectl hlf chaincode install --path=./chaincode.tgz \
    --config=org5.yaml --language=golang --label=$CHAINCODE_LABEL --user=admin --peer=org5-peer0.green-bc
    
kubectl hlf chaincode install --path=./chaincode.tgz \
    --config=org5.yaml --language=golang --label=$CHAINCODE_LABEL --user=admin --peer=org5-peer1.green-bc
    
    
#########################
# Deploy CaS

kubectl hlf externalchaincode sync --image=kfsoftware/chaincode-external:latest \
    --ca-name org1-ca \
    --ca-namespace green-bc \
    --enroll-id enroll \
    --enroll-secret enrollpw \
    --name=$CHAINCODE_NAME \
    --namespace=green-bc \
    --package-id=$PACKAGE_ID \
    --tls-required=false \
    --replicas=1
    
    
# Query installed

kubectl hlf chaincode queryinstalled --config=org2.yaml --user=admin --peer=org2-peer0.green-bc


# Approve Chaincode - Sample
export SEQUENCE=1
export VERSION="1.0"
export POLICY="OR('Org1MSP.member', 'Org2MSP.member', 'Org3MSP.member', 'Org4MSP.member', 'Org5MSP.member')"

kubectl hlf chaincode approveformyorg --config=org1.yaml --user=admin --peer=org1-peer0.green-bc \
    --package-id=$PACKAGE_ID \
    --version "$VERSION" --sequence "$SEQUENCE" --name=asset \
    --policy="$POLICY" --channel=electrolineras-lentas
    
kubectl hlf chaincode approveformyorg --config=org2.yaml --user=admin --peer=org2-peer0.green-bc \
    --package-id=$PACKAGE_ID \
    --version "$VERSION" --sequence "$SEQUENCE" --name=asset \
    --policy="$POLICY" --channel=electrolineras-lentas
    
kubectl hlf chaincode approveformyorg --config=org3.yaml --user=admin --peer=org3-peer0.green-bc \
    --package-id=$PACKAGE_ID \
    --version "$VERSION" --sequence "$SEQUENCE" --name=asset \
    --policy="$POLICY" --channel=electrolineras-lentas
    
kubectl hlf chaincode approveformyorg --config=org4.yaml --user=admin --peer=org4-peer0.green-bc \
    --package-id=$PACKAGE_ID \
    --version "$VERSION" --sequence "$SEQUENCE" --name=asset \
    --policy="$POLICY" --channel=electrolineras-lentas

kubectl hlf chaincode approveformyorg --config=org5.yaml --user=admin --peer=org5-peer0.green-bc \
    --package-id=$PACKAGE_ID \
    --version "$VERSION" --sequence "$SEQUENCE" --name=asset \
    --policy="$POLICY" --channel=electrolineras-lentas

# Hay combinar todos los archivos de conexion
# python gen_orgs_total.py # Revisar las organizaciones del script


# Commit Chaincode

kubectl hlf chaincode commit --config=orgs-total.yaml --user=admin --mspid=Org1MSP \
    --version "$VERSION" --sequence "$SEQUENCE" --name=asset \
    --policy="$POLICY" --channel=electrolineras-lentas
    
# Invoke Transaction
kubectl hlf chaincode invoke --config=org1.yaml \
    --user=admin --peer=org1-peer0.green-bc \
    --chaincode=asset --channel=electrolineras-lentas \
    --fcn=initLedger -a '[]'
    
# Query
kubectl hlf chaincode query --config=org1.yaml \
    --user=admin --peer=org1-peer0.green-bc \
    --chaincode=asset --channel=electrolineras-lentas \
    --fcn=GetAllAssets -a '[]'