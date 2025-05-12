library(shiny)
library(DT)
library(readr)

server <- function(input, output, session) {
  
  # File mappings
  school_file_map <- list(
    "Denison University" = "denison_schedule.csv",
    "Kenyon College" = "kenyon_schedule.csv",
    "College of Wooster" = "wooster_schedule.csv",
    "Oberlin College" = "oberlin_schedule.csv",
    "Carleton College" = "carleton_schedule.csv",
    "Swarthmore College" = "swarthmore_schedule.csv",
    "St.Olar College" = "stolar_schedule.csv",
    "Bowdoin College" = "bowdoin_schedule.csv",
    "Wellesley College" = "wellesley_schedule.csv"
  )
  
  school_file_result <- list(
    "Denison University"   = "denison_result.csv",
    "Kenyon College"       = "kenyon_result.csv",
    "College of Wooster"   = "wooster_result.csv",
    "Oberlin College"      = "oberlin_result.csv",
    "Carleton College"     = "carleton_result.csv",
    "Swarthmore College"   = "swarthmore_result.csv",
    "St.Olar College"      = "stOlaf_result.csv",
    "Bowdoin College"      = "bowdoin_result.csv",
    "Wellesley College"    = "wellesley_result.csv"
  )
  
  # Load schedule data
  schedule_data <- reactive({
    file_name <- school_file_map[[input$school]]
    file_path <- file.path("data", "schedule", file_name)
    
    if (file.exists(file_path)) {
      df <- read_csv(file_path, show_col_types = FALSE)
      df[-1] <- lapply(df[-1], function(col) ifelse(col == 1, "\u2714", "\u274C"))
      return(df)
    } else {
      return(data.frame(Message = "No schedule available for selected school."))
    }
  })
  
  output$schedule_table <- renderDT({
    df <- schedule_data()
    datatable(df)
  })
  
  output$download_schedule <- downloadHandler(
    filename = function() {
      paste0(gsub(" ", "_", tolower(input$school)), "_schedule_", Sys.Date(), ".csv")
    },
    content = function(file) {
      df <- schedule_data()
      write.csv(df, file, row.names = FALSE)
    }
  )
  
  path_data <- reactive({
    file_name <- school_file_result[[input$school]]
    term <- input$term
    file_path <- file.path("data", "result", term, file_name)
    
    if (!file.exists(file_path)) {
      return(data.frame(Message = "Path file not found"))
    }
    
    # ✅ Read the FULL CSV
    full_df <- read_csv(file_path, col_names = FALSE, col_types = cols(.default = "c"))
    term_levels <- c("F2020", "S2021", "F2021", "S2022", "F2022", "S2023", "F2023", "S2024")
    start_index <- match(term, term_levels)
    
    result <- data.frame()
    row_index <- 1
    
    for (i in 1:nrow(full_df)) {
      row_data <- full_df[i, ]
      course_path <- unlist(row_data, use.names = FALSE)
      course_path <- course_path[!is.na(course_path) & course_path != ""]
      
      terms <- term_levels[start_index:(start_index + length(course_path) - 1)]
      terms <- head(terms, length(course_path))
      
      path_df <- data.frame(
        Course = course_path,
        Term = terms,
        PathID = row_index
      )
      
      result <- rbind(result, path_df)
      row_index <- row_index + 1
    }
    
    return(result)
  })
  
  
  # Render selected path
  output$path_table <- renderDT({
    df_all <- path_data()
    paths <- split(df_all, df_all$PathID)
    
    idx <- as.numeric(input$path_page)
    if (!is.na(idx) && idx <= length(paths)) {
      datatable(paths[[idx]], 
                options = list(dom = 't', paging = FALSE, ordering = FALSE),
                rownames = FALSE)
    } else {
      datatable(data.frame(Message = "Path does not exist"))
    }
  })
  
  # Update dropdown with number of paths
  observe({
    df_all <- path_data()
    n_paths <- length(unique(df_all$PathID))
    updateSelectInput(session, "path_page", choices = 1:n_paths, selected = 1)
  })
  
  # Previous button
  observeEvent(input$prev_path, {
    current <- as.numeric(input$path_page)
    if (!is.na(current) && current > 1) {
      updateSelectInput(session, "path_page", selected = current - 1)
    }
  })
  
  # Next button
  observeEvent(input$next_path, {
    df_all <- path_data()
    n_paths <- length(unique(df_all$PathID))
    current <- as.numeric(input$path_page)
    if (!is.na(current) && current < n_paths) {
      updateSelectInput(session, "path_page", selected = current + 1)
    }
  })
}
