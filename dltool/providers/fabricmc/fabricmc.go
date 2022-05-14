package fabricmc

import (
	"fmt"
	"strconv"

	"github.com/buger/jsonparser"
	"github.com/go-resty/resty/v2"
)

var baseUrl = "https://meta.fabricmc.net/v2/versions"

var client *resty.Client = resty.New()

func getVersion(m Module) string {
	// Make a API request for the given module
	resp, err := client.R().Get(fmt.Sprintf("%s/%s", baseUrl, m))
	if err == nil && resp.StatusCode() == 200 {
		// HTTP 200 OK!

		// This API returns an array of objects
		// At the time of writing, the version string is at (data)[i].version
		// UPDATE: The API now returns snapshot versions, so we can no longer just return the first item in the array.

		var version string
		var stillSearching bool = true

		// Let's iterate through each item until we come across one with stable: true
		jsonparser.ArrayEach(resp.Body(), func(value []byte, _ jsonparser.ValueType, offset int, _ error) {
			if stillSearching {
				stableByte, dataType, _, err := jsonparser.Get(value, "stable")
				if err == nil && dataType == jsonparser.Boolean {
					stable, _ := strconv.ParseBool(string(stableByte))
					if stable {
						// We have a stable release! Get the version value andd return it.
						str, dataType, _, err := jsonparser.Get(value, "version")
						// Make sure a) that there were no errors and b) that we have a string response type
						if err == nil && dataType == jsonparser.String {
							// Set the version string
							version = string(str)
							// Set stillSearching to false to prevent another stable version from overwriting this one
							// ('game' has multiple stable versions)
							stillSearching = false
						}
					}
				}
			}
		})
		return version
	}

	// Fallback return
	return "unknown"
}

func GetLatestVersion() string {
	return fmt.Sprintf("%s/%s/%s", getVersion(Game), getVersion(Loader), getVersion(Installer))
}

func ConstructDownloadUrl(vers string) string {
	return fmt.Sprintf("%s/loader/%s/server/jar", baseUrl, vers)
}
