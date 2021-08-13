package cmd

import (
	"fmt"

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
		case "velocity":
			fmt.Println(velocity.GetLatestDownloadLinkForVersion(args[1]))
		default:
			fmt.Println("unknown platform")
		}
	},
}

func init() {
	rootCmd.AddCommand(downloadCmd)

	// TODO: https://github.com/spf13/cobra/issues/395#issuecomment-340496139 ?
}
