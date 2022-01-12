package purpur

import (
	"encoding/json"
	"fmt"

	"github.com/buger/jsonparser"
	"github.com/go-resty/resty/v2"
)

var baseUrl = "https://api.pl3x.net/v2/purpur"

var client *resty.Client = resty.New()

type apiResponse struct {
	Versions []string `json:"versions"`
}

func GetLatestVersion() string {
	resp, err := client.R().Get(baseUrl)

	if err == nil && resp.StatusCode() == 200 {
		// No errors, HTTP 200 ok, continue!

		// Parse the response body into an object
		if data, dataType, _, err := jsonparser.Get(resp.Body()); err == nil {
			// Make sure we have an object response
			if dataType != jsonparser.Object {
				return "unknown"
			}

			res := &apiResponse{}

			// Parse the JSON object response into struct res
			if err := json.Unmarshal([]byte(data), res); err != nil {
				// If there's an error during parsing, return unknown
				return "unknown"
			}
			// Parsing succeeded! The last item in the array is the newest version
			// To return the last item in the array, return length-1
			return string(res.Versions[len(res.Versions)-1])
		}
	}

	return "unknown"
}

// Note: unlike with papermc this is not needed to get a download link.
func GetVersionLatestBuild(version string) string {
	resp, err := client.R().Get(fmt.Sprintf("%s/%s/latest", baseUrl, version))

	if err == nil && resp.StatusCode() == 200 {
		// No errors, HTTP 200 ok, continue!

		if string, err := jsonparser.GetString(resp.Body(), "build"); err == nil {
			return string
		}
	}

	return "unknown"
}

func GetLatestBuildDownloadLinkForVersion(version string) string {
	return fmt.Sprintf("%s/%s/latest/download", baseUrl, version)
}
