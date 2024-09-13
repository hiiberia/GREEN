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
DEVICE = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
device = DEVICE

def load_data(data_csv, CS):
    all_data = pd.read_csv(data_csv)
    all_data['Time'] = pd.to_datetime(all_data['Time'])

    data = all_data.loc[all_data['Time'] < pd.Timestamp("2019-01-31 00:00:00") ,['Time', CS]]
    data = data.rename(columns={CS: "E"})

    return data

def prepare_dataframe_for_lstm(df, n_steps):
    df = dc(df)
    
    df.set_index('Time', inplace=True)
    
    for i in range(1, n_steps+1):
        df[f'E(t-{i})'] = df['E'].shift(i)
        
    df.dropna(inplace=True)
    
    return df

def treat_data(data):
    lookback = 96
    shifted_df = prepare_dataframe_for_lstm(data, lookback)
    shifted_df_as_np = shifted_df.to_numpy()
    from sklearn.preprocessing import MinMaxScaler

    scaler = MinMaxScaler(feature_range=(-1, 1))
    shifted_df_as_np = scaler.fit_transform(shifted_df_as_np)
    X = shifted_df_as_np[:, 1:]
    y = shifted_df_as_np[:, 0]
    X = dc(np.flip(X, axis=1))

    f_train = 0.75
    n_train = math.floor(len(data)*f_train) - 1  # el -1 es para que el tamaño coincida con los frameworks

    X_train = X[:n_train]; X_test = X[n_train:]
    y_train = y[:n_train]; y_test = y[n_train:]

    # Añadir una dimensión extra
    X_train = X_train.reshape((-1, lookback, 1))
    X_test = X_test.reshape((-1, lookback, 1))

    y_train = y_train.reshape((-1, 1, 1))
    y_test = y_test.reshape((-1, 1, 1))

    X_train = torch.tensor(X_train).float()
    y_train = torch.tensor(y_train).float()
    X_test = torch.tensor(X_test).float()
    y_test = torch.tensor(y_test).float()
    return X_train, y_train, X_test, y_test

from torch.utils.data import DataLoader

class TimeSeriesDataset(Dataset):
    def __init__(self, X, y):
        self.X = X
        self.y = y

    def __len__(self):
        return len(self.X)

    def __getitem__(self, i):
        return self.X[i], self.y[i]

def start_TimeSeries(X_train, y_train, X_test, y_test):
    train_dataset = TimeSeriesDataset(X_train, y_train)
    test_dataset = TimeSeriesDataset(X_test, y_test)

    batch_size = 16

    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=False)
    test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False)
    num_examples = {"trainset": len(train_dataset), "testset": len(test_dataset)}
    return train_loader, test_loader, num_examples