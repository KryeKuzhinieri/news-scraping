foods = read.csv(file = "foods.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)
MasterListPort = read.csv(file = "MasterListPort.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE, check.names = FALSE)
Suppliers = plyr::count(foods$SuppName)
Suppliers = na.omit(Suppliers)

color = I("antiquewhite")
#filters <- filter(foods, foods$SuppName == input$Supplier.Input)
filters <- filter(foods, foods$SuppName == "Atlas International Shipchandling & Trading Co Inc" & foods$Code == "100342")
Agg1 <- aggregate(as.numeric(filters$PrchNetPriceUsd), by = list(filters$Code), FUN=sum)
filters$REQDATE <- as.Date(filters$REQDATE)
typeof(filters$REQDATE)
plot_ly(x = ~filters$REQDATE, y = ~filters$PrchNetPriceUsd, mode = 'lines+markers', 
        text = paste(filters$COUNTRY,",", filters$DELIVERYPORT,",", is.null())) %>%
  layout(showlegend = FALSE, xaxis = list(title = filters$Description[1]), yaxis = list(title = 'Purchase Net Price USD'))
?is_null
?plotly
