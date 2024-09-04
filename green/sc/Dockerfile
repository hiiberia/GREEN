ARG GO_VER=1.22.5
ARG ALPINE_VER=3.20

FROM golang:${GO_VER}-alpine${ALPINE_VER}

WORKDIR /go/src/github.com/hyperledger/fabric-samples/asset-transfer-basic/chaincode-external
COPY . .

RUN go get -d -v ./...
RUN go install -v ./...

EXPOSE 9999
CMD ["mychaincode"]

