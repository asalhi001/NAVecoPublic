##Initialisation

#Librairies
import os
from sys import argv
import json
import csv
import pyjsonviewer
import matplotlib.pyplot as plt
from math import *
import ast

plt.close('all')

#Chemin
os.chdir('C:/Users/ASALHI/Documents/MATLAB/NAVecoPublicBackUp/NAVecoScript/')

script, seg_speed_ext, seg_slope_ext, seg_slope_sample, constant_slope_ext, duration_user = argv

##ParamÃ¨tres

# #Segmentation par vitesse
# seg_speed = True
if (seg_speed_ext=='True'):
    seg_speed = True
elif (seg_speed_ext=='False'):
    seg_speed = False

#
# #Segmentation par pente
# seg_slope = True
if (seg_slope_ext=='True'):
    seg_slope = True
elif (seg_slope_ext=='False'):
    seg_slope = False
#
# #RÃ©solution de la segmentation par pente
# seg_slope_sample = 5 en degrees
seg_slope_sample=float(seg_slope_sample)
#
# #Pente constante(moyenne) sur chaque segment
# constant_slope = True
if (constant_slope_ext=='True'):
    constant_slope = True
elif (constant_slope_ext=='False'):
    constant_slope = False
#
# #Temps dÃ©sirÃ©e par le conducteur
# duration_user = 1000
duration_user=float(duration_user)


##Fonctions

def writeCsv(csvVar,csvName):
    with open('./'+csvName+'.csv', 'w', newline='') as csv_file:
        csv_writer = csv.writer(csv_file,delimiter=';')
        csv_writer.writerows(csvVar)

def loadCsv(csvName):
    csv_list = []
    with open('./'+csvName+'.csv', 'r', newline='') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=';', quotechar='|')
        for row in csv_reader:
            csv_list.append(row)
        return csv_list

##Main

data = loadCsv("dataResolE3")
data = data[1:]
#[['Num', 'Lat', 'Lng', 'Dist (m)', 'MaxSpeed (m/s)', 'Slope (rad)', 'Altitude (m)', 'Duree (s)']]

##Segmentation

split_points = [0]


#Segmentation par pente
# if(seg_slope):
#     ref_slope = float(data[0][5])
#     for i in range(1,len(data)):
#         slope_temp = data[i][5]
#         if (abs(float(slope_temp)-ref_slope)>=seg_slope_sample):
#             split_points.append(i)
#             ref_slope = float(slope_temp)
            

#Segmentation par pente negative (avec une distance de descente choisie "descent_distance")
if(seg_slope):
    descent_distance = 400 
    i=0
    j=0
    while(i < len(data) - 1 ):
        if( (float(data[i+1][6]) - float(data[i][6])) >= 0 ):
            
            while( (i < len(data) - 1 ) and ( float(data[i+1][6]) - float(data[i][6]) >= 0 ) ):
                i = i + 1 ;
                                
        else:
            split = i
            j=0
            while( (i < len(data) - 1 ) and ( float(data[i+1][6]) - float(data[i][6]) < 0 ) ) :
                i = i + 1 ;
                j = j + 1 ;
           
            if( (i < len(data) - 1 )  and ( float(data[i+1][6]) - float(data[i][6]) >= 0 ) and  ( j >= descent_distance ) ):
                split_points.append(split)
                j=0
         
print(split_points); 
   

#Segmentation par pente (variation prise entre chaque paire de point)
# if(seg_slope):
#     for i in range(0,len(data)-1):
#         previous_slope = float(data[i][5])
#         next_slope = float(data[i+1][5])     
#         if (abs(next_slope - previous_slope )>=seg_slope_sample):
#             split_points.append(i)

#     print(split_points);

# print(split_points);



#Segmentation par vitesse
if(seg_speed):
    ref_speed = float(data[0][4])
    for i in range(1,len(data)):
        if (float(data[i][4])!=ref_speed):
            split_points.append(i)
            ref_speed = float(data[i][4])
print(split_points)

#Segmentation par variation de vitesse choisie (on choisit la valeur de "Vitesse_variation")
# Vitesse_variation = 4
# if(seg_speed):
#     ref_speed = float(data[0][4])
#     for i in range(1,len(data)):
#         speed_tmp = data[i][4]
#         if ( abs(float(speed_tmp)-ref_speed) >= Vitesse_variation ):
#             split_points.append(i)
#             ref_speed = float(data[i][4])
#             print("True")
#     s=0         
#     print(split_points)
#     if(len(split_points) > 1 ):
#         for i in range(1, len(split_points)):
#             for k in range( split_points[i]  , split_points[i] ):
#                 s = s + float( data[k][4])
               
#             #data[k+1][4] =  sum(  float( data[ split_points[i]+1: split_points[i]+1 ][ 4 ] ) / ( split_points[i]-split_points[i]  ) )
#             #data[k+1][4] = s / ( split_points[i]-split_points[i]  ) 
#         print(( split_points[i]-split_points[i]  ))
#         data[ split_points[i]:split_points[i] ][ 4 ] = s / ( split_points[i]-split_points[i]  )  
#         print( data[ split_points[i]:split_points[i] ][ 4 ] )
#         s= 0 

#split_points.append(len(data))

#Segmentation

segmented_header = ['Num', 'Lat', 'Lng', 'Dist (m)', 'MaxSpeed (m/s)', 'Slope (rad)', 'Altitude (m)', 'Duree (s) T','MIN SPEED C','DistSeg','MIN DUREE C']
segmented_data = []
IndiceInit=1
DistInit=0

# ajouter le dernier point pour former le dernier segment 
split_points.append(len(data)) 

#print(split_points)

if(len(split_points)>1):
    #DÃ©coupage du trajet en segments
    split_points = list(set(split_points))
    split_points = sorted(split_points)
    for i in range(0,len(data)):
        segmented_data.append(data[i][:])
        
        if(i==split_points[IndiceInit]):
            if(IndiceInit!=(len(split_points)-1)):
                IndiceInit = IndiceInit+1
            DistInit = float(data[i-1][3])
        
        segmented_data[i][0]=IndiceInit
        if(IndiceInit!=len(split_points)-1):
               DiffDist=float(data[split_points[IndiceInit]-1][3])-DistInit
        else:
            DiffDist=float(data[len(data)-1][3])-DistInit

        if(float(segmented_data[i][4])*3.6>= 110):
            segmented_data[i].append(80/3.6)
            segmented_data[i].append(DiffDist)
            segmented_data[i].append(DiffDist/(80/3.6))
        elif(float(segmented_data[i][4])*3.6>= 70):
            segmented_data[i].append(40/3.6)
            segmented_data[i].append(DiffDist)
            segmented_data[i].append(DiffDist/(40/3.6))
        elif(float(segmented_data[i][4])*3.6>=50):
            segmented_data[i].append(25/3.6)
            segmented_data[i].append(DiffDist)
            segmented_data[i].append(DiffDist/(25/3.6))
        else:
            segmented_data[i].append(10/3.6)
            segmented_data[i].append(DiffDist)
            segmented_data[i].append(DiffDist/(10/3.6))
else:
    #split_points.append(len(data))
    for i in range(0,len(data)):
        segmented_data.append(data[i][:])
        segmented_data[i][0]=IndiceInit
        DiffDist=float(data[len(data)-1][3])-DistInit

        if(float(segmented_data[i][4])*3.6>= 110):
            segmented_data[i].append(80/3.6)
            segmented_data[i].append(DiffDist)
            segmented_data[i].append(DiffDist/(80/3.6))
        elif(float(segmented_data[i][4])*3.6>= 70):
            segmented_data[i].append(40/3.6)
            segmented_data[i].append(DiffDist)
            segmented_data[i].append(DiffDist/(40/3.6))
        elif(float(segmented_data[i][4])*3.6>=50):
            segmented_data[i].append(25/3.6)
            segmented_data[i].append(DiffDist)
            segmented_data[i].append(DiffDist/(25/3.6))
        else:
            segmented_data[i].append(10/3.6)
            segmented_data[i].append(DiffDist)
            segmented_data[i].append(DiffDist/(10/3.6))

segmented_data.insert(0,segmented_header)
writeCsv(segmented_data,"SegmentedData")

