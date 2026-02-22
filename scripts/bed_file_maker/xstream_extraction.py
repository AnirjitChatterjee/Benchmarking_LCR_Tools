import requests
from bs4 import BeautifulSoup

# Replace with the URL of the page you want to scrape
url = 'file:///home/ceglab5/Desktop/xstream/human/XSTREAM__i0.7_g3_m5_e2.0_out_2.html'

# Send a GET request to the website
response = requests.get(url)

# Parse the HTML content using BeautifulSoup
soup = BeautifulSoup(response.text, 'html.parser')

# Define a list to hold the extracted data
uniprot_ids_and_positions = []

# Iterate through relevant tags (e.g., table rows, divs, etc.) to find Uniprot IDs and positions
# This assumes Uniprot IDs and repeat positions are within <tr> or <td> tags. Modify as needed based on the page's structure.
for row in soup.find_all('tr'):  # Adjust to match specific tags or structures
    columns = row.find_all('td')
    if len(columns) >= 2:  # Ensure there are at least 2 columns (one for Uniprot ID, one for position)
        uniprot_id = columns[0].text.strip()  # Extract Uniprot ID
        repeat_position = columns[1].text.strip()  # Extract repeat position
        uniprot_ids_and_positions.append((uniprot_id, repeat_position))

# Print the extracted Uniprot IDs and positions
for uniprot_id, position in uniprot_ids_and_positions:
    print(f"Uniprot ID: {uniprot_id} \t Position: {position}")
