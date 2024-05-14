package main

import (
	"fmt"

	"github.com/kenyoni-software/godot-addons/publisher/internal"
)

func main() {
	newCli().Execute()
	return
	meta := struct {
		Version     string
		MinGodot    string
		DownloadUrl string
		Description string
	}{
		Version:     "2.0.0",
		MinGodot:    "4.2",
		DownloadUrl: "https://github.com/kenyoni-software/godot-addons/releases/download/hide_private_properties-1.1.2/hide_private_properties-1_1_2.zip",
		Description: "",
	}

	client := internal.NewAssetLibraryClient("http://localhost:8080/asset-library/api")
	fmt.Println(client.Login("iceflower", "iceflowerpass"))
	fmt.Println(client.UpdateAsset(internal.AssetData{
		AssetId:          "1",
		GodotVersion:     meta.MinGodot,
		DownloadProvider: "Custom",
		DownloadCommit:   meta.DownloadUrl,
		VersionString:    meta.Version,
	}))
	fmt.Println(client.Logout())
	modClient := internal.NewAssetLibraryClient("http://localhost:8080/asset-library/api")
	fmt.Println(modClient.Login("mod", "mod"))
	fmt.Println(modClient.MoveToReview("1"))
	fmt.Println(modClient.AcceptReview("1"))
	fmt.Println(client.Logout())
}
