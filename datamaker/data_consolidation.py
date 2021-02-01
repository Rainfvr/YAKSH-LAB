# input project folder  location
import sys
projectfolder = sys.argv[1]
dt = projectfolder + '/data_tables'

import pandas as pd
import glob
import os

os.chdir(dt)

globbed_files_mac = glob.glob("*mac*") #creates a list of all csv files
print(globbed_files_mac)

data = [] # pd.concat takes a list of dataframes as an agrument

for csv in globbed_files_mac:
    frame = pd.read_csv(csv)
    frame['filename'] = os.path.basename(csv)
    data.append(frame)

combined = pd.concat(data, ignore_index=True) #dont want pandas to try an align row indexes
os.chdir(projectfolder)
combined.to_excel("mac_combined.xlsx")


os.chdir(dt)
globbed_files_bv = glob.glob("*Blood*") #creates a list of all csv files
print(globbed_files_bv)

data2 = [] # pd.concat takes a list of dataframes as an agrument

for csv in globbed_files_bv:
    frame = pd.read_csv(csv)
    frame['filename'] = os.path.basename(csv)
    data2.append(frame) 
combined2 = pd.concat(data2, ignore_index=True) #dont want pandas to try an align row indexes
os.chdir(projectfolder)
combined2.to_excel("bv_combined.xlsx")


os.chdir(dt)
globbed_files_neu = glob.glob("*Neu*")
print(globbed_files_neu)

data3  = []

for csv in globbed_files_neu:
    frame = pd.read_csv(csv)
    frame['filename'] = os.path.basename(csv)
    data3.append(frame)
combined3 = pd.concat(data3, ignore_index=True)
os.chdir(projectfolder)
combined3.to_excel("neu_combined.xlsx")

os.chdir(dt)
globbed_files_BV_Volume = glob.glob("*Volume*")
print(globbed_files_BV_Volume)

data4 = []

for csv in globbed_files_BV_Volume:
    frame = pd.read_csv(csv)
    frame['filename'] = os.path.basename(csv)
    data4.append(frame)
combined4 = pd.concat(data4, ignore_index=True)
os.chdir(projectfolder)
combined4.to_excel("BV_Volume_combined.xlsx")

with pd.ExcelWriter('Combined_Data.xlsx') as writer:
	combined.to_excel(writer,sheet_name='mac')
	combined4.to_excel(writer,sheet_name='BV_Volume')
	combined2.to_excel(writer,sheet_name='mac_bv_intensity')
	combined3.to_excel(writer,sheet_name='mac_neu_intensity') 
