server <- function(input, output, session) {
    
    #Reading the data:
    foods = read.csv(file = "foods.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)
    MasterListPort = read.csv(file = "MasterListPort.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE, check.names = FALSE)
    MasterListPortMin = read.csv(file = "MasterListPortMin.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE, check.names = FALSE)
    MasterListPortMax = read.csv(file = "MasterListPortMax.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE, check.names = FALSE)
    CancelReasonsCatering = read.csv(file = "CancelReasonsCatering.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)
    DeliveredSalesCatering = read.csv(file = "DeliveredSalesCatering.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)
    PortsDelPrice = read.csv(file = "PortsDelPrice.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE, check.names = FALSE)
    PortDF = read.csv(file = "PortDF.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)
    TopCountries = read.csv(file = "TopCountries.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)
    ShipCount = read.csv(file = "ShipCount.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE)
    Top.Ports = read.csv(file = "Top.Ports.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE, check.names = FALSE)
    Suppliers = read.csv(file = "Suppliers.csv", header = TRUE, sep = ",", stringsAsFactors = FALSE, check.names = FALSE)
    #DeliveredSalesCatering$ORDERDATE = as.Date(DeliveredSalesCatering$ORDERDATE)
    
    observe({
        updateSelectInput(session, "Country.Input", choices = TopCountries$x, selected = TopCountries$x[TopCountries$x == "Spain"])})
    
    observe({
        updateSelectInput(session, "Ship.Input", choices = ShipCount$x, selected = ShipCount$x[ShipCount$x == "ESPADON"])})
    
    observe({
        updateSelectInput(session, "Port.MasterList", choices = Top.Ports$x, selected = Top.Ports$x[Top.Ports$x == "Zeyport"])})
    
    observe({
        updateSelectInput(session, "Port1.MasterList", choices = Top.Ports$x, selected = Top.Ports$x[Top.Ports$x == "Antalya"])})
    
    observe({
        updateSelectInput(session, "Port2.MasterList", choices = Top.Ports$x, selected = Top.Ports$x[Top.Ports$x == "Ambarli"])})
    
    v <- reactiveValues()
    CountrySelected <- reactive({
        filter(foods, foods$COUNTRY == input$Country.Input)})

    observeEvent(CountrySelected(), {
        choices <- unique(CountrySelected()$DELIVERYPORT)
        updateSelectInput(session, "Port.Input", choices = choices) })
    
    output$CountriesPlot <- renderPlotly({
        validate(need(input$Country.Input != "", "No Country selected")) # display custom message in need
        color = I("antiquewhite")
        filters <- filter(foods, foods$COUNTRY == input$Country.Input)
        Agg1 <- aggregate(as.numeric(filters$PrchNetPriceUsd), by = list(filters$SuppName), FUN=sum)
        plot_ly(Agg1, x = ~Agg1$Group.1, y = ~Agg1$x, type = 'bar', color = color) %>%
            layout(showlegend = FALSE, xaxis = list(title = "Suppliers"), yaxis = list(title = 'Sale Net Price USD')) })  
    
    output$coolplot <- renderPlotly({
        validate(need(input$Port.Input != "", "No Port selected"))
        color = I("antiquewhite")
        filtered <-
            foods %>%
            filter(foods$DELIVERYPORT == input$Port.Input)
        Agg <- aggregate(as.numeric(filtered$PrchNetPriceUsd), by=list(filtered$SuppName), FUN=sum)
        plot_ly(Agg, x = ~Agg$Group.1, y = ~Agg$x, type = 'bar', color = color) %>%
            layout(showlegend = FALSE, xaxis = list(title = "Suppliers"), yaxis = list(title = 'Sale Net Price USD'))      
    })
    
    observeEvent(input$getMessages, {
      shinyalert("Errors updated: 17.02.2019", "Data used is from 01.01.2019. 
                   Data is updated daily. ", type = "info")
    })
    
    output$results <- renderDT({
        filtered <- MasterListPort %>%
            dplyr::select(2,3, 4, 5,  as.character(input$Port.MasterList),as.character(input$Port1.MasterList), as.character(input$Port2.MasterList))
        filteredMin <- MasterListPortMin %>%
            dplyr::select(as.character(input$Port.MasterList),as.character(input$Port1.MasterList), as.character(input$Port2.MasterList))
        filteredMax <- MasterListPortMax %>% 
            dplyr::select(as.character(input$Port.MasterList),as.character(input$Port1.MasterList), as.character(input$Port2.MasterList))
        
        MasterListTableFormat = dplyr::bind_cols(filtered, filteredMin, filteredMax)
        MasterListTableFormat = MasterListTableFormat %>%
            select(1,2,3,4,8,5,11,9,6,12,10,7,13)
        # Create a vector of min values to be able to color the rows of the datatable for the min values:
        min_val <- as.numeric(apply(MasterListTableFormat[, c(6,9,12)], 1, FUN = min))
        averageval = mean(as.numeric(MasterListTableFormat[,4])) #All the values larger than average must be colored in the table.
         observeEvent(input$GetTotal,{
            v$value <- paste0("Selecting the cheapest product from each port results in $",
                              sum(as.numeric(min_val[1:(length(min_val)-1)])))})
         inone <- reactive({
             as.character(input$Port.MasterList)
         })
         intwo <- reactive({
             as.character(input$Port1.MasterList)
         })
         inthree <- reactive({
             as.character(input$Port2.MasterList)
         })
         sketch = htmltools::withTags(table(class = 'display',thead(tr(
                    th(colspan = 4, 'General', class = "dt-center"),th(colspan = 3, inone(), class = "dt-center"),
                    th(colspan = 3, intwo(), class = "dt-center"), th(colspan = 3, inthree(), class = "dt-center")),
                    tr(lapply(rep( c('Code','Description','MainGroup','World Avg','Min', 'Average', 'Max', 'Min',
                                    'Average', 'Max', 'Min', 'Average', 'Max'), 1), th)))))
        
        datatable(MasterListTableFormat, container = sketch, rownames = FALSE, options = list(scrollX = TRUE, scrollY = "600px", columnDefs = list(list(className = 'dt-center', targets = 0:12)),
                                                                                                                       pageLength = 17, lengthMenu = c(17, 34, 51, 68, 85, 102),initComplete = JS("function(settings, json) {",
                                                                                                                                                                                                  "$(this.api().table().header()).css({'background-color': '#404040', 'color': '#fff'});",
                                                                                                                                                                                                  "}"))) %>%
            #formatStyle(5,`border-bottom` = 'solid 2px') %>%
            formatStyle(1, `border-left` = 'solid 2px') %>%
            formatStyle(3, `border-right` = "solid 2px") %>%
            formatStyle(4, `border-right` = "solid 2px") %>%
            formatStyle(7, `border-right` = "solid 2px") %>%
            formatStyle(10, `border-right` = "solid 2px") %>%
            formatStyle(13, `border-right` = "solid 2px") %>%
            formatStyle('PurchasePrice', target = 'row', backgroundColor = styleInterval(averageval, c('', 'antiquewhite')))
        #formatStyle(columns = c(6,9,12),
        #backgroundColor = styleEqual(levels = min_val , values = rep("antiquewhite", length(min_val))))
    })
    
    output$MinTotal <- renderText({
        HTML(paste0("<b>", v$value, "</b>"))})
    output$PortRejectionReasons <- renderDT({
        filtable <- filter(CancelReasonsCatering, CancelReasonsCatering$DELIVERYPORT == input$Port.MasterList)
        Reasons1 = plyr::count(filtable$IPTALSEBEP)
        Reasons1 = na.omit(Reasons1)
        Reasons1 = Reasons1[order(-Reasons1$freq),]
        PortOneName = as.character(input$Port.MasterList)
        Reasons1 = Reasons1 %>% 
            rename(
                PortOneName = x,
                Frequency = freq)
        
        filtable2 <- filter(CancelReasonsCatering, CancelReasonsCatering$DELIVERYPORT == input$Port1.MasterList)
        Reasons2 = plyr::count(filtable2$IPTALSEBEP)
        Reasons2 = na.omit(Reasons2)
        Reasons2 = Reasons2[order(-Reasons2$freq),]
        PortTwoName = renderText(input$Port1.MasterList)
        Reasons2 = Reasons2 %>% 
            rename(
                PortTwoName = x,
                Frequency = freq)
        
        
        filtable3 <- filter(CancelReasonsCatering, CancelReasonsCatering$DELIVERYPORT == input$Port2.MasterList)
        Reasons3 = plyr::count(filtable3$IPTALSEBEP)
        Reasons3 = na.omit(Reasons3)
        Reasons3 = Reasons3[order(-Reasons3$freq),]
        PortThreeName = renderText(input$Port2.MasterList)
        Reasons3 = Reasons3 %>% 
            rename(
                PortThreeName = x,
                Frequency = freq)
        
        
        mylist = list(Reasons1, Reasons2, Reasons3)
        max.rows = max(nrow(Reasons1), nrow(Reasons2), nrow(Reasons3))                        
        newmylist = lapply(mylist, function(x) {x[1:max.rows,]})
        Reason = do.call(cbind, lapply(newmylist, '['))
        
        datatable(head(Reason, 10), colnames = c(input$Port.MasterList, 'Frequency', 
                                                 input$Port1.MasterList, 'Frequency',  
                                                 input$Port2.MasterList, 'Frequency'), options = list(scrollX = TRUE, scrollY = "100%", columnDefs = list(list(className = 'dt-center', targets = 0:5)),
                                                                                                      pageLength = 17,
                                                                                                      lengthMenu = c(17, 34, 51, 68, 85, 102),
                                                                                                      searchHighlight = TRUE, "sDom" = "rt",
                                                                                                      initComplete = JS(
                                                                                                          "function(settings, json) {",
                                                                                                          "$(this.api().table().header()).css({'background-color': '#404040', 'color': '#fff'});",
                                                                                                          "}")), rownames = FALSE) %>%
            formatStyle(1, `border-left` = 'solid 2px') %>%
            formatStyle(2, `border-right` = 'solid 2px') %>%
            formatStyle(4, `border-right` = "solid 2px") %>%
            formatStyle(6, `border-right` = "solid 2px")
    })
    output$AverageDelPrice <- renderDT({
        TableOut = PortsDelPrice %>%
            select(as.character(input$Port.MasterList),as.character(input$Port1.MasterList),as.character(input$Port2.MasterList))
        rownames(TableOut) = c("Extra Cost Percentage", "Average Delivery Cost", "Launch Services",
                                    "Other Expenses")
        datatable(TableOut, list(scrollX = TRUE, scrollY = "100%",columnDefs = list(list(className = 'dt-center', targets = 1:3)),
                                 pageLength = 17,
                                 lengthMenu = c(17, 34, 51, 68, 85, 102),
                                 searchHighlight = TRUE, "sDom" = "rt",
                                 initComplete = JS(
                                     "function(settings, json) {",
                                     "$(this.api().table().header()).css({'background-color': '#404040', 'color': '#fff'});",
                                     "}")), rownames = TRUE) %>%
            formatStyle(1, `border-left` = 'solid 2px') %>%
            formatStyle(1, `border-right` = 'solid 2px') %>%
            formatStyle(2, `border-right` = "solid 2px") %>%
            formatStyle(3, `border-right` = "solid 2px")
    })
    
    
    output$mymap <- renderLeaflet({
      qpal <- colorQuantile(c("Green", "Yellow", "Red"), as.numeric(PortDF$WorldAverage), n = 3)
      leaflet(PortDF) %>% 
            addTiles() %>%
            addCircleMarkers(lng = PortDF$Longtitude, lat=PortDF$Latitude, label = PortDF$Adress, radius = 5, layerId = PortDF$Adress, color = qpal(PortDF$WorldAverage), fillOpacity = 0.5) %>% 
            addLegend("bottomright", pal = qpal, values = PortDF$WorldAverage, title = "Prices", opacity = 1) })
    observeEvent(input$mymap_marker_click, {
        p <- input$mymap_marker_click$id 
        print(p)
        filteredtable <- MasterListPort %>%
            dplyr::select(2,3,4,5, as.character(p))
        output$Histogram <- renderPlotly({
            WorldMean <- aggregate(as.numeric(filteredtable$PurchasePrice), by=list(filteredtable$MainGroup), FUN=sum)
            PortMean <- aggregate(as.numeric(filteredtable[,5]), by=list(filteredtable$MainGroup), FUN=sum)
            plot_ly(WorldMean, x= ~WorldMean$Group.1, y= ~WorldMean$x, type = 'bar', name = 'World Average') %>%
                add_trace(PortMean, x= ~PortMean$Group.1, y= ~PortMean$x, type = 'bar', name = p) %>%
                layout(xaxis = list(title = 'Food Group'), yaxis = list(title = 'Amount'), barmode = 'Food Group')
        }) })
    
    #Starting Ship Trajectory in the next codes:
    ShipSelected <- reactive({
        validate(need(input$Ship.Input != "", "No ship selected")) # display custom message in need
        DeliveredSalesCatering %>%
            filter(SHIPNAME == input$Ship.Input)})
    
    #observeEvent(input$Ship.Input, {
      #  updateDateRangeInput(session, "dates", label = "Date Range", 
       #                      start = min(ShipSelected()$ORDERDATE), end = max(ShipSelected()$ORDERDATE),
        #                     min = min(ShipSelected()$ORDERDATE), max = max(ShipSelected()$ORDERDATE))})
    
    #DateSelected <- reactive({filter(ShipSelected(),ShipSelected()$ORDERDATE >= input$dates)})
    
    observeEvent(ShipSelected(), {
        #Get the long,lat for each port that the selected ship has visited:
        Portlist = ShipSelected()$DELIVERYPORT
        longvalues = c()
        latvalues = c()
        for (i in 1:length(Portlist)){
            
            dats = filter(PortDF, PortDF$Adress == Portlist[i])
            if (length(dats$Adress == 0)){
                latvalues[i] = 0
                longvalues[i] = 0
            }
            if (length(dats$Adress > 0)) {
                latvalues[i] = dats$Latitude
                longvalues[i] = dats$Longtitude
            }}
        #Create a dataframe with the list of ports and its map values:
        mydf <- data.frame(Port = Portlist, lat = latvalues, long = longvalues)
        mydf <- na.omit(mydf)
        mydf$Order <- seq.int(nrow(mydf))
        updateSliderInput(session, "time", label = "Select Time", min = min(mydf$Order), 
                          max = max(mydf$Order), value = min(mydf$Order), step=1)
        
        points <- reactive({
            mydf %>% 
                filter(Order == input$time)})
        history <- reactive({
            mydf %>%
                filter(Order <= input$time)})
        
        
        output$ShipDir <- renderLeaflet({
            leaflet(options = leafletOptions(zoomControl = FALSE,
                                               minZoom = 3, maxZoom = 3)) %>%
                addTiles() %>%
                addMarkers(lng = ~points()$long,
                           lat = ~points()$lat,
                           data = points()) %>%
                addCircles(lng = ~history()$long,
                           lat = ~history()$lat,
                           label = ~history()$Port, weight = 25, opacity = 1,
                           color = I('orange'),
                           data = history()) %>%
                addPolylines(lng = ~long,
                             lat = ~lat, opacity = 0.5,
                             color = I('orange'),
                             data = history())})})
    
    
    
  # SUPPLIER TAB:
    
    observe({
      updateSelectInput(session, "Supplier.Input", choices = Suppliers$x, selected = Suppliers$x[Suppliers$x == "Atlas International Shipchandling & Trading Co Inc"])})
    #SuppliersSelected <- reactive({
     # filter(foods, foods$SuppName == input$Supplier.Input)})
    observe({
      updateSelectInput(session, "Code.Input", choices = MasterListPort$x, selected = MasterListPort$x[MasterListPort$x == "100342"])})
    
    output$SuppliersPlot <- renderPlotly({
      validate(need(input$Supplier.Input != "", "No Supplier selected")) # display custom message in need
      validate(need(input$Code.Input != "", "No Product selected")) # display custom message in need
      filtersz <- filter(foods, foods$SuppName == input$Supplier.Input & foods$Code == input$Code.Input)
      filtersz$REQDATE <- as.Date(filtersz$REQDATE)
      
      observeEvent(input$Supplier.Input, {
        if (length(filtersz$REQDATE) == 0){
          output$NoSupplies <- renderText(("This supplier never supplied such a product."))}
        if (length(filtersz$REQDATE) > 0){
          output$NoSupplies <- renderText((""))}
        })
      if (length(filtersz$REQDATE) > 0){
      plot_ly(x = ~filtersz$REQDATE, y = ~filtersz$PrchNetPriceUsd, mode = 'lines+markers', hoverinfo = 'text', 
              text = paste(filtersz$COUNTRY,",", filtersz$DELIVERYPORT)) %>%
        layout(hovermode = 'x+y', showlegend = FALSE, xaxis = list(title = filtersz$Description[3]), yaxis = list(title = 'Purchase Net Price USD'))}
    })
    
    
    observeEvent(input$navbar,({
        if (input$navbar == "Refresh Data") {
            js$reset()
        }}))
    
    
    
}


