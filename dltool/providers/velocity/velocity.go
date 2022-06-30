package velocity

import (
	"fmt"

	"github.com/go-resty/resty/v2"
)

var client *resty.Client = resty.New()

func GetLatestVersion() string {
	resp, err := client.R().SetResult(&MavenMetadataPartial{}).Get("https://nexus.velocitypowered.com/repository/maven-public/com/velocitypowered/velocity-native/maven-metadata.xml")

	if err == nil && resp.StatusCode() == 200 {
		// No errors, HTTP 200 ok, continue!

		return resp.Result().(*MavenMetadataPartial).Versioning.Release
	}

	return "unknown"

}

// GetVersionLatestBuild not needed here, only one build per stable version

// Velocity-Native is just part of the source, so fall back to official download domain (closed-source, no other known endpoints) for the complete jar
func GetLatestDownloadLinkForVersion(version string) string {
	return fmt.Sprintf("https://versions.velocitypowered.com/download/%s.jar", version)
}
