async function gotoData() {
    const responseMessage = document.getElementById("responseMessage");
    responseMessage.innerText = "Processing data...";

    const graphsDiv = document.getElementById("graphs");


    // Hide graphs section
    graphsDiv.style.display = "none";

    try {
        const response = await fetch('http://127.0.0.1:5500/insertData', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
        });
        
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
    const graphsDiv = document.getElementById("graphs");
    graphsDiv.innerHTML = ''; // Clear existing content

    const timestamp = new Date().getTime(); // Current timestamp in milliseconds


    // Use relative paths for graph images
    const graphPaths = [
        `./requests_by_country.png?timestamp=${timestamp}`,
        `./requests_by_day_of_month_line.png?timestamp=${timestamp}`,
        `./requests_by_day_of_week.png?timestamp=${timestamp}`,
        `./requests_by_time_of_day.png?timestamp=${timestamp}`
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
    const deleteButton = document.querySelector(".delete-data");
    deleteButton.style.display = "none";

    // Ensure that the graphs section is initially hidden
    const graphsDiv = document.getElementById("graphs");
    graphsDiv.style.display = "none"; // Hide graphs section initially

    

    try {
        // Sending a DELETE request to delete data
        console.log("Sending delete request to server...");
        const response = await fetch('http://127.0.0.1:5500/deleteData', {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
            },
        });

        console.log("Received response:", response);

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json(); // Parse response JSON
        console.log('Response from server:', data);

        // Update response message based on server response
        responseMessage.innerText = data.message || "Data deleted successfully.";

        // Hide the "Get Data" button after deletion
        document.getElementById("submitData").style.display = "block";


        // Show the delete data button if applicable
        const deleteButton = document.getElementById('deleteDataButton');
        if (deleteButton) {
            deleteButton.style.display = 'block'; // Show button only if it exists
        }

    } catch (error) {
        console.error('Error during fetch:', error);
        responseMessage.innerText = "Error processing data. Please try again.";
    }
}
