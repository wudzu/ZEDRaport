library(shiny)
shinyServer(
  #runApp(paste(getwd(),"/shiny",sep = ""))
  
  function(input, output) {
    dat = read.csv("elektrownie.csv", header = TRUE)
    data <- dat[c(51,1:50)]
    
    colnames_tmp <- colnames(data)
    colnames_tmp[3] <- "idMiejsca"
    colnames_tmp[4] <- "idModelu"
    colnames_tmp[5] <- "idMarki"
    colnames_tmp[8] <- "wiekWMiesiacach"
    colnames_tmp[9] <- "rok"
    colnames_tmp[10] <- "dzien"
    colnames_tmp[11] <- "moment"
    colnames_tmp[13] <- "temperaturaOtoczenia"
    colnames_tmp[14] <- "naslonecznienie"
    colnames_tmp[15] <- "cisnienie"
    colnames_tmp[16] <- "predkoscWiatur"
    colnames_tmp[17] <- "wilgotnosc"
    colnames_tmp[19] <- "punktRosy"
    colnames_tmp[20] <- "lozyskoWiatrowe"
    colnames_tmp[21] <- "zachmurzenie"
    
    colnames_tmp[22] <- "temperaturaI"
    colnames_tmp[23] <- "naslonecznienieI"
    colnames_tmp[24] <- "cisnienieI"
    colnames_tmp[25] <- "predkoscWiatuIr"
    colnames_tmp[26] <- "wilgotnoscI"
    colnames_tmp[27] <- "punktRosyI"
    colnames_tmp[28] <- "lozyskoWiatroweI"
    colnames_tmp[29] <- "zachmurzenieI"
    
    colnames_tmp[30] <- "odleglosc"
    colnames_tmp[31] <- "wysokosc"
    colnames_tmp[32] <- "szerkoscGeograficzna"
    colnames_tmp[33] <- "wysokoscI"
    colnames_tmp[34] <- "szerkoscGeograficznaI"
    
    colnames_tmp[50] <- "wspolczynnikNaslonecznieniaPVGIS"
    colnames_tmp[51] <- "wspolczynnikNaslonecznieniaPVGISI"
    colnames(data) <- colnames_tmp
    
    # uzycie tylko danych liniowych
    data <- data[c(1,8:11,13:34,50:51)]
    
    # podzial danych na uczace i testowe
    indexes <- reactive({
      set.seed(666);
      sample(1:nrow(data), size=input$partition*nrow(data));
    })
    
    test <- reactive({
      data[indexes(),];
    })
    
    train <- reactive({
      data[-indexes(),]
    })
    
    # korelacja innych wspolczynnikow do mocy
    correlation <- reactive({
      temporary <- c(1:29);
      for (i in 2:29) {
        temporary[i] <- cor(train()[[i]],train()[[1]]);
        if (temporary[i] < 0) {
          temporary[i] <- -temporary[i];
        }
      }
      temporary[1] <- -1;
      
      temporary;
    })
    
    # wspolczynniki o wymaganej przez uzytkownika korelacji
    good <- reactive({
      min=input$decimal;
      correlation() > min;
    })
    
    goodAnd1 <- reactive({
      temporary <- good();
      temporary[1] <- T;
      temporary;
    })
    
    model <- reactive({
      temporary <- lm(train()[goodAnd1()])
      temporary
    })
    
    # Obszar na wykres w ui
    output$correlation <- renderPlot({
      # Render a barplot
      barplot(correlation()[good()],names.arg = colnames(train()[good()]),
              main="KORELACJA",
              ylab="Korelacja do mocy",
              xlab="Wspolczynnik")
    
      
    })
    
    
    # obszar na tabele w ui
    output$lmtable <- renderTable({
      
      cof <- model()$coefficients
      
      names <- names(model()$coefficients)
      names[1] = 'bias'
      
      hprint <- matrix("",model()$rank,2)
      for (i in 1:model()$rank) {
        hprint[i,2] <- cof[i]
        hprint[i,1] <- names[i]
      }
      
      as.data.frame(hprint,optional = T)
    })
    
    # obszar na blad modelu w ui
    output$summary <- renderPrint({
      error_vec <- unname(predict.lm(model(),test())) - test()[,1]
      error_vec <- error_vec * error_vec
      mean(error_vec)
    })
    
    
      
  }
)