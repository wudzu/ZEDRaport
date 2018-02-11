library(shiny)
shinyUI(fluidPage(
  titlePanel("Regresja liniowa danych z farm slonecznych"),
  sidebarLayout(
    sidebarPanel(
      h3('Dobor nastaw'),
      sliderInput("decimal", "Minimalna absolutna korelacja:",
                  min = 0, max = 0.8,
                  value = 0.4, step = 0.1),
      sliderInput("partition", "Czesc danych nalezaca do zbioru treningowego:",
                  min = 0.1, max = 0.9,
                  value = 0.5, step = 0.1)
    ),
    mainPanel(
      plotOutput("correlation"),
    
      h2("Model"),
      helpText("Zbudowano model liniowy na bazie wspolczynnikow o podanej minimalnej absolutnej korelacji.
               W poniżej tabeli zebrano bias oraz wszystkie współczynniki gotowego modelu."),
      tableOutput("lmtable"),
      helpText("Sredni blad kwadratowy modelu (RMSE)"),
      
      verbatimTextOutput("summary")
    )
    
  )
))