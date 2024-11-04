# Suppress package loading messages
suppressPackageStartupMessages({
  library(RMariaDB) # Interact with MariaDB database in R
  library(ggplot2) # Create decorative graphics for data
  library(dplyr) # Manipulate data
  library(tidyr) # Tidy data easily
  library(lubridate) # Evaluate times and dates
})

# Display more rows in the console
# options(max.print = 1000) # Adjust as needed to display more rows

# Connect to the database
con <- dbConnect(RMariaDB::MariaDB(),
  dbname = "ip address",
  host = "127.0.0.1",
  user = "root",
  password = "Eliyah21!!"
)

# Fetch data for requests by date
data_date <- dbGetQuery(con, "SELECT query_date, COUNT(*) as Requests FROM log_query GROUP BY query_date")
# print("Requests by Date:")
# print(data_date) # Print the entire data frame

# From query_date to actual Date type
data_date$query_date <- as.Date(data_date$query_date, format = "%m/%d/%Y")

# # Count total requests by date
# total_requests_date <- sum(data_date$Requests)
# print(paste("Total Requests by Date:", total_requests_date))

# Fetch data for requests by country
data_country <- dbGetQuery(con, "SELECT country, COUNT(*) as Requests FROM log_query GROUP BY country")
# print("Requests by Country:")
# print(data_country) # Print the entire data frame

# Convert Requests to numeric in case it's of type integer64
data_country$Requests <- as.numeric(data_country$Requests)

# Drop data from null country names
data_country <- data_country %>% filter(country != "N/A")

# # Count total requests by country
# total_requests_country <- sum(data_country$Requests)
# print(paste("Total Requests by Country:", total_requests_country))

# Generate distinct colors for countries
num_countries <- nrow(data_country)
colors_country <- rainbow(num_countries)

# Plot requests by country
plot_country <- ggplot(data_country, aes(x = country, y = Requests, fill = country)) +
  geom_bar(stat = "identity") +
  theme(
    plot.background = element_rect(fill = "white"),
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(color = "gray"),
    axis.text.x = element_text(color = "black", angle = 45, hjust = 1, vjust = 1, size = 40),
    axis.text = element_text(color = "black", hjust = 1, size = 40),
    axis.title = element_text(color = "black", size = 80, face = "bold"),
    plot.title = element_text(color = "black", size = 120, hjust = 0.5, face = "bold")
  ) +
  # Modify labels and titls of graph componenets
  labs(title = paste("Requests by Country in", (format(data_date$query_date, "%B"))), x = "Country", y = "Number of Requests") +
  scale_fill_manual(values = colors_country)

# Save the plot to a file
ggsave("requests_by_country.png", plot = plot_country, bg = "white", limitsize = FALSE, width = 50, height = 40)

# ---------------------------------------------------------------------------------------------------------------------------------------------------

# Create day variable for requests by date
data_date$day <- as.factor(format(data_date$query_date, "%d"))

# # Print the total requests for each day of the month
# total_requests_day_month <- sum(data_date$Requests)
# print(paste("Total Requests by Day of Month:", total_requests_day_month))

# Plot requests by day of the month as a line graph
plot_date <- ggplot(data_date, aes(x = day, y = Requests, group = 1)) +
  geom_line(color = "blue", linewidth = 3) +
  geom_point(color = "red", size = 3) +
  theme(
    plot.background = element_rect(fill = "white"),
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(color = "gray"),
    axis.text = element_text(color = "black", size = 30, hjust = 1),
    axis.title = element_text(color = "black", size = 60, face = "bold"),
    plot.title = element_text(color = "black", size = 60, hjust = 0.5, face = "bold")
  ) +
  labs(title = paste("Requests by Day of Month in", unique(format(data_date$query_date, "%B"))), x = "Day of the Month", y = "Number of Requests") +
  scale_x_discrete(breaks = unique(data_date$day))

# Save the plot to a file
ggsave("requests_by_day_of_month_line.png", plot = plot_date, bg = "black", width = 35, height = 25)

# ---------------------------------------------------------------------------------------------------------------------------------------------------

# Fetch data for requests by date and time
data_time <- dbGetQuery(con, "SELECT query_date, query_time FROM log_query")
# print("Requests by Time of Day:")
# print(data_time) # Print the entire data frame

# Convert query_date to Date type
data_time$query_date <- as.Date(data_time$query_date, format = "%m/%d/%Y")

# # Count total requests by time of day
# total_requests_time <- nrow(data_time)
# print(paste("Total Requests by Time of Day:", total_requests_time))

# Extract the min and max dates directly from the dataset
start_date <- min(data_time$query_date)
end_date <- max(data_time$query_date)

# Convert query_time to POSIXct and extract the hour
data_time$query_time <- as.POSIXct(data_time$query_time, format = "%H:%M:%S")
data_time$hour <- hour(data_time$query_time)

# Create time categories
data_time$time_category <- cut(data_time$hour,
  breaks = seq(0, 24, by = 4),
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
  summarise(Requests = n(), .groups = "drop")

# # Print the requests by time category
# print("Requests by Time Category:")
# print(requests_by_time) # Print the entire data frame

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
  labs(title = paste("Requests by Time of Day from", format(start_date, "%B %d"), "to", format(end_date, "%B %d")), x = "Time of Day", y = "Number of Requests") +
  scale_x_discrete(breaks = unique(requests_by_time$time_category))

# Save the plot to a file
ggsave("requests_by_time_of_day.png", plot = plot_time, bg = "black", width = 15, height = 15)

# Count the requests by day of week
data_date$day_of_week <- factor(wday(data_date$query_date, label = TRUE, abbr = FALSE, week_start = 1))
requests_by_day_of_week <- data_date %>%
  group_by(day_of_week) %>%
  summarise(Requests = sum(Requests), .groups = "drop")

# # Print the requests by day of the week
# print("Requests by Day of Week:")
# print(requests_by_day_of_week) # Print the entire data frame

# # Count total requests by day of week
# total_requests_day_week <- sum(requests_by_day_of_week$Requests)
# print(paste("Total Requests by Day of Week:", total_requests_day_week))

# Plot requests by day of the week
plot_day_of_week <- ggplot(requests_by_day_of_week, aes(x = day_of_week, y = Requests, fill = day_of_week)) +
  geom_bar(stat = "identity") +
  theme(
    plot.background = element_rect(fill = "white"),
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(color = "gray"),
    axis.text = element_text(color = "black", size = 15),
    axis.title = element_text(color = "black", size = 15, face = "bold"),
    plot.title = element_text(color = "black", size = 30, hjust = 0.5, face = "bold")
  ) +
  labs(title = paste("Requests by Day of Week from", format(start_date, "%B %d"), "to", format(end_date, "%B %d")), x = "Day of Week", y = "Number of Requests")

# Save the plot to a file
ggsave("requests_by_day_of_week.png", plot = plot_day_of_week, bg = "black", width = 15, height = 15)

# Disconnect from the database
dbDisconnect(con)
