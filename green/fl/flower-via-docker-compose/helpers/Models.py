from audioop import avg
from cgi import test
from collections import OrderedDict
import torch
import torch.nn as nn
import torch.nn.functional as F
from copy import deepcopy as dc
from torch.utils.data import DataLoader
import math
import flwr as fl
import pandas as pd
import numpy as np
from torch.utils.data import Dataset
import sklearn
from sklearn import preprocessing


import numpy as np
import math
import sklearn.metrics as skm

# --------------- Funciones evaluación ------------------- 
def huber_fn(y_true, y_pred, delta):
    
    error = y_true - y_pred
    
    error = np.vectorize(np.abs)(error)
    is_small_error = np.vectorize(np.abs)(error) < delta
    #print(sum(is_small_error))
    squared_loss = np.vectorize(math.sqrt)(error) / 2
    linear_loss = delta * (np.vectorize(np.abs)(error) - 0.5 * delta)
    return np.mean(np.where(is_small_error, squared_loss, linear_loss))


def mase_loss(y_test, y_pred, y_train, sp=1):

    #  naive seasonal prediction
    y_train = np.asarray(y_train)
    y_pred_naive = y_train[:-sp]

    # mean absolute error of naive seasonal prediction
    mae_naive = np.mean(np.abs(y_train[sp:] - y_pred_naive))

    # if training data is flat, mae may be zero,
    # return np.nan to avoid divide by zero error
    # and np.inf values
    if mae_naive == 0:
        return np.nan
    else:
        return np.mean(np.abs(y_test - y_pred)) / mae_naive

def evaluateAllMetrics_test_pred(test, forecast, train):
    metrics = {"MAE": round(skm.mean_absolute_error(test, forecast),2),
               "MSE": round(skm.mean_squared_error(test, forecast),2),
               "RMSE": round(math.sqrt(skm.mean_squared_error(test, forecast)),2),
               "R^2": round(skm.r2_score(test, forecast),2),
               "MASE": round(mase_loss(test, forecast, train, sp=96), 2),
               "Huber Loss": round(huber_fn(test, forecast, np.std(test)),2)}  
    return metrics

DEVICE = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
device = DEVICE





class LinearModel(nn.Module):
    """
    Just one Linear layer
    """
    def __init__(self, channels, input_len, output_len):
        super(LinearModel, self).__init__()
        self.seq_len = input_len
        self.pred_len = output_len
        
        # Use this line if you want to visualize the weights
        # self.Linear.weight = nn.Parameter((1/self.seq_len)*torch.ones([self.pred_len,self.seq_len]))
        self.channels = channels
        self.Linear = nn.Linear(self.seq_len, self.pred_len)

    def forward(self, x):
        # x: [Batch, Input length, Channel]
        x = self.Linear(x.permute(0,2,1)).permute(0,2,1)
        return x # [Batch, Output length, Channel]

class NLinearModel(nn.Module):
    """
    Normalization-Linear
    """
    def __init__(self, channels, input_len, output_len):
        super(NLinearModel, self).__init__()
        self.seq_len = input_len
        self.pred_len = output_len
        
        # Use this line if you want to visualize the weights
        # self.Linear.weight = nn.Parameter((1/self.seq_len)*torch.ones([self.pred_len,self.seq_len]))
        self.channels = channels
        
        # De momento solo para 1 canal
        self.Linear = nn.Linear(self.seq_len, self.pred_len)

    def forward(self, x):
        # x: [Batch, Input length, Channel]
        seq_last = x[:,-1:,:].detach()
        x = x - seq_last
        
        # De momento solo para 1 canal
        x = self.Linear(x.permute(0,2,1)).permute(0,2,1)
        
        x = x + seq_last
        return x # [Batch, Output length, Channel]
def load_model():
    model = NLinearModel(1, 96, 1).to(device)
    return model



def mse(x, y):
    mse = ((x - y)**2).mean(axis=0)

    return mse



def rmse(x, y):
    rmse = (abs(x**2 - y**2)**(1/2)).mean(axis=0)

    return rmse


def mae(x, y):
    mae = (abs(x-y)).mean(axis=0)

    return mae







def train(net, trainloader):
    net.train(True)
    
    running_loss=0.0
    optimizer = torch.optim.SGD(net.parameters(), lr=0.001, momentum=0.9)
    for batch_index, batch in enumerate(trainloader):
        x_batch, y_batch = batch[0].to(DEVICE), batch[1].to(DEVICE)
        
        output = net(x_batch)
        loss = mse(output, y_batch)
        running_loss += loss.item()
        num_examples = len(trainloader)
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        if batch_index % 100 == 99:  # print every 100 batches
            avg_loss_across_batches = running_loss / 100
            print('Batch {0}, Loss: {1:.3f}'.format(batch_index+1,
                                                    avg_loss_across_batches))
            running_loss = 0.0
    
    return trainloader, trainloader, num_examples


def test(net, testloader):
    net.train(False)
    running_loss = 0.0
    
    for batch_index, batch in enumerate(testloader):
        x_batch, y_batch = batch[0].to(DEVICE), batch[1].to(DEVICE)
        
        with torch.no_grad():
            output = net(x_batch)
            loss = mse(output, y_batch)
            running_loss += loss.item()
    avg_loss_across_batches = running_loss / len(testloader)

    return avg_loss_across_batches


def calc_MSE(net, testloader):
    net.train(False)
    running_loss = 0.0
    
    for batch_index, batch in enumerate(testloader):
        x_batch, y_batch = batch[0].to(DEVICE), batch[1].to(DEVICE)
        
        with torch.no_grad():
            output = net(x_batch)
            loss = mse(output, y_batch)
            running_loss += loss.item()
    avg_loss_across_batches = running_loss / len(testloader)

    return avg_loss_across_batches


def calc_RMSE(net, testloader):
    net.train(False)
    running_loss = 0.0
    
    for batch_index, batch in enumerate(testloader):
        x_batch, y_batch = batch[0].to(DEVICE), batch[1].to(DEVICE)
        
        with torch.no_grad():
            output = net(x_batch)
            loss = rmse(output, y_batch)
            running_loss += loss.item()
    avg_loss_across_batches = running_loss / len(testloader)

    return avg_loss_across_batches

def calc_MAE(net, testloader):
    net.train(False)
    running_loss = 0.0
    
    for batch_index, batch in enumerate(testloader):
        x_batch, y_batch = batch[0].to(DEVICE), batch[1].to(DEVICE)
        
        with torch.no_grad():
            output = net(x_batch)
            loss = mae(output, y_batch)
            running_loss += loss.item()
    avg_loss_across_batches = running_loss / len(testloader)

    return avg_loss_across_batches


def calc_MASE(net, testloader):
    net.train(False)
    running_loss = 0.0
    
    for batch_index, batch in enumerate(testloader):
        x_batch, y_batch = batch[0].to(DEVICE), batch[1].to(DEVICE)
        
        with torch.no_grad():
            output = net(x_batch)
            loss = mse(output, y_batch)
            running_loss += loss.item()
    avg_loss_across_batches = running_loss / len(testloader)

    return avg_loss_across_batches


def calc_SMAPE(net, testloader):
    net.train(False)
    running_loss = 0.0
    
    for batch_index, batch in enumerate(testloader):
        x_batch, y_batch = batch[0].to(DEVICE), batch[1].to(DEVICE)
        
        with torch.no_grad():
            output = net(x_batch)
            loss = mse(output, y_batch)
            running_loss += loss.item()
    avg_loss_across_batches = running_loss / len(testloader)

    return avg_loss_across_batches