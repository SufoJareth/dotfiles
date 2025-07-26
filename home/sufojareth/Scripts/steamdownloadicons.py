import os
import requests
from bs4 import BeautifulSoup

# Function to get the icon URLs from the Icons tab
def get_game_icons(appid):
    # Construct the SteamGridDB URL for the icons page
    url = f"https://www.steamgriddb.com/game/{appid}/icons"

    response = requests.get(url)

    if response.status_code != 200:
        print(f"Error: Unable to access icons page for App ID {appid}")
        return None

    soup = BeautifulSoup(response.text, 'html.parser')
    
    # Find the icon images (we'll look for <img> tags within the 'grid-item' divs or similar)
    icon_images = soup.find_all('img', class_='grid-item-img')

    if icon_images:
        icon_urls = [img['src'] for img in icon_images if 'src' in img.attrs]
        return icon_urls
    else:
        print(f"No icons found for App ID {appid}")
        return None

# Function to download an image and save it to a specified folder
def download_icon(icon_url, download_folder, appid, index):
    # Get the file extension from the URL
    file_extension = icon_url.split('.')[-1]
    filename = f"{appid}_icon_{index}.{file_extension}"
    filepath = os.path.join(download_folder, filename)

    # Download and save the image
    img_response = requests.get(icon_url)
    if img_response.status_code == 200:
        with open(filepath, 'wb') as file:
            file.write(img_response.content)
        print(f"Downloaded: {filename}")
    else:
        print(f"Failed to download image for App ID {appid}")

# Main function to handle multiple App IDs input and download the icons
def download_icons():
    # Get multiple App IDs from user input
    appids = input("Enter Steam App IDs (separated by spaces): ").split()

    # Ask for the download folder
    download_folder = input("Enter the folder path to download icons (e.g., /home/username/icons): ")
    
    # Create the folder if it doesn't exist
    if not os.path.exists(download_folder):
        os.makedirs(download_folder)
    
    # Loop through each App ID and download the icons
    for appid in appids:
        print(f"Fetching icons for App ID {appid}...")
        icon_urls = get_game_icons(appid)
        if icon_urls:
            # Download each icon
            for index, icon_url in enumerate(icon_urls):
                download_icon(icon_url, download_folder, appid, index)

# Run the script
if __name__ == "__main__":
    download_icons()

