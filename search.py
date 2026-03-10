import requests

query = "python programming"

url = "https://duckduckgo.com/html/?q=" + query
response = requests.get(url)

print("Search request sent")
print("Status:", response.status_code)