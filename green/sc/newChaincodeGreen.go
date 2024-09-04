package main

import (
    "encoding/json"
    "fmt"
    "io/ioutil"
    "log"
    "os"
    "strconv"

    "github.com/hyperledger/fabric-chaincode-go/shim"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type serverConfig struct {
    CCID    string
    Address string
}

// SmartContract provides functions for managing metrics and models
type SmartContract struct {
    contractapi.Contract
}

// Metric describes basic details of a metric
type Metric struct {
    SHA         string `json:"sha"`
    MetricType  string `json:"metricType"`
    MetricValue string `json:"metricValue"`
    OrgName     string `json:"orgName"`
}

type ModelsWithMetricsResponse struct {
    ModelsWithMetrics []*ModelWithMetrics `json:"modelsWithMetrics"`
    UnknownMetrics    []*Metric           `json:"unknownMetrics"`
}

// Model describes basic details of a model
type Model struct {
    SHA     string    `json:"sha"`
    URL     string    `json:"url"`
    OrgName string    `json:"orgName"`
}

// ModelWithMetrics combines Model and its Metrics
type ModelWithMetrics struct {
    Model   *Model    `json:"model"`
    Metrics []*Metric `json:"metrics"`
}


// AddModel issues a new model to the world state with given details.
func (s *SmartContract) AddModel(ctx contractapi.TransactionContextInterface, sha, url, orgName string) error {
  model := Model{
      SHA:     sha,
      URL:     url,
      OrgName: orgName,
  }

  modelJSON, err := json.Marshal(model)
  if err != nil {
      return err
  }

  return ctx.GetStub().PutState("MODEL_"+orgName, modelJSON)
}

// GetLatestModels returns the latest model for each organization
func (s *SmartContract) GetLatestModels(ctx contractapi.TransactionContextInterface) ([]*Model, error) {
    resultsIterator, err := ctx.GetStub().GetStateByRange("MODEL_", "MODEL_~")
    if err != nil {
        return nil, err
    }
    defer resultsIterator.Close()

    var models []*Model
    for resultsIterator.HasNext() {
        queryResponse, err := resultsIterator.Next()
        if err != nil {
            return nil, err
        }

        var model Model
        err = json.Unmarshal(queryResponse.Value, &model)
        if err != nil {
            return nil, err
        }
        models = append(models, &model)
    }

    return models, nil
}

// GetModel returns the model stored in the world state with given id
func (s *SmartContract) GetModel(ctx contractapi.TransactionContextInterface, sha string) (*Model, error) {
	modelJSON, err := ctx.GetStub().GetState("MODEL_" + sha)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state: %v", err)
	}
	if modelJSON == nil {
		return nil, fmt.Errorf("the model %s does not exist", sha)
	}

	var model Model
	err = json.Unmarshal(modelJSON, &model)
	if err != nil {
		return nil, err
	}

	return &model, nil
}

// GetAllModels returns all models found in world state
func (s *SmartContract) GetAllModels(ctx contractapi.TransactionContextInterface) ([]*Model, error) {
	resultsIterator, err := ctx.GetStub().GetStateByRange("MODEL_", "MODEL_~")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var models []*Model
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		var model Model
		err = json.Unmarshal(queryResponse.Value, &model)
		if err != nil {
			return nil, err
		}
		models = append(models, &model)
	}

	return models, nil
}

func (s *SmartContract) GetMetricsForModel(ctx contractapi.TransactionContextInterface, orgName, sha string) ([]*Metric, error) {
    resultsIterator, err := ctx.GetStub().GetStateByRange("METRIC_"+orgName+"_"+sha+"_", "METRIC_"+orgName+"_"+sha+"_~")
    if err != nil {
        return nil, err
    }
    defer resultsIterator.Close()

    var metrics []*Metric
    for resultsIterator.HasNext() {
        queryResponse, err := resultsIterator.Next()
        if err != nil {
            return nil, err
        }

        var metric Metric
        err = json.Unmarshal(queryResponse.Value, &metric)
        if err != nil {
            return nil, err
        }
        metrics = append(metrics, &metric)
    }

    return metrics, nil
}

func (s *SmartContract) GetModelsWithMetrics(ctx contractapi.TransactionContextInterface) (*ModelsWithMetricsResponse, error) {
    modelsIterator, err := ctx.GetStub().GetStateByRange("MODEL_", "MODEL_~")
    if err != nil {
        return nil, err
    }
    defer modelsIterator.Close()

    response := &ModelsWithMetricsResponse{
        ModelsWithMetrics: []*ModelWithMetrics{},
        UnknownMetrics:    []*Metric{},
    }

    for modelsIterator.HasNext() {
        queryResponse, err := modelsIterator.Next()
        if err != nil {
            return nil, err
        }

        var model Model
        err = json.Unmarshal(queryResponse.Value, &model)
        if err != nil {
            return nil, err
        }

        metrics, err := s.GetMetricsForModel(ctx, model.OrgName, model.SHA)
        if err != nil {
            return nil, err
        }

        // Si no hay métricas, inicializa con un slice vacío en lugar de null
        if metrics == nil {
            metrics = []*Metric{}
        }

        response.ModelsWithMetrics = append(response.ModelsWithMetrics, &ModelWithMetrics{
            Model:   &model,
            Metrics: metrics,
        })
    }

    // Get all metrics and check for unknown models
    metricsIterator, err := ctx.GetStub().GetStateByRange("METRIC_", "METRIC_~")
    if err != nil {
        return nil, err
    }
    defer metricsIterator.Close()

    for metricsIterator.HasNext() {
        queryResponse, err := metricsIterator.Next()
        if err != nil {
            return nil, err
        }

        var metric Metric
        err = json.Unmarshal(queryResponse.Value, &metric)
        if err != nil {
            return nil, err
        }

        modelExists := false
        for _, mwm := range response.ModelsWithMetrics {
            if mwm.Model.SHA == metric.SHA && mwm.Model.OrgName == metric.OrgName {
                modelExists = true
                break
            }
        }

        if !modelExists {
            response.UnknownMetrics = append(response.UnknownMetrics, &metric)
        }
    }

    return response, nil
}


// AddMetric issues a new metric to the world state with given details.
func (s *SmartContract) AddMetric(ctx contractapi.TransactionContextInterface, sha, metricType, metricValue, orgName string) error {
    metric := Metric{
        SHA:         sha,
        MetricType:  metricType,
        MetricValue: metricValue,
        OrgName:     orgName,
    }

    metricJSON, err := json.Marshal(metric)
    if err != nil {
        return err
    }

    return ctx.GetStub().PutState("METRIC_"+orgName+"_"+sha+"_"+metricType, metricJSON)
}

// GetAllMetrics returns all metrics found in world state
func (s *SmartContract) GetAllMetrics(ctx contractapi.TransactionContextInterface) ([]*Metric, error) {
	resultsIterator, err := ctx.GetStub().GetStateByRange("", "")
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	var metrics []*Metric
	for resultsIterator.HasNext() {
		queryResponse, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		var metric Metric
		err = json.Unmarshal(queryResponse.Value, &metric)
		if err != nil {
			return nil, err
		}
		metrics = append(metrics, &metric)
	}

	return metrics, nil
}

func main() {
        // See chaincode.env.example
        config := serverConfig{
                CCID:    os.Getenv("CHAINCODE_ID"),
                Address: os.Getenv("CHAINCODE_SERVER_ADDRESS"),
        }

        chaincode, err := contractapi.NewChaincode(&SmartContract{})

        if err != nil {
                log.Panicf("error create asset-transfer-basic chaincode: %s", err)
        }

        server := &shim.ChaincodeServer{
                CCID:     config.CCID,
                Address:  config.Address,
                CC:       chaincode,
                TLSProps: getTLSProperties(),
        }

        if err := server.Start(); err != nil {
                log.Panicf("error starting asset-transfer-basic chaincode: %s", err)
        }
}

func getTLSProperties() shim.TLSProperties {
        // Check if chaincode is TLS enabled
        tlsDisabledStr := getEnvOrDefault("CHAINCODE_TLS_DISABLED", "true")
        key := getEnvOrDefault("CHAINCODE_TLS_KEY", "")
        cert := getEnvOrDefault("CHAINCODE_TLS_CERT", "")
        clientCACert := getEnvOrDefault("CHAINCODE_CLIENT_CA_CERT", "")

        // convert tlsDisabledStr to boolean
        tlsDisabled := getBoolOrDefault(tlsDisabledStr, false)
        var keyBytes, certBytes, clientCACertBytes []byte
        var err error

        if !tlsDisabled {
                keyBytes, err = ioutil.ReadFile(key)
                if err != nil {
                        log.Panicf("error while reading the crypto file: %s", err)
                }
                certBytes, err = ioutil.ReadFile(cert)
                if err != nil {
                        log.Panicf("error while reading the crypto file: %s", err)
                }
        }
        // Did not request for the peer cert verification
        if clientCACert != "" {
                clientCACertBytes, err = ioutil.ReadFile(clientCACert)
                if err != nil {
                        log.Panicf("error while reading the crypto file: %s", err)
                }
        }

        return shim.TLSProperties{
                Disabled:      tlsDisabled,
                Key:           keyBytes,
                Cert:          certBytes,
                ClientCACerts: clientCACertBytes,
        }
}

func getEnvOrDefault(env, defaultVal string) string {
        value, ok := os.LookupEnv(env)
        if !ok {
                value = defaultVal
        }
        return value
}

// Note that the method returns default value if the string
// cannot be parsed!
func getBoolOrDefault(value string, defaultVal bool) bool {
        parsed, err := strconv.ParseBool(value)
        if err != nil {
                return defaultVal
        }
        return parsed
}
