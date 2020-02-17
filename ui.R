ui = tagList(
    
    tags$style("
             body {-moz-transform: scale(0.90, 0.90); /* Moz-browsers */zoom: 0.90; /* Other non-webkit browsers */
    zoom: 90%; /* Webkit browsers */}"),
    useShinyjs(),                           
    extendShinyjs(text = jsResetCode, functions = "reset"),
    useShinyalert(), #Use shiny alerts for pop up messages. 
    #shinythemes::themeSelector(),
    navbarPage(
        theme = shinytheme("sandstone"),
        "AVS CATERING ADVISER", id = "navbar",
        
        #Tab 1:
        tabPanel("Countries/Ports",
                 sidebarLayout(
                     sidebarPanel(
                         selectInput("Country.Input", "Select Country", choices = NULL),
                         selectInput("Port.Input", "Select Port", choices = NULL),
                         actionButton("getMessages", "Messages")
                         ,width = 2),
                     mainPanel(plotlyOutput("CountriesPlot"), br(), br(), br(), br(),  plotlyOutput("coolplot"),
                               ))),
        
        #Tab 2:
        tabPanel("Comparisons",
                 mainPanel(width = 12, tabsetPanel(
                     tabPanel("Masterlist Price Comparison",
                              fluidRow(column(width = 2, "", offset = 2)),
                              fluidRow(
                                  column(width = 2, br(), selectInput("Port.MasterList", "Select Port 1",
                                                                      choices = NULL)),
                                  column(width = 2 , br(), selectInput("Port1.MasterList", "Select Port 2",
                                                                       choices = NULL)),
                                  column(width = 2 , br(), selectInput("Port2.MasterList", "Select Port 3",
                                                                       choices = NULL)),
                                  column(width = 1, br(), br(), actionButton("GetTotal", label = "Calculate Min")),
                                  column(width = 5, br(), br(), br(), htmlOutput('MinTotal'))),
                              fluidRow(
                                  column(width = 12, align = "center", DTOutput("results")))),
                     tabPanel("Cancellation Reasons", 
                              fluidRow(
                                  column(width = 12, align = 'center', br(), br(), DTOutput('PortRejectionReasons')))),
                     
                     tabPanel("Average Extra Cost Per Port",
                              fluidRow(
                                  column(width = 12, align = 'center', br(), br(), DTOutput('AverageDelPrice'))
                              ))))),
        #Tab 3:
        tabPanel("MAP", 
                 mainPanel(width = 12,
                           fluidRow(leafletOutput("mymap")),
                           fluidRow(plotlyOutput("Histogram")))),
        
        
        
        #Tab 4:
        
        tabPanel("Ship Trajectory",
                 fluidRow(
                     column(selectInput("Ship.Input", "Select Vessel", choices = NULL, selected = NULL), width = 2),
                     #column(dateRangeInput("dates", "Date range", start = NULL, end = NULL, min = NULL, max = NULL), width = 3),
                     column(sliderInput(inputId = "time", label = "Supplied Times",min = NA, max = NA,value = NA,
                                        step=NULL, animate=TRUE),width = 4)),
                 fluidRow(leafletOutput("ShipDir", height = 750)),
                 tags$style(type="text/css", " .leaflet-fade-anim .leaflet-tile, .leaflet-fade-anim .leaflet-popup {opacity: 1 !important;}")),
        
        #Tab 5:
        
        tabPanel(title = "Suppliers",
                 fluidRow(
                     column(selectInput("Supplier.Input", "Select Supplier", choices = NULL, selected = NULL), width =2),
                     column(selectInput("Code.Input", "Select Product Code", choices = NULL, selected = NULL), width =2)),
                 fluidRow(
                     column(textOutput("NoSupplies"), width = 12),
                     column(plotlyOutput("SuppliersPlot"), width = 12)
                     
                 )),
                        
        
        
        tabPanel(title = "Refresh Data")
        
))
