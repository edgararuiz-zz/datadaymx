library(shiny)
library(recipes)
library(httr)
library(magrittr)
library(shinymaterial)
library(purrr)
library(r2d3)

load("receta.RData")

ui <- material_page(
  title = "Tensorflow y R",
  material_side_nav(
    fixed = TRUE,
    material_radio_button(
      "contract", "Contrato",
      choices = set_names(
        list("Month-to-month", "One year", "Two year"),
        c("Mes-a-mes", "1 año", "2 años")
      )
    ),
    material_radio_button(
      "internet", "Servicio de Internet",
      choices = set_names(
        list("DSL", "Fiber optic", "No"),
        c("DSL", "Fibra optica", "No")
      )
    ),
    material_dropdown(
      "paperless", "Factura sin papel",
      choices = list("Sí" = "Yes", "No" = "No")
    ),
    material_dropdown(
      "payment", "Método de pago",
      choices = set_names(
        list("Electronic check", "Mailed check", "Bank transfer (automatic)", "Credit card (automatic)"),
        c("Cheque eletrónico", "Por correo", "Transferencia bancaria", "Tarjeta de crédito")
      )
    ),
    material_slider("monthly", "Cargos mensuales", initial_value = 65, min_value = 12, max_value = 120),
    material_slider("total", "Cargos totales", initial_value = 2200, min_value = 12, max_value = 8800),

    material_dropdown("phone", "Phone Service", choices = list("Sí" = "Yes", "No" = "No")),
    material_dropdown(
      "multiple", "Multiples lineas",
      choices = set_names(
        list("Yes", "No", "No phone service"),
        c("Sí", "No", "Sin servicio")
      )
    ),
    material_dropdown(
      "gender", "Género",
      choices = set_names(list("Male", "Female"), c("Masculino", "Femenino"))
    ),
    material_dropdown("senior", "Mayor de 65", choices = list("No" = 0, "Sí" = 1)),
    material_dropdown("partner", "Partner", choices = list("Sí" = "Yes", "No" = "No")),
    material_dropdown("dependents", "Dependientes", choices = list("Sí" = "Yes", "No" = "No")),

    material_dropdown("security", "Seguridad en línea",
      choices = list("Sí" = "Yes", "No" = "No", "Sin Internet" = "No internet service"),
      selected = "No internet service"
    ),
    material_dropdown("backup", "Backup en línea",
      choices = list("Sí" = "Yes", "No" = "No", "Sin Internet" = "No internet service"),
      selected = "No internet service"
    ),
    material_dropdown("device", "Protección de dispositivo",
      choices = list("Sí" = "Yes", "No" = "No", "Sin Internet" = "No internet service"),
      selected = "No internet service"
    ),
    material_dropdown("support", "Soporte técnico",
      choices = list("Sí" = "Yes", "No" = "No", "Sin Internet" = "No internet service"),
      selected = "No internet service"
    ),
    material_dropdown("tv", "Televisión en línea",
      choices = list("Sí" = "Yes", "No" = "No", "Sin Internet" = "No internet service"),
      selected = "No internet service"
    ),

    material_dropdown("movies", "Películas en línea",
      choices = list("Sí" = "Yes", "No" = "No", "Sin Internet" = "No internet service"),
      selected = "No internet service"
    )
  ),
  mainPanel(
    material_card(
      title = "Probabilidad de perdida de cliente",
      d3Output("churn", height = 200),
      depth = 5
    )
  )
)

server <- function(input, output, session) {
  output$churn <- renderD3({
    tenure_bins <- c(1, 3, 6, 9, 12, 18, 24, 36, 48, 60)
    selections <- data.frame(
      gender = input$gender,
      SeniorCitizen = as.integer(input$senior),
      Partner = input$partner,
      Dependents = input$dependents,
      tenure = tenure_bins,
      PhoneService = input$phone,
      MultipleLines = input$multiple,
      InternetService = input$internet,
      OnlineSecurity = input$security,
      OnlineBackup = input$backup,
      DeviceProtection = input$device,
      TechSupport = input$support,
      StreamingTV = input$tv,
      StreamingMovies = input$movies,
      Contract = input$contract,
      PaperlessBilling = input$paperless,
      PaymentMethod = input$payment,
      MonthlyCharges = input$monthly,
      TotalCharges = input$total,
      Churn = 0
    )
    baked_selections <- bake(receta, new_data = selections)
    baked_selections$Churn <- NULL
    baked_numeric <- baked_selections %>%
      transpose() %>%
      map(as.numeric)
    body <- list(instances = list(baked_numeric))
    r <- POST("https://colorado.rstudio.com/rsc/content/2230/serving_default/predict", body = body, encode = "json")
    results <- jsonlite::fromJSON(content(r))$predictions[, , 1]
    results <- round(results, digits = 2)
    churn_data <- data.frame(
      y = results,
      x = tenure_bins,
      label = paste0(tenure_bins, "m"),
      value_label = paste0(results * 100, "%")
    )
    r2d3(churn_data, "col_plot.js")
  })

  # observeEvent(input$phone, {
  #   if (input$phone == "No") {
  #     dv <- "No phone service"
  #   } else {
  #     dv <- "No"
  #   }
  #   update_material_dropdown(session, "multiple", value = dv)
  # })
  #
  # observeEvent(input$internet, {
  #   if (input$internet == "No") {
  #     dv <- "No internet service"
  #   } else {
  #     dv <- "No"
  #   }
  #   update_material_dropdown(session, "security", value = dv)
  #   update_material_dropdown(session, "device", value = dv)
  #   update_material_dropdown(session, "backup", value = dv)
  #   update_material_dropdown(session, "support", value = dv)
  #   update_material_dropdown(session, "tv", value = dv)
  #   update_material_dropdown(session, "movies", value = dv)
  # })
}

shinyApp(ui = ui, server = server)
