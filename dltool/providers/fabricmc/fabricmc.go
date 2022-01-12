package fabricmc

import (
	"fmt"

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
		// At the time of writing, the latest version string is at (data)[0].version
		// (the first item in the array being the latest version for the module)

		str, dataType, _, err := jsonparser.Get(resp.Body(), "[0]", "version")
		// Make sure a) that there were no errors and b) that we have a string response type
		if err == nil && dataType == jsonparser.String {
			return string(str)
		}
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
