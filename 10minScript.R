library(plyr)
library(dplyr)
library(pryr)
library(openxlsx)
library(readxl)
library(readr)
library(leaflet)
library(plotly)
library(tidyverse)
library(DT)
library(data.table)
library(hablar)
library(outliers)
library(RODBCext)

print(Sys.time())
setwd("C:/Users/enes.ahmeti/Documents/ShinyAPPS/CateringDashboard")
#setwd("C:/Users/Server/Desktop/ShinyApps/CateringDashboard")

################## RFQs Calculations ##########################
#dbhandle = odbcDriverConnect('driver={SQL Server};server=DESKTOP-DJK8HJS\\ENES;database=AVSSOFT;trusted_connection=true')    local connection.
dbhandle <- odbcDriverConnect("driver={SQL Server};Server=192.168.2.202; Database=AVSSOFT; Uid=sa;Pwd=EDMAR'2007")
#RFQs = read_xlsx("ALLSALES.xlsx")
query = "SELECT ORDERDATE, OPRID, SUBDIVISIONS,SHIPNAME, DELIVERYPORT, IPTALSEBEP, LDELIVERYEXPENCES, LLAUNCHSERVICE,LOTHEREXPENSES FROM AllListFinalUSD"
RFQs = data.frame(sqlExecute(channel = dbhandle, query = query, fetch = TRUE, stringsAsFactors = FALSE))
RFQs$OPRID[RFQs$OPRID == '0'] = "Cancelled" #Changing the names from 0 to Cancelled
RFQs$OPRID[RFQs$OPRID == '8'] = "Delivered"
DeliveredSales = filter(RFQs, RFQs$OPRID == "Delivered") #Filter data according to Delivered
DeliveredSalesCatering = filter(DeliveredSales, DeliveredSales$SUBDIVISIONS == "CATERING")
CancelledSales = filter(RFQs, RFQs$OPRID == "Cancelled")
CancelReasonsCatering = filter(CancelledSales, CancelledSales$SUBDIVISIONS == "CATERING") #Get the cancellation reasons
###############################################################
################## foods Calculations #########################

#query = "SELECT  AY, CvrtQty,DosyaNo, COUNTRY, DELIVERYPORT, REQDATE, Code, Description, MainGroup, PrchNetPriceUsd, SaleNetPriceUsd,SuppName  FROM ProductSearch2 
#where REQDATE >= Convert(datetime, '2018-01-01')"
query = "SELECT  AY, CvrtQty,DosyaNo, COUNTRY, DELIVERYPORT, REQDATE, Code, Description, MainGroup, PrchNetPriceUsd, SaleNetPriceUsd,SuppName, OPRID  FROM ProductSearch2 
where REQDATE >= Convert(datetime, '2019-01-01') AND OPRID = 8"
foods <-  data.frame(sqlExecute(channel = dbhandle, query = query, fetch = TRUE, stringsAsFactors = FALSE))
odbcClose(dbhandle)

PortDF = read.csv("Portss.csv", header = TRUE, sep = ",",stringsAsFactors  = FALSE)

foods = setDT(foods)[, rm := !PrchNetPriceUsd %in% boxplot.stats(PrchNetPriceUsd)$out, Code][(rm)] #Removing the outliers from each of the food units the data

#Fixing bugs:
foods$COUNTRY[foods$COUNTRY == 'TURKEY'] = 'Turkey'
DeliveredSalesCatering$ORDERDATE = as.Date(DeliveredSalesCatering$ORDERDATE)
foods = foods[foods$PrchNetPriceUsd != 0,] #Remove the not sold items. 


#Creating the masterlist:
Food.Units = plyr::count(foods$Code)
Food.Units = Food.Units[order(Food.Units$freq),] #Ordering the units from smallest to largest:
Food.Units = na.omit(Food.Units)

#Getting the names of these food units:
for (i in 1:length(Food.Units$x)){
  name = as.character(Food.Units$x[i])
  unitdescriptions = (foods[which(foods[,7] == name), 8])
  #We consider the name that was used the most for the product:
  unitdescriptions = plyr::count(unitdescriptions)
  unitdescriptions = unitdescriptions[order(unitdescriptions$freq),]
  len = length(unitdescriptions$freq)
  Food.Units$Description[i] = unitdescriptions$Description[len]
  name = 0}

#Check each code in how many ports was supplied to:
for (i in 1:length(Food.Units$x)){
  name = as.character(Food.Units$x[i])
  Portnumber = (foods[which(foods[,7] == name), 5])
  #Count all the ports :
  Portnumber = plyr::count(Portnumber)
  Portnumber = Portnumber[order(Portnumber$freq),]
  len = length(Portnumber$freq)
  Food.Units$NumberofPorts[i] = len
  name = 0 }

#Checking the amount of kilograms per unit:
for (i in 1:length(Food.Units$x)){
  name = as.character(Food.Units$x[i])
  kilogram = sum(foods[which(foods[,7] == name), 2], na.rm = TRUE)
  Food.Units$KG.Liter[i] = kilogram
  name = 0}

#Adding the main group to each unit:
for (i in 1:length(Food.Units$x)){
  name = as.character(Food.Units$x[i])
  MainGroup = (foods[which(foods[,7] == name), 9])
  Food.Units$MainGroup[i] = MainGroup$MainGroup[1]}

#Getting the percentage of all the units over the total no of supplies:
#It may not be needed since it is for the frequency ABC analysis
#AllSupplies = plyr::count(foods$DosyaNo)
#AllSupplies =length(AllSupplies$x)
#Food.Units$Percentage = Food.Units$freq/AllSupplies

#Removing the cabin files:
Food.Units = dplyr::filter(Food.Units, Food.Units$MainGroup !="Cabin")

#Removing the 111111 items:
Food.Units = Food.Units[!(Food.Units$x == "111111"),]

#Getting the average price per product:
for (i in 1:length(Food.Units$x)){
  name = as.character(Food.Units$x[i])
  prices = foods %>%
    filter(foods$Code == name)
  average = mean(prices$PrchNetPriceUsd, na.rm = TRUE)
  Food.Units$PurchasePrice[i] = average}

#ABC analysis per kilogram:
ABCKilogram = Food.Units
ABCKilogram = na.omit(ABCKilogram)
ABCKilogram = ABCKilogram[order(ABCKilogram$KG.Liter),]

#Taking the cummualtive sum for all the kilograms:
ABCKilogram$Cumkg = cumsum(ABCKilogram$KG.Liter)

#Taking the cummulaitve percentage:
cumkg = sum(ABCKilogram$KG.Liter)
ABCKilogram$CumPercent = (ABCKilogram$Cumkg / cumkg)

#Adding 20% in group A, 50% in group B, 30% in group c. 
#If Kilogram ABC analysis is needed.
#A1 = ABCKilogram %>% dplyr::filter(ABCKilogram$CumPercent >= 0.80)
#B1 = ABCKilogram %>% dplyr::filter(ABCKilogram$CumPercent<= 0.80,
#ABCKilogram$CumPercent >= 0.50)
#C1 = ABCKilogram %>% dplyr::filter(ABCKilogram$CumPercent < 0.50)

#Ordering and getting the top 100 units as part of our masterlist:
ABCKilogram = ABCKilogram[order(ABCKilogram$CumPercent),]
ABCKilogramTop100 = ABCKilogram[(length(ABCKilogram$x)-99):length(ABCKilogram$x),]

####
#Master List per Country: RUN IT IF NEEDED.
#Ordered from smallest to most wanted. 
#MasterList <- ABCKilogramTop100 %>%
#dplyr::select(1,3, 8)

#Getting all the countries from the data:
Countries = plyr::count(foods$COUNTRY)
TopCountries = Countries
#TopCountries = TopCountries[order(-TopCountries$freq),]

#Adding all the country columns to the Master List:
#Countries = as.character(Countries$x)
#MasterList[Countries] <- NA

#Computing the average price for all the countries:
#for (i in 1:length(MasterList$x)){
# name = MasterList$x[i]
#prices = foods %>%
# filter(foods$Code == name)
#for (j in 1:length(Countries)){
# countryname = as.character(Countries[j])
#  con = prices %>% 
#   filter(prices$COUNTRY == countryname)
#  average = mean(con$PrchNetPriceUsd, na.rm = TRUE)
# MasterList[i,j+3] <- average}}

#Filling NAs with world average:
#for (i in 1:length(MasterList$x)){
# Val = MasterList[i,3]
#  for (j in 1:length(MasterList)){
#   if (is.na(MasterList[i,j])){
#    MasterList[i,j] = Val}}}

#Adding a row with the totals of each country:
#library(janitor)
#MasterList = MasterList %>%
# adorn_totals("row")
###

#The Top.Ports data is for the select inputs:
Top.Ports = plyr::count(foods$DELIVERYPORT)
Top.Ports = Top.Ports[order(Top.Ports$freq),]

###MasterList per Port:
#Ordered from smallest to most wanted. 
MasterListPort = ABCKilogramTop100 %>%
  dplyr::select(1,3,6, 7)
MasterListPortMin = ABCKilogramTop100 %>%
  dplyr::select(1,3,6, 7)
MasterListPortMax = ABCKilogramTop100 %>%
  dplyr::select(1,3,6, 7)

#Getting all the Ports from the data:
Ports = plyr::count(foods$DELIVERYPORT)

#Getting the average delivery price for each port:
PortsDelPrice = Ports
for (i in 1:length(PortsDelPrice$x)){
  filt = filter(DeliveredSalesCatering, DeliveredSalesCatering$DELIVERYPORT == PortsDelPrice$x[i])
  TotalOperations <- length(filt$OPRID)
  filt2 = filter(filt, filt$LDELIVERYEXPENCES > 0)
  filt3 = filter(filt, filt$LOTHEREXPENSES > 0 )
  OtherExpenses <- round(mean(filt3$LOTHEREXPENSES, na.rm = TRUE),2)
  filt4 = filter(filt, filt$LLAUNCHSERVICE > 0 )
  LaunchService <- round(mean(filt4$LLAUNCHSERVICE, na.rm = TRUE),2)  #Getting the average launch service delivery price:
  DeliveryOperations <- length(filt2$OPRID)
  AvgPrice = round(mean(filt2$LDELIVERYEXPENCES, na.rm = TRUE),2)
  PortsDelPrice$Percentage[i] = round(DeliveryOperations/TotalOperations,2)*100
  PortsDelPrice$AverageDeliveryPrice[i] = AvgPrice
  PortsDelPrice$AverageLaunchService[i] = LaunchService
  PortsDelPrice$AverageOtherExpenses[i] = OtherExpenses}
PortsDelPrice[is.na(PortsDelPrice)] <- 0
PortsDelPrice$Percentage <- paste0(PortsDelPrice$Percentage, "%")
PortsDelPrice$AverageDeliveryPrice <- paste0("$",PortsDelPrice$AverageDeliveryPrice)
PortsDelPrice$AverageLaunchService <- paste0("$",PortsDelPrice$AverageLaunchService)
PortsDelPrice$AverageOtherExpenses <- paste0("$",PortsDelPrice$AverageOtherExpenses)
PortsDelPrice = dplyr::select(PortsDelPrice, 1, 3, 4, 5, 6)

#We are transposing the dataframe so that the user can select the desired port. 
PortsDelPrice = transpose(PortsDelPrice)
colnames(PortsDelPrice) = Ports$x #Give the columns the names of the ports.
PortsDelPrice = PortsDelPrice[2:length(PortsDelPrice$Aarhus),] #Remove the unnecessary first row
rownames(PortsDelPrice) = c("Extra Price Percentage", "Average Delivery Cost", "Launch Services",
                            "Other Expenses") #Start the row numbers from 1 again.

#Adding all the Port columns to the Master List:
Ports = as.character(Ports$x)
MasterListPort[Ports] = NA
MasterListPortMin[Ports] = NA
MasterListPortMax[Ports] = NA

#Computing the average price for all the Ports:
for (i in 1:length(MasterListPort$x)){
  name = MasterListPort$x[i]
  prices = foods %>%
    filter(foods$Code == name)
  for (j in 1:length(Ports)){
    portname = as.character(Ports[j])
    con = prices %>% 
      filter(prices$DELIVERYPORT == portname)
    average = mean(con$PrchNetPriceUsd, na.rm = TRUE)
    MasterListPort[i,j+4] = average}}

#Computing the Minimum Value for all the ports:
for (i in 1:length(MasterListPortMin$x)){
  name = MasterListPort$x[i]
  prices = foods %>%
    filter(foods$Code == name)
  for (j in 1:length(Ports)){
    portname = as.character(Ports[j])
    conmin = prices %>% 
      filter(prices$DELIVERYPORT == portname)
    Minimum = min(s(conmin$PrchNetPriceUsd, ignore_na = TRUE))
    #Minimum = min(con$PrchNetPriceUsd, na.rm = TRUE)
    MasterListPortMin[i,j+4] = Minimum}}

#Computing the Maximum Values for all the ports:
for (i in 1:length(MasterListPortMax$x)){
  name = MasterListPort$x[i]
  prices = foods %>%
    filter(foods$Code == name)
  for (j in 1:length(Ports)){
    portname = as.character(Ports[j])
    con = prices %>% 
      filter(prices$DELIVERYPORT == portname)
    Maximum = max(s(con$PrchNetPriceUsd,ignore_na = TRUE))
    MasterListPortMax[i,j+4] = Maximum}}

MasterListPortMin[nrow(MasterListPortMin)+1,] = NA
MasterListPortMax[nrow(MasterListPortMax)+1,] = NA

#Filling NAs with world average:
for (i in 1:length(MasterListPort$x)){
  Val = MasterListPort[i,4]
  for (j in 1:length(MasterListPort)){
    if (is.na(MasterListPort[i,j])){
      MasterListPort[i,j] = Val}}}


#ordering the units according to the masterlist:
orderLEVES =  c("BEEF", "PORK", "LAMB", "POULTRY", "FISH", "HAM & SAUSAGES", "BAKING GOODS", 
   "FLOUR, RICE, NOODLES", "DRY CEREALS, MUESLI, SEMOLINA", "JAM, HONEY, BREAD SPREAD", 
   "SAUCES & FATS", "SOUPS & BOUILLON POWDER", "SPICES & HERBS", "BEVERAGES", "DESSERTS",
   "ASIAN FOOD", "CANNED FOOD", "FRUITS & VEGETABLES FROZEN", "JUICE", "DAIRY PRODUCTS", 
   "FRUITS & VEGETABLES", "DRINKING WATER") #create the given order. 
LevelsCOunt = plyr::count(MasterListPort$MainGroup) #count all different types of maingroups
MissingGroups = as.character(LevelsCOunt$x[!LevelsCOunt$x %in% orderLEVES]) #Check what else is different.
orderLEVES = c(orderLEVES, MissingGroups) #add the different units to the end of the list. 
print(orderLEVES)
MasterListPort$MainGroup = factor(MasterListPort$MainGroup, levels = orderLEVES) #create them as levels.
MasterListPortMin$MainGroup = factor(MasterListPortMin$MainGroup, levels = orderLEVES)
MasterListPortMax$MainGroup = factor(MasterListPortMax$MainGroup, levels = orderLEVES)
MasterListPort = MasterListPort[order(MasterListPort$MainGroup),]
MasterListPortMin = MasterListPortMin[order(MasterListPortMin$MainGroup),]
MasterListPortMax = MasterListPortMax[order(MasterListPortMax$MainGroup),]

#Add totals in the end of the list:
library(janitor)
MasterListPort = MasterListPort %>%
  adorn_totals("row")

MasterListPort = format(MasterListPort, digits = 2)


ShipCount = plyr::count(DeliveredSalesCatering$SHIPNAME)

#Getting the world average value for each port with lat and long
TransposeMasterlist = transpose(MasterListPort)
rownames(TransposeMasterlist) = colnames(MasterListPort)
TransposeMasterlist = TransposeMasterlist[5:length(TransposeMasterlist$V1),]
TransposeMasterlist = setDT(TransposeMasterlist, keep.rownames = TRUE)[]
for (i in 1:length(PortDF$Adress)){
    PortDF$WorldAverage[i] <- as.numeric(TransposeMasterlist[which(TransposeMasterlist[,1] == PortDF$Adress[i]), 102])
}
PortDF$WorldAverage <- vapply(PortDF$WorldAverage, paste, collapse = ", ", character(1L))


# Suppliers Tab:
Suppliers = plyr::count(foods$SuppName)
Suppliers = na.omit(Suppliers)

#Write this file to get the port lat and long if needed:
#NoPorts = plyr::count(foods$DELIVERYPORT)
#write.csv(NoPorts, file = "xxx.csv", quote = TRUE)

################################################
#Creating the necessary variables for the app to use:

write.csv(foods, file = "foods.csv", quote = TRUE)
write.csv(MasterListPort, file = "MasterListPort.csv", quote = TRUE) 
write.csv(MasterListPortMin, file = "MasterListPortMin.csv", quote = TRUE)
write.csv(MasterListPortMax, file = "MasterListPortMax.csv", quote = TRUE)
write.csv(CancelReasonsCatering, file = "CancelReasonsCatering.csv", quote = TRUE)
write.csv(PortsDelPrice, file = "PortsDelPrice.csv", quote = TRUE)
write.csv(DeliveredSalesCatering, file = "DeliveredSalesCatering.csv", quote = TRUE)
write.csv(TopCountries, file = "TopCountries.csv", quote = TRUE)
write.csv(ShipCount, file = "ShipCount.csv", quote = TRUE)
write.csv(Top.Ports, file = "Top.Ports.csv", quote = TRUE)
write.csv(PortDF, file = "PortDF.csv", quote = TRUE)
write.csv(Suppliers, file = "Suppliers.csv", quote = TRUE)
print(Sys.time())
