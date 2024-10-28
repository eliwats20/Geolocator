# Suppress package loading messages
suppressPackageStartupMessages({
  library(DBI)
  library(RMariaDB)
  library(ggplot2)
  library(dplyr)
  library(tidyr) # Load tidyr for replace_na
  library(lubridate)
})

# Connect to the database
con <- dbConnect(RMariaDB::MariaDB(),
  dbname = "ip address",
  host = "127.0.0.1",
  user = "root",
  password = "Eliyah21!!"
)

# Fetch data for requests by date
data_date <- dbGetQuery(con, "SELECT query_date, COUNT(*) as Requests FROM log_query GROUP BY query_date")

# Convert query_date to Date type
data_date$query_date <- as.Date(data_date$query_date, format = "%m/%d/%Y")

# Create month name variable for the title
month_name <- unique(format(data_date$query_date, "%B")) # Get the month name from query_date
title_text <- paste("Requests by Country in", month_name)

# Fetch data for requests by country
data_country <- dbGetQuery(con, "SELECT country, COUNT(*) as Requests FROM log_query GROUP BY country")

# Convert Requests to numeric if it's of type integer64
data_country$Requests <- as.numeric(data_country$Requests)

# Drop data from unidentified countries
data_country <- data_country %>%
  filter(country != "N/A")

# Replace NAs in Requests with 0
data_country <- data_country %>%
  tidyr::replace_na(list(Requests = 0))

# Generate distinct colors for countries
num_countries <- nrow(data_country)
colors_country <- rainbow(num_countries) # Generate distinct colors

# Plot requests by country
plot_country <- ggplot(data_country, aes(x = country, y = Requests, fill = country)) +
  geom_bar(stat = "identity") +
  theme(
    plot.background = element_rect(fill = "white"), # Set plot background to white
    panel.background = element_rect(fill = "white"), # Set panel background to white
    panel.grid.major = element_line(color = "gray"), # Set grid color
    axis.text = element_text(color = "black", angle = 90, hjust = 1, size = 20), # Axis text color
    axis.title = element_text(color = "black", size = 50, face = "bold"),
    plot.title = element_text(color = "black", size = 50, hjust = 0.5, face = "bold")
  ) +
  labs(title = title_text, x = "Country", y = "Number of Requests") +
  scale_fill_manual(values = colors_country) # Apply distinct colors

# Save the plot to a file with a white background
ggsave("requests_by_country.png", plot = plot_country, bg = "white", width = 20, height = 12)



## PLOT REQUESTS BY DAY OF THE MONTH (LINE GRAPH)

# Fetch data for requests by date (again, as needed for this plot)
data_date <- dbGetQuery(con, "SELECT query_date, COUNT(*) as Requests FROM log_query GROUP BY query_date")
title_text <- paste("Requests by Day of Month in", month_name)


# Convert query_date to Date type
data_date$query_date <- as.Date(data_date$query_date, format = "%m/%d/%Y")

# Create month and day variables
data_date$month <- format(data_date$query_date, "%B")
data_date$day <- as.factor(format(data_date$query_date, "%d")) # Convert day to factor

# Generate distinct colors for days (optional for line graph)
num_days <- length(unique(data_date$day))
colors_date <- rainbow(num_days)

# Plot requests by day as a line graph
plot_date <- ggplot(data_date, aes(x = day, y = Requests, group = 1)) + # Group = 1 to connect the line
  geom_line(color = "blue", size = 1) + # Line graph
  geom_point(color = "red", size = 3) + # Optional: Add points at each day for clarity
  theme(
    plot.background = element_rect(fill = "white"),
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(color = "gray"),
    axis.text = element_text(color = "black", size = 30, hjust = 1), # Rotate x-axis text for clarity
    axis.title = element_text(color = "black", size = 60, face = "bold"),
    plot.title = element_text(color = "black", size = 60, hjust = 0.5, face = "bold")
  ) +
  labs(title = title_text, x = "Day of the Month", y = "Number of Requests") +
  scale_x_discrete(breaks = unique(data_date$day)) # Ensure each day appears as a separate tick

# Save the plot to a file
ggsave("requests_by_day_of_month_line.png", plot = plot_date, bg = "black", width = 35, height = 25)

# Fetch data for requests by date and time
data_time <- dbGetQuery(con, "SELECT query_date, query_time FROM log_query")

# Convert query_date to Date type
data_time$query_date <- as.Date(data_time$query_date, format = "%m/%d/%Y")

# Extract start and end dates for the title
start_date <- min(data_time$query_date)
end_date <- max(data_time$query_date)

# Format the dates into a string for the title
date_range_title <- paste("Requests by Time of Day from", format(start_date, "%B %d"), "to", format(end_date, "%B %d"))

# Convert query_time to POSIXct
data_time$query_time <- as.POSIXct(data_time$query_time, format = "%H:%M:%S")

# Extract the hour from query_time
data_time$hour <- hour(data_time$query_time)

# Create time categories
data_time$time_category <- cut(data_time$hour,
  breaks = seq(0, 24, by = 4), # Adjust the intervals to 4
  right = FALSE,
  labels = c(
    "0-4" = "Midnight to Early Morning",
    "4-8" = "Early Morning",
    "8-12" = "Late Morning",
    "12-16" = "Afternoon",
    "16-20" = "Evening",
    "20-24" = "Night"
  )
)

# Count the requests by hour category
requests_by_time <- data_time %>%
  group_by(time_category) %>%
  summarise(Requests = n(), .groups = "drop") # Drop the grouping after summarization

# Plot requests by time of day
plot_time <- ggplot(requests_by_time, aes(x = time_category, y = Requests, fill = time_category)) +
  geom_bar(stat = "identity") +
  theme(
    plot.background = element_rect(fill = "white"),
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(color = "gray"),
    axis.text = element_text(color = "black", size = 15),
    axis.title = element_text(color = "black", size = 15, face = "bold"),
    plot.title = element_text(color = "black", size = 30, hjust = 0.5, face = "bold")
  ) +
  labs(title = date_range_title, x = "Time of Day", y = "Number of Requests") +
  scale_x_discrete(breaks = unique(requests_by_time$time_category)) # Ensure each time category appears as a separate tick

# Save the plot to a file
ggsave("requests_by_hour.png", plot = plot_time, bg = "black", width = 15, height = 15)

# Disconnect from the database
dbDisconnect(con)
