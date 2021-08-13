package cmd

import (
	"fmt"

	"github.com/Prouser123/minecraft-runner-docker/dltool/v2/providers/papermc"
	"github.com/spf13/cobra"
)

// latestmcCmd represents the latestmc command
var latestmcCmd = &cobra.Command{
	Use:   "latestmc [platform]",
	Short: "Display the latest mc version available for a given platform",
	Args:  cobra.ExactArgs(1),
	Run: func(cmd *cobra.Command, args []string) {
		switch args[0] {
		case "paper":
			fmt.Println(papermc.GetLatestVersion("paper"))
		case "waterfall":
			fmt.Println(papermc.GetLatestVersion("waterfall"))
		default:
			fmt.Println("unknown platform")
		}
	},
}

func init() {
	rootCmd.AddCommand(latestmcCmd)

	// TODO: https://github.com/spf13/cobra/issues/395#issuecomment-340496139 ?
}
