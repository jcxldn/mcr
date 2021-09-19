package purpur

import (
	"fmt"

	"github.com/buger/jsonparser"
	"github.com/go-resty/resty/v2"
)

var baseUrl = "https://api.pl3x.net/v2/purpur"

var client *resty.Client = resty.New()

func GetLatestVersion() string {
	resp, err := client.R().Get(baseUrl)

	if err == nil && resp.StatusCode() == 200 {
		// No errors, HTTP 200 ok, continue!

		if string, err := jsonparser.GetString(resp.Body(), "versions", "[0]"); err == nil {
			return string
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
