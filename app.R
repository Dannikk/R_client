library(shiny)


ui <- fluidPage(
  titlePanel("Patients database"),
  # selectInput("dataset", label = "Dataset", choices = ls("package:datasets")),
  sidebarLayout(
    sidebarPanel(
      titlePanel("Add new patient"),
      textInput("name", "Enter patient name:"),
      numericInput("age", "Enter patient age:", value = NULL, min = 0, max = 150, step = 1),
      textInput("desease", "Enter desease:"),
      actionButton("add", "Add patient"),
      hr(),
      verbatimTextOutput("result")
    ),
    mainPanel(
      titlePanel("Patients:"),
      DT::dataTableOutput("table")
    )
  )
)

server <- function(input, output, session) {
  config <- rjson::fromJSON(file="config.json")
  db_url <- config$db_url


  observeEvent(input$add, {

      output$result <- renderText({
          "Some fields are empty"
          })
      req(input$name, input$age, input$desease)

      patient <- data.frame(name = input$name,
                              desease = input$desease,
                              age = input$age)

      jsonQuery <- rjson::toJSON(patient)

      POST(url = db_url,
          body =  jsonQuery,
          verbose(),
          httr::add_headers(`accept` = 'application/json'),
          httr::content_type('application/json'))


      output$result <- renderText({
          "Good job"
          })
      output$table <- renderDataTable(getData(db_url))
  })

  output$table <- renderDataTable(getData(db_url))
}

shinyApp(ui, server)