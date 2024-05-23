package cmd

import (
	"fmt"

	"net/url"

	"github.com/Prouser123/minecraft-runner-docker/dltool/v2/providers/fabricmc"
	"github.com/Prouser123/minecraft-runner-docker/dltool/v2/providers/papermc"
	"github.com/Prouser123/minecraft-runner-docker/dltool/v2/providers/purpur"
	"github.com/Prouser123/minecraft-runner-docker/dltool/v2/providers/velocity"
	"github.com/spf13/cobra"
)

var downloadCmd = &cobra.Command{
	Use:   "download [platform] [version]",
	Short: "Download the latest build for a given platform and version",
	Args:  cobra.ExactArgs(2),
	Run: func(cmd *cobra.Command, args []string) {
		switch args[0] {
		case "paper":
			fmt.Println(papermc.GetLatestBuildDownloadLinkForVersion("paper", args[1]))
		case "waterfall":
			fmt.Println(papermc.GetLatestBuildDownloadLinkForVersion("waterfall", args[1]))
		case "purpur":
			fmt.Println(purpur.GetLatestBuildDownloadLinkForVersion(args[1]))
		case "velocity": // no work
			fmt.Println(papermc.GetLatestBuildDownloadLinkForVersion("velocity", args[1]))
		case "geyser": // no work
			// Only one line needed so not in it's own package
			fmt.Printf("https://download.geysermc.org/v2/projects/geyser/versions/%s/builds/latest/downloads/standalone\n", url.PathEscape(args[1]))
		case "fabric":
			fmt.Println(fabricmc.ConstructDownloadUrl(args[1]))
		default:
			fmt.Println("unknown platform")
		}
	},
}

func init() {
	rootCmd.AddCommand(downloadCmd)

	// TODO: https://github.com/spf13/cobra/issues/395#issuecomment-340496139 ?
}
