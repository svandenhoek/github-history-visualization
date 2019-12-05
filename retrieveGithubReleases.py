#!/user/bin/env python3
"""
Name:	retrieveGithubReleases.py

Usage:
	retrieveGithubReleases.py user/repo branch outFile

Description:
	Retrieve release information for a specific GitHub repository.
	Output is formatted as 1 line per release (date|name), where the date is a UNIX timestamp.
"""

from sys import argv
from requests import get
from requests.exceptions import ConnectionError
from requests.exceptions import ReadTimeout
from requests import HTTPError
from requests.packages.urllib3 import disable_warnings
from requests.packages.urllib3.exceptions import InsecureRequestWarning
from datetime import datetime

def main():
	# Disables InsecureRequestWarning. See also: https://urllib3.readthedocs.org/en/latest/security.html
	disable_warnings(InsecureRequestWarning)

	fileWriter = open(argv[3], 'w')
	retrieveReleasesFromGithub(fileWriter, "https://api.github.com/repos/" + argv[1] + "/releases")
	fileWriter.flush()
	fileWriter.close()

def retrieveReleasesFromGithub(fileWriter, apiUrl):
	# Tries to make a request to the REST API with the JSON String.
	# If an HTTPError is triggered, this is printed and then no further benchmarking data will be uploaded.
	try:
		response = get(apiUrl, verify=False)
		response.raise_for_status()
	except (ConnectionError, HTTPError, ReadTimeout) as e:
		exit(e)

	# Disgests the response and writes it to the output file.
	for release in response.json():
		# Filters releases on defined branch.
		if release["target_commitish"] == argv[2]:
			releaseDate = datetime.strptime(release["published_at"], "%Y-%m-%dT%H:%M:%SZ")
			fileWriter.write(releaseDate.strftime("%s") + "|" + release["name"] + "\n")
	
	# Checks if there is a next page, and does a recursive call if this is true.
	if "next" in response.links:
		retrieveReleasesFromGithub(fileWriter, response.links["next"]["url"])

if __name__ == '__main__':
    main()