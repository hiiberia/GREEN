import traci
import pytz
import datetime
import pandas as pd
import matplotlib.pyplot as plt


def getdatetime():
        utc_now = pytz.utc.localize(datetime.datetime.utcnow())
        currentDT = utc_now.astimezone(pytz.timezone("Europe/Madrid"))
        DATIME = currentDT.strftime("%Y-%m-%d %H:%M:%S")
        return DATIME


sumoCmd = ["sumo", "-c", "sumo.sumocfg"]  # El nombre de la simulación en este caso se llama sumo.sumocfg
traci.start(sumoCmd)

packVehicleData = []
packStationData = []


while traci.simulation.getMinExpectedNumber() > 0:
       
        traci.simulationStep();

        simTime = traci.simulation.getTime();
        vehicles=traci.vehicle.getIDList();
        stations = traci.chargingstation.getIDList(); # Aunque en principio la lista de estaciones no cambia, lo dejamos aquí de momento
        

        for i in range(0,len(vehicles)):

                #Function descriptions
                #https://sumo.dlr.de/docs/TraCI/Vehicle_Value_Retrieval.html
                #https://sumo.dlr.de/pydoc/traci._vehicle.html#VehicleDomain-getSpeed
                vehid = vehicles[i]
                x, y = traci.vehicle.getPosition(vehid)
                coord = [x, y]
                lon, lat = traci.simulation.convertGeo(x, y)
                gpscoord = [lon, lat]
                spd = round(traci.vehicle.getSpeed(vehid)*3.6,2)
                edge = traci.vehicle.getRoadID(vehid)
                lane = traci.vehicle.getLaneID(vehid)
                displacement = round(traci.vehicle.getDistance(vehid),2)

                battery = round(float(traci.vehicle.getParameter(vehid, "device.battery.actualBatteryCapacity")),2)
                

                #Packing of all the data for export to CSV/XLSX
                vehList = [getdatetime(), simTime, vehid, coord, gpscoord, spd, edge, lane, displacement, battery]
                
                print("Vehicle: ", vehicles[i], " at datetime: ", getdatetime())
                print(vehicles[i], " >>> Position: ", coord, " | GPS Position: ", gpscoord, " |", \
                                       " Speed: ", spd, "km/h |", \
                                      #Returns the id of the edge the named vehicle was at within the last step.
                                       " EdgeID of veh: ", edge, " |", \
                                      #Returns the id of the lane the named vehicle was at within the last step.
                                       " LaneID of veh: ", lane, " |", \
                                      #Returns the distance to the starting point like an odometer.
                                       " Distance: ", displacement, "m |", \
                                      #Returns the energy stored in the battery at the last step
                                        " Current Batery: ", battery            
                                      
                       )

                                
                #Pack Simulated Data
                packVehicleData.append(vehList)


        for i in range(0,len(stations)):
                statId = stations[i]
                statName = traci.chargingstation.getName(statId)
                statPos = traci.chargingstation.getStartPos(statId)
                statLane = traci.chargingstation.getLaneID(statId)
                statVehCount = traci.chargingstation.getVehicleCount(statId)
                statVehIds = traci.chargingstation.getVehicleIDs(statId)
                statTotalE = round(float(traci.simulation.getParameter(statId, "chargingStation.totalEnergyCharged")),2)
                

                # Packing the stations data
                statList = [getdatetime(), simTime, statId, statName, statPos, statLane, statVehCount, statVehIds, statTotalE]

                print("Station: ", statId, " at datetime: ", getdatetime())
                print(statId, " >>> Position: ", statPos, " m in the lane ", statLane, \
                                        #Returns the number of vehicles charging in the station within the last step
                                       " Vehicle count: ", statVehCount, \
                                        #Returns the list of IDs of the vehicles charging in the station within the last step
                                       " Vehicle list: ", statVehIds, \
                                        #Returns the total amount of energ provided by the station from the begining of the simulation until the last step
                                       " Total energy charged: ", statTotalE               
                                      
                )

                #Pack Simulated Data
                packStationData.append(statList)

traci.close()

#Generate Excel file for vehicles
columnnames = ['dateandtime', 'simulation time', 'vehid', 'coord', 'gpscoord', 'spd', 'edge', 'lane', 'displacement','battery']
df_veh = pd.DataFrame(packVehicleData, index=None, columns=columnnames)
df_veh.to_excel("output_vehicles.xlsx", index=False)

#Generate Excel file for stations
statColumnnames = ['dateandtime', 'simulation time', 'statId', 'name', 'pos', 'lane', 'vehicle count', 'vehicle list', 'total energy charged']
df_stat = pd.DataFrame(packStationData, index=None, columns=statColumnnames)
# Ordenamos los datos por electrolinera y por tiempo
df_stat = df_stat.sort_values(by=['statId', 'simulation time'])
df_stat.to_excel("output_stations.xlsx", index=False)


# Análisis posterior de resultados
steps = df_stat.loc[df_stat['statId']==stations[0]]['simulation time'] # Obtenemos una lista del tiempo de la simulación
# Ploteamos la energúa total entregada por cada una de las electrolineras a lo largo de la simulación
for stat in stations:
      plt.plot(steps, df_stat.loc[df_stat['statId']==stat]['total energy charged'])

fig = plt.gcf()
fig.set_size_inches(10,7)
plt.legend(stations)
plt.xlabel("Time step (s)", size = 12)
plt.ylabel("Total energy charged", size = 12)
plt.title("Energy charged by each station", size = 18)
plt.show()
