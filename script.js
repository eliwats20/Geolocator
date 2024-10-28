async function gotoData() {
    const responseMessage = document.getElementById("responseMessage");
    responseMessage.innerText = "Processing data...";

    const graphsDiv = document.getElementById("graphs");
    console.log("Graphs Div:", graphsDiv);

    // Ensure graphsDiv is not null
    if (!graphsDiv) {
        console.error("Graphs element not found!");
        return;
    }

    // Hide graphs section initially
    graphsDiv.style.display = "none";

    try {
        console.log("Sending data to server...");
        const response = await fetch('http://127.0.0.1:5500/insertData', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ data: [] }), // Adjust the body as needed
        });

        console.log("Received response:", response);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json(); // Parse response JSON
        console.log('Response from server:', data);

        // Update response message based on server response
        responseMessage.innerText = data.message || "Data processed successfully.";

        // Hide the submit button after data submission
        document.getElementById("submitData").style.display = 'none'; // Hide button

        // Show the graphs section
        graphsDiv.style.display = "flex";
        graphsDiv.style.alignContent = "center";

        // Call fetchGraphs to update the display of graph images
        await fetchGraphs();

        // After fetching graphs, show the delete data button
        const deleteButton = document.querySelector('.delete-data');
        console.log("Delete Button:", deleteButton); // Log the button

        if (deleteButton) {
            deleteButton.style.display = 'block'; // Show the delete button
        } else {
            console.error("Delete button not found!");
        }

    } catch (error) {
        console.error('Error during fetch:', error);
        responseMessage.innerText = "Error processing data. Please try again.";
    }
}



// Function to fetch and display graph images
async function fetchGraphs() {
    console.log("fetchGraphs function called"); // Add this line
    const graphsDiv = document.getElementById("graphs");
    graphsDiv.innerHTML = ''; // Clear existing content

    // Use relative paths for graph images
    const graphPaths = [
        "./requests_by_country.png",
        "./requests_by_day_of_month_line.png",
        "./requests_by_hour.png"
    ];

    graphPaths.forEach(path => {
        const img = document.createElement("img");
        img.src = path; // Use relative path directly
        img.alt = "Graph Image";
        graphsDiv.appendChild(img);
    });
    console.log("Graphs fetched and added to the DOM"); // Add this line
}

async function deleteData() {
    const responseMessage = document.getElementById("responseMessage");
    responseMessage.innerText = "Processing data...";

    // Ensure that the graphs section is initially hidden
    const graphsDiv = document.getElementById("graphs");
    graphsDiv.style.display = "none"; // Hide graphs section initially

    try {
        // Send a POST request to insert data
        console.log("Sending data to server...");
        const response = await fetch('http://127.0.0.1:5500/deleteData', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ data: [] }), // Send data as needed
        });

        console.log("Received response:", response);
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json(); // Parse response JSON
        console.log('Response from server:', data);

        // Update response message based on server response
        if (data.message) {
            responseMessage.innerText = data.message; // Use server's response message
        } else {
            responseMessage.innerText = "";
        }

        document.getElementById("submitData").style.display = 'none'; // Hide button

        // Show the graphs section
        graphsDiv.style.display = "flex";
        graphsDiv.style.alignContent = "center"

        // Call fetchGraphs to update the display of graph images
        await fetchGraphs(); // Ensure fetchGraphs is awaited

        // Show the delete data button
        document.getElementById('deleteDataButton').style.display = 'block';

    } catch (error) {
        console.error('Error during fetch:', error);
        responseMessage.innerText = "Error processing data. Please try again.";
    }
}

