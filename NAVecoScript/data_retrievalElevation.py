#Auteur : Yesid BELLO
#Date : 07/01/2022
#Programme qui permet de récupérer, à partir d'une adresse de départ et d'arrivée, les coordonnées du départ et de l'arrivée, le trajet, la vitesse et la pente de la route.
# Modifie par: Yesid BELLO

##Initialisation

#Librairies
import os
import json
import csv
import pyjsonviewer
import matplotlib.pyplot as plt
import requests
import polyline
from math import *
import numpy
import time
import googlemaps
import ssl
from sys import argv

script, DepartA, ArrivalA, ResolDista, OrdreFiltre = argv


import urllib.request
import math
import matplotlib.pyplot as plt

plt.close('all')

#Chemin du dossier contenant le programme
path = 'C:/Users/crybelloceferin/Documents/MATLAB/Supun/NAVecoScript'
os.chdir(path)

#Url des API utilisées
url_OSM = 'https://overpass-api.de/api/'
url_ORS = 'https://api.openrouteservice.org/'

#API key for OpenRouteService
ORS_key = '5b3ce3597851110001cf62481939aa3d96f749b49609cadbedfa192d'

#API key for Gooogle Maps
GM_key = 'AIzaSyDrB16uv9NYnnT4WH4V0zcJmqvHGkxL9mE'
client = googlemaps.Client(key=GM_key)

##Paramètres

#Adresses
# departure_adress = '1098 avenue roger salengro, chaville'
departure_adress = DepartA.replace('_',' ')
# arrival_adress = 'Pont de Sevres, paris'
arrival_adress = ArrivalA.replace('_',' ')

#Résolution de la distance entre chaque point pour la récupération de l'altitude
#distance_sample = int(ResolDista)
distance_sample = float(ResolDista)
# distance_sample = 1

DevelopperMode = False

OrdreFiltre = int(OrdreFiltre)

##Fonctions

#Sauvegarder,charger et afficher des données de type Json

def writeJson(jsonVar,jsonName):
    with open('./saved_data/'+jsonName+'.json', 'w') as json_file:
        json.dump(jsonVar, json_file)

def loadJson(jsonName):
    with open('./saved_data/'+jsonName+'.json', 'r') as json_file:
        return json.load(json_file)

def printJson(jsonVar,jsonParams):
    for param in jsonParams:
        print(jsonVar[0])

def jsonViewer(jsonName):
    pyjsonviewer.view_data(json_file='./saved_data/'+jsonName+'.json')

#Sauvegarder,charger des données de type CSV

def writeCsv(csvVar,csvName):
    with open('C:/Users/crybelloceferin/Documents/MATLAB/Supun/NAVecoScript/'+csvName+'.csv', 'w', newline='') as csv_file:
        csv_writer = csv.writer(csv_file,delimiter=';')
        csv_writer.writerows(csvVar)

def loadCsv(csvName):
    csv_list = []
    with open('C:/Users/crybelloceferin/Documents/MATLAB/Supun/NAVecoScript/'+csvName+'.csv', 'r', newline='') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=';', quotechar='|')
        for row in csv_reader:
            csv_list.append(row)
        return csv_list

#Obtenir la distance entre deux coordonnées

def getDistance(lat1,lon1,lat2,lon2):
    R = 6371000
    phi1 = lat1*pi/180
    phi2 = lat2*pi/180
    dlat = (lat2-lat1)*pi/180
    dlon = (lon2-lon1)*pi/180

    a = sin(dlat/2)*sin(dlat/2)+cos(phi1)*cos(phi2)*sin(dlon/2)*sin(dlon/2)
    c = 2*atan2(sqrt(a), sqrt(1-a))

    return R * c

def RouteData(departure_long,departure_lat,arrival_long,arrival_lat):
    body = {
        "coordinates":[[departure_long,departure_lat],[arrival_long,arrival_lat]],
        "language":"fr-fr",
        "units":"m",
        "geometry":"True",
        "elevation":"true",
        "extra_info":["waytype","waycategory"],
    }

    headers = {
        'Accept': 'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
        'Authorization': ORS_key,
        'Content-Type': 'application/json; charset=utf-8'
    }
    print("API request route: sending request ...")
    route_raw = requests.post(url_ORS+'v2/directions/driving-car/geojson', json=body, headers=headers)
    print("API request route: OK\n")
    route = route_raw.text
    route = json.loads(route)
    #Sauvegarde du trajet
    #writeJson(route,'route')

    return route['features'][0]

#
# item=1
# getDistance(route['geometry']['coordinates'][item][1],route['geometry']['coordinates'][item][2],route['geometry']['coordinates'][item+1][1],route['geometry']['coordinates'][item+1][2])

##Main

##-Récupération des coordonnées du départ et de l'arrivée


#Récupération et sauvegarde des coordonnées du départ
print("API request geocode departure: sending request ...")
departure = client.geocode(departure_adress)[0]
print("API request geocode departure: OK")
#writeJson(departure,"departure")
#Récupération et sauvegarde des coordonnées de l'arrivée
print("API request geocode departure: sending request ...")
arrival = client.geocode(arrival_adress)[0]
print("API request geocode departure: OK\n")
#writeJson(arrival,"arrival")


departure_name = departure['formatted_address']
departure_long = departure['geometry']['location']['lng']
departure_lat = departure['geometry']['location']['lat']

arrival_name = arrival['formatted_address']
arrival_long = arrival['geometry']['location']['lng']
arrival_lat = arrival['geometry']['location']['lat']

if DevelopperMode:
    print("Departure:")
    print(departure_name)
    print("lat: "+str(departure_lat)+" | lng: "+str(departure_long)+"\n")

    print("Arrival:")
    print(arrival_name)
    print("lat: "+str(arrival_lat)+" | lng: "+str(arrival_long)+"\n")

##-Récupération du trajet

flag=1
while flag:
    try:
        route = RouteData(departure_long,departure_lat,arrival_long,arrival_lat)
        distance = route['properties']['summary']['distance']
        duration = route['properties']['summary']['duration']
        geometry = route['geometry']['coordinates']

        flag=0
        if DevelopperMode:
            print('Meassure correct:')
            print(distance)
            print(duration)
            print(geometry)
    except:
        #pass
        print('Error in route Data, sleeping 1 secs\n')
        time.sleep(1)


##Altitude
#https://www.geodose.com/2018/03/create-elevation-profile-generator-python.html
LatSichr = []
LonSichr = []


for i in range(len(geometry)):
    if i == len(geometry)-1:
        n = 0
    else:
        DistTemp = getDistance(geometry[i][1],geometry[i][0],geometry[i+1][1],geometry[i+1][0])
        n = ceil(DistTemp/distance_sample)
    LatSichr.append(geometry[i][1])
    LonSichr.append(geometry[i][0])
    if n>1:
        for j in range(1,n):
            LatSichr.append(geometry[i][1]+(geometry[i+1][1]-geometry[i][1])/n*j)
            LonSichr.append(geometry[i][0]+(geometry[i+1][0]-geometry[i][0])/n*j)

new_geometry = []
for i in range(len(LatSichr)):
    new_geometry.append([LatSichr[i],LonSichr[i]])

#API Google Map altitudes -------------------------------
elevations = []
#Découpage en requêtes de 500 points (max de l'api)
for i in range(ceil(len(new_geometry)/500)):
    if((i+1)*500<=len(new_geometry)):
        elevations_result = client.elevation(new_geometry[i*500:(i+1)*500])
    else:
        elevations_result = client.elevation(new_geometry[i*500:])
    elevations += elevations_result

elev_list = []
ResolHist = []
new_geometry_Final = []

for i in range(len(elevations)):
    elev_list.append(elevations[i]['elevation'])
    ResolHist.append(elevations[i]['resolution'])
    new_geometry_Final.append([elevations[i]['location']['lat'],elevations[i]['location']['lng'],elevations[i]['elevation']])

#Filtre d'elev Goggle Maps

ElevFiltre = []
for i in range(0,len(elev_list)):
    ElevFiltre.append(float(elev_list[i]))  

#OrdreFiltre = 50
ElevFiltre1 = []
for i in range(0,len(ElevFiltre)):
    if len(ElevFiltre)>1:
        if i==0:
            ElevFiltre1.append(ElevFiltre[0])
        elif i==len(ElevFiltre)-1:
        	evFiltre1.append(ElevFiltre[len(ElevFiltre)-1])
        elif i<=OrdreFiltre/2:
            #ElevFiltre1.append(sum(ElevFiltre[:int(OrdreFiltre/2)])/len(ElevFiltre[:int(OrdreFiltre/2)]))
            ElevFiltre1.append(sum(ElevFiltre[:i*2])/len(ElevFiltre[:i*2]))
        elif i>=(len(ElevFiltre)-(OrdreFiltre/2)):
            #ElevFiltre1.append(sum(ElevFiltre[len(ElevFiltre)-int(OrdreFiltre/2):])/len(ElevFiltre[len(ElevFiltre)-int(OrdreFiltre/2):]))
            ElevFiltre1.append(sum(ElevFiltre[2*i-len(ElevFiltre)+1:])/len(ElevFiltre[2*i-len(ElevFiltre)+1:]))
        else:
            ElevFiltre1.append(sum(ElevFiltre[i-int(OrdreFiltre/2):i+int(OrdreFiltre/2)])/len(ElevFiltre[i-int(OrdreFiltre/2):i+int(OrdreFiltre/2)]))

for i in range(0,len(elev_list)):
    elev_list[i]=ElevFiltre1[i]

## Pente ----------------

DistNodesV = []
DiffaltV  = [0]
Pente = [0]
DistCum = [0]
DistInit = 0
VarTemp = 0

for i in range(len(LatSichr)-1):
    DistNodes=getDistance(LatSichr[i],LonSichr[i],LatSichr[i+1],LonSichr[i+1])
    DiffAlt = (elev_list[i+1]-elev_list[i])
    DistNodesV.append(DistNodes)
    DistCum.append(DistInit+DistNodes)
    DistInit=DistInit+DistNodes
    if (abs(DiffAlt/DistNodes))>0.5:
        VarTemp = VarTemp
        DiffaltV.append(DiffAlt)
        Pente.append(math.asin(VarTemp)) #Radians
    else:
        VarTemp = DiffAlt/DistNodes
        DiffaltV.append(DiffAlt)
        Pente.append(math.asin(VarTemp)) #Radians
    # print(' ')
    # print(DiffAlt)
    # print(DistNodes)
    # print(DiffAlt/DistNodes)
    # input("Press Enter to continue...")


##Vittesse
# https://giscience.github.io/openrouteservice/documentation/travel-speeds/Travel-Speeds.html

MaxSpeed = []
DistKeyPoints = route['properties']['segments'][0]['steps'][0]['distance']
# DistKeyPointsVect = []
# DistTempVect = []
KeyPoints = len(route['properties']['segments'][0]['steps'])
KeySegments = len(route['properties']['segments'])
KeyPointsTemp = 0
KeySegmentsTemp = 0

TotalDist = 0
i = 0
# for i in range(len(LatSichr)-1):
while 1 :
    DistTemp = route['properties']['segments'][KeySegmentsTemp]['steps'][KeyPointsTemp]['distance']
    DuraTemp = route['properties']['segments'][KeySegmentsTemp]['steps'][KeyPointsTemp]['duration']

    if(DuraTemp==0):
        KeyPointsTemp = KeyPointsTemp + 1
        # DistKeyPointsVect.append(DistKeyPoints)
        # DistTempVect.append(DistTemp)
    else:
        MaxSpeedTemp = (DistTemp/DuraTemp)
        MaxSpeed.append(MaxSpeedTemp)

        if(DistCum[i]>=DistKeyPoints+TotalDist):
            TotalDist = TotalDist+DistKeyPoints
            KeyPointsTemp = KeyPointsTemp + 1
            DistKeyPoints = DistKeyPoints + route['properties']['segments'][KeySegmentsTemp]['steps'][KeyPointsTemp]['distance']
            # DistKeyPointsVect.append(DistKeyPoints)
            # DistTempVect.append(DistTemp)

        i=i+1

    if(KeyPointsTemp==KeyPoints):
        KeyPointsTemp = 0
        KeySegmentsTemp = KeySegmentsTemp+1
        KeyPoints = len(route['properties']['segments'][KeySegmentsTemp]['steps'])

    if (len(MaxSpeed)==len(LatSichr)) :
        break


# DistKeyPoints = 0
# for i in range(len(route['properties']['segments'][0]['steps'])-1):
#     DistKeyPoints= DistKeyPoints + (route['properties']['segments'][0]['steps'][i]['distance'])
#     print(DistKeyPoints)

# Plots ---------------

if DevelopperMode:
    plt.figure(figsize=(10,4))
    plt.plot(range(len(DistNodesV)),DistNodesV)
    plt.fill_between(range(len(DistNodesV)),DistNodesV,alpha=0.1)
    plt.xlabel("Nodes")
    plt.ylabel("Distance (m)")
    plt.grid()
    plt.show()

    plt.figure(figsize=(10,4))
    plt.plot(DistCum,elev_list)
    plt.fill_between(DistCum,elev_list,alpha=0.1)
    plt.xlabel("Distance (m)")
    plt.ylabel("Altura (m)")
    plt.grid()
    plt.show()

    plt.figure(figsize=(10,4))
    plt.plot(DistCum,DiffaltV)
    plt.fill_between(DistCum,DiffaltV,alpha=0.1)
    plt.xlabel("Distance (m)")
    plt.ylabel("Diff Altura (m)")
    plt.grid()
    plt.show()

    plt.figure(figsize=(10,4))
    plt.plot(DistCum,Pente)
    plt.fill_between(DistCum,Pente,alpha=0.1)
    plt.xlabel("Distance (m)")
    plt.ylabel("Pente (°)")
    plt.grid()
    plt.show()

DataFinal = []

for i in range(len(LatSichr)-1):
    DataFinal.append([i,LatSichr[i],LonSichr[i],DistCum[i],MaxSpeed[i],Pente[i],elev_list[i],duration])
DataFinal.insert(0,['Num','Lat','Lng','Dist (m)','MaxSpeed (m/s)','Slope (rad)','Altitude (m)','Duree (s)'])
writeCsv(DataFinal,"dataResolE3")







