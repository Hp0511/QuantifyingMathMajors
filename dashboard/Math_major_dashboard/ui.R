library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(DT)

ui <- dashboardPage(
  dashboardHeader(title = "University Math Major Dashboard"),
  
  dashboardSidebar(
    selectInput("school", "Select School", 
                choices = c("Denison University", "Kenyon College", "College of Wooster", 
                            "Oberlin College", "Carleton College", "Swarthmore College", 
                            "St.Olaf College", "Bowdoin College","Wellesley College", "Grinnell College"),
                selected = "Denison University"),
    
    sliderTextInput(
      inputId = "term",
      label = "Select Start Term:",
      choices = c("F2021", "S2021", "F2022", "S2022", "F2023", "S2023"),
      selected = "F2021",
      grid = TRUE,
      animate = TRUE
    )
  ),
  
  dashboardBody(
    fluidRow(
      box(title = "Path to Complete", width = 6, status = "primary", solidHeader = TRUE,
          DTOutput("path_table"),
          fluidRow(
            column(12,
                   selectInput("path_page", "Select Path:", choices = 1, selected = 1, width = "100%"),
                   div(style = "display: flex; justify-content: space-between; margin-top: -10px;",
                       actionButton("prev_path", "← Previous"),
                       actionButton("next_path", "Next →")
                   )
            )
          )
      ),
      box(title = "Schedule", width = 6, status = "primary", solidHeader = TRUE,
          downloadButton("download_schedule", "Download"),
          DTOutput("schedule_table")
      )
    )
  )
)
