package velocity

// Partial struct based on XML maven metadata response
type MavenMetadataPartial struct {
	GroupId    string `xml:"groupId"`
	ArtifactId string `xml:"artifactId"`
	Versioning struct {
		Latest      string `xml:"latest"`
		Release     string `xml:"release"`
		LastUpdated string `xml:"lastUpdated"`
	} `xml:"versioning"`
}
