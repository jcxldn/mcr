package papermc

import (
	"fmt"

	"github.com/buger/jsonparser"
	"github.com/go-resty/resty/v2"

	"github.com/Prouser123/minecraft-runner-docker/dltool/v2/providers/common"
)

var baseUrl = "https://papermc.io/api/v2"

var client *resty.Client = resty.New()

func GetLatestVersion(project string) string {
	//client := resty.New()

	resp, err := client.R().Get(fmt.Sprintf("%s/projects/%s", baseUrl, project))

	if err == nil && resp.StatusCode() == 200 {
		// No errors, HTTP 200 OK, lets continue!

		bytes, arrType, _, err := jsonparser.Get(resp.Body(), "versions")
		// The bytes object is a byte[] containing a JSON array

		if err == nil && arrType == jsonparser.Array {
			// Next, let's get a string of the latest available minecraft version
			var latestVer string

			if str, err := jsonparser.GetString(bytes, fmt.Sprintf("[%d]", common.GetLastItemIndex(bytes))); err == nil {
				latestVer = str
			}

			//len = 0
			return latestVer
		}
	}
	return "unknown"
}

func GetVersionLatestBuild(project string, version string) string {
	//client := resty.New()

	resp, err := client.R().Get(fmt.Sprintf("%s/projects/%s/versions/%s", baseUrl, project, version))
	if err == nil && resp.StatusCode() == 200 {
		// No errors, HTTP 200 OK, lets continue!

		bytes, arrType, _, err := jsonparser.Get(resp.Body(), "builds")
		// The bytes object is a byte[] containing a JSON array

		if err == nil && arrType == jsonparser.Array {
			// Next, let's get a string of the latest available minecraft version
			var latestBuild string

			if val, err := jsonparser.GetInt(bytes, fmt.Sprintf("[%d]", common.GetLastItemIndex(bytes))); err == nil {
				latestBuild = fmt.Sprint(val)
			}

			return latestBuild
		}

	}
	return "unknown"
}

func GetLatestBuildDownloadLinkForVersion(project string, version string) string {
	// 1. Get the latest build number
	latestBuild := GetVersionLatestBuild(project, version)

	resp, err := client.R().Get(fmt.Sprintf("%s/projects/%s/versions/%s/builds/%s", baseUrl, project, version, latestBuild))
	if err == nil && resp.StatusCode() == 200 {
		if val, err := jsonparser.GetString(resp.Body(), "downloads", "application", "name"); err == nil {
			return fmt.Sprintf("%s/projects/%s/versions/%s/builds/%s/downloads/%s", baseUrl, project, version, latestBuild, val)
		}
	}
	return "unknown"
}
