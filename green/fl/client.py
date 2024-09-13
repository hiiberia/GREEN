import os
import argparse
import flwr as fl
import torch 
import logging
from helpers.load_data import load_data
from helpers import Models, LoadData
from collections import OrderedDict
import time
import hashlib
import io
import json
import requests
from datetime import datetime
import re

logging.basicConfig(level=logging.INFO)  # Configure logging
logger = logging.getLogger(__name__)  # Create logger for the module

# Make TensorFlow log less verbose
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"

# Parse command line arguments
parser = argparse.ArgumentParser(description="Flower client")

parser.add_argument(
    "--server_address", type=str, default="server:8080", help="Address of the server"
)
parser.add_argument(
    "--client_id", type=int, default=1, help="Unique ID for the client"
)
parser.add_argument(
    "--CS_data", type = str, default=' ', help="Charging Station's Name"
)

parser.add_argument(
    "--number_of_rounds", type=int, default=100, help="Number of FL rounds (default: 100)"
)

args = parser.parse_args()

API_KEY = os.getenv('API_KEY')

# Headers for JSON file
headers = {
    'api-key': API_KEY,  # Common practice for APIs using Bearer token
    'Content-Type': 'application/json'  # Set the content type if sending JSON data
}

# Directories
if not os.path.exists('./models/local'):
    os.makedirs('./models/local')

local_Models = './models/local/' + args.CS_data
last_sha256_local = 0
last_local_params = 0


class Client(fl.client.NumPyClient):
    def __init__(self, args):
        self.args = args

        logger.info("Preparing data...")
        data = LoadData.load_data(r'./Bcn_dayE.csv', self.args.CS_data)
        X_train, y_train, X_test, y_test = LoadData.treat_data(data)
        self.train_loader, self.test_loader, self.num_examples = LoadData.start_TimeSeries(X_train, y_train, X_test, y_test)
        self.x_train = X_train
        self.y_train = y_train
        self.x_test = X_test
        self.y_test = y_test

        self.model = Models.load_model()
        self.org_msp = get_org_name()
        self.round_num = 0
    
    def get_model_params(self):
        """Returns a model's parameters."""
        return [val.cpu().numpy() for _, val in self.model.state_dict().items()]
    
    def set_parameters(self, parameters):
        """Loads a alexnet or efficientnet model and replaces it parameters with the
        ones given."""

        params_dict = zip(self.model.state_dict().keys(), parameters)
        state_dict = OrderedDict({k: torch.tensor(v) for k, v in params_dict})
        self.model.load_state_dict(state_dict, strict=False)

    def send_loss(self, rmse, model_sha):
        url = "http://api-gateway-green-hf-service.hi-iberia.es/"
        if args.CS_data[0:10] == 'Power_PdRR':
            url = url + 'rapidas/metrics'
        else:
            url = url + 'lentas/metrics'
        msg = {
            'orgMsp': get_org_name(),
            'sha': model_sha,
            'metricType': 'RMSE',
            'metricValue': rmse
        }
        response = requests.post(url, json=msg, headers=headers)
        logger.info("Sending this metric message {} for orgMSP {}".format(msg, msg['orgMsp']))
        logger.info("This is the result of sending RMSE metric {}: {}".format(response.status_code, response.text))

    def send_acc(self, mae, model_sha):
        url = "http://api-gateway-green-hf-service.hi-iberia.es/"
        if args.CS_data[0:10] == 'Power_PdRR':
            url = url + 'rapidas/metrics'
        else:
            url = url + 'lentas/metrics'
        msg = {
            'orgMsp': get_org_name(),
            'sha': model_sha,
            'metricType': 'MAE',
            'metricValue': mae
        }
        response = requests.post(url, json=msg, headers=headers)
        logger.info("Sending this metric message {} for orgMSP {}".format(msg, msg['orgMsp']))
        logger.info("This is the result of sending MAE metric {}: {}".format(response.status_code, response.text))


    def fit(self, parameters, config):
        self.round_num = self.round_num+1

        # Set the weights of the model
        self.set_parameters(parameters)

        # Train the model
        Models.train(self.model, self.train_loader)

        rmse = Models.calc_RMSE(self.model, self.test_loader)
        mae = Models.calc_MAE(self.model, self.test_loader)
        accuracy = mae

        # Calculate evaluation metric
        results = {
            "accuracy": float(accuracy),
        }

        # Get the parameters after training
        parameters_prime = self.get_model_params()
        
        # Directly return the parameters and the number of examples trained on
        return parameters_prime, len(self.train_loader), results

    def evaluate(self, parameters, config):
        # Set the weights of the model
        self.set_parameters(parameters)

        # Evaluate the model and get the loss and accuracy
  
        rmse= Models.calc_RMSE(self.model, self.test_loader)
        mae =  Models.calc_MAE(self.model, self.test_loader)
        accuracy = mae

        if args.number_of_rounds == self.round_num:
            # Generate SHA256 for Local Model
            last_sha256_local = compute_state_dict_hash(self.model.state_dict())
            # Last Local Model
            last_local_params = self.model.state_dict()

            # Send Request for rmse 'Loss'
            self.send_loss(rmse, last_sha256_local)

            time.sleep(10)
            sendandsave_model_hash(last_sha256_local, last_local_params)

            # Send Request for mae 'Accuracy'
            time.sleep(10)
            self.send_acc(mae, last_sha256_local)

        # Return the loss, the number of examples evaluated on and the accuracy
        return float(rmse), len(self.test_loader), {"accuracy": float(accuracy)}


# Function to Start the Client
def start_fl_client():
    try:
        client = Client(args).to_client()
        fl.client.start_client(server_address=args.server_address, client=client)
    except Exception as e:
        logger.error("Error starting FL client: %s", e)
        return {"status": "error", "message": str(e)}

def get_org_name():
    client_id = args.client_id
    org_name = ''
    result = client_id % 5

    if result == 1:
        org_name = 'Org1MSP'
    if result == 2:
        org_name = 'Org2MSP'
    if result == 3:
        org_name = 'Org3MSP'
    if result == 4:
        org_name = 'Org4MSP'
    if result == 0:
        org_name = 'Org5MSP'

    return org_name

def clean_name_station(name):
    name = name.replace(" ", "_").replace(".", "_").lower()

    name = re.sub('[^a-zA-Z0-9 \n\.\_]', '', name)
    return name

def defineURL(cs_name):
    now = datetime.now()
    formatted_now = now.strftime('%Y-%m-%d_%H-%M-%S')
    return os.path.join(clean_name_station(cs_name), formatted_now)


# Methods needed
def compute_state_dict_hash(state_dict):
    # Serialize the state_dict to a bytes object
    buffer = io.BytesIO()
    torch.save(state_dict, buffer)
    serialized_data = buffer.getvalue()

    # Compute the hash of the serialized data
    hasher = hashlib.sha256()
    hasher.update(serialized_data)

    return hasher.hexdigest()


def post_model(model_sha):
    org_name = get_org_name()
    aux = defineURL(args.CS_data)
    url = "http://api-gateway-green-hf-service.hi-iberia.es/"
    if args.CS_data[0:10] == 'Power_PdRR':
        url = url + 'rapidas/models'
    else:
        url = url + 'lentas/models'
    msg = {
        'orgMsp': org_name,
        'sha': model_sha,
        'url': os.path.join("harbor.hi-iberia.es/green/clients", aux)
    }
    response = requests.post(url, json=msg, headers=headers)
    logger.info("Sending this message {} for orgMSP {}".format(msg, msg['orgMsp']))
    logger.info("This is the result of sending model metric {}: {}".format(response.status_code, response.text))


def sendandsave_model_hash(hash_local, last_local):
    ## Save Last Local Model
    torch.save(last_local, local_Models + 'last_local_model.pt')

    ## Post Model to BC Local
    post_model(hash_local)


if __name__ == "__main__":
    # Call the function to start the client
    start_fl_client()
    
