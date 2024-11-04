# Geolocator

Author: Eliyah Watson \
GitHub Repository URL: https://github.com/eliwats20/Geolocator \
Credit: https://github.com/kiritbasu/Fake-Apache-Log-Generator

Description: This project is a comprehensive web application designed to store, receive, and visualize geolocation and additional information associated with IP addresses. It utilizes a Node.js, Express.js, and Windows Powershell backend to use the ip-api API, which contains geolocation details such as the city, state, postal code, country, and more information. The IP address data was generated from Python file in an existing GitHub repository, producing a file with 100 rows of synthetic IP address data. Database management and data handling was implemented through a MariaDB SQL database, which supports data handling. For data visualization. R was used to provide graphs that displayed information on the user interface from the database. The website is designed with an interactive front-end using HTML, CSS, and JavaScript. AJAX requests is used to send requests to the Node.js server to fetch information that will be displayed on the front-end.
//

ZIP File content:
In the ZIP file contains the Python fake IP log generator file, R script for the graph visuals, SQL script for creating the database schema, HTML file for the front-end mark-up content, Windows PowerShell script for data parsing and processing, Node.js application using Express.js as a web framework, Javascript file for front-end logic and handling requests, and CSS file for website styling.

Prerequisites:

1. Install Node.js on your machine
2. Install MariaDB and set up your database.
3. Install R on your machine.

Directions:

1. Clone the GitHub Repository by performing the command `git clone https://github.com/eliwats20/Geolocator.git`.
2. Navigate to the project's directory with `cd Geolocator`.
3. Install Node.js and its dependencies - `npm install`.
4. Change database credentials in the Data Visualization.r and run_app.js
5. (Optional) To generate custom fake IP logs, first run the `pip` command to install Python packages, then create a virtual environment using `python -m venv [name]`
6. Run Node application - `node run_app.js`.
