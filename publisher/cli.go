package main

import (
	"errors"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/spf13/cobra"

	"github.com/kenyoni-software/godot-addons/publisher/internal"
)

type assetLibraryActionCfg struct {
	Username string
	Password string
	AssetId  string
	Category string
	Host     string
}

func newCli() *cobra.Command {
	rootCmd := &cobra.Command{}
	var baseDir string

	rootCmd = &cobra.Command{
		Short: "Kenyoni Godot Addon publishing helper",
	}
	rootCmd.PersistentFlags().StringVarP(&baseDir, "baseDir", "b", "./", "Base directory of the project.")

	ghCmd := &cobra.Command{
		Use:   "github [addon id] [output file]",
		Short: "Save information about an Addon to the given file, to be used with $GITHUB_OUTPUT",
		Run: func(cmd *cobra.Command, args []string) {
			doActionGithub(baseDir, args[0], args[1])
		},
		Args: cobra.ExactArgs(2),
	}

	var assetLibrary assetLibraryActionCfg
	gdAssetCmd := &cobra.Command{
		Use:   "asset-library",
		Short: "Publish given Addon to an Asset Library.",
		Run: func(cmd *cobra.Command, args []string) {
			doActionAssetLibrary(baseDir, args[0], assetLibrary)
		},
		Args: cobra.ExactArgs(1),
	}
	gdAssetCmd.Flags().StringVarP(&assetLibrary.AssetId, "asset-id", "", "", "Asset ID.")
	gdAssetCmd.Flags().StringVarP(&assetLibrary.Username, "username", "u", "", "Asset Library username.")
	gdAssetCmd.MarkFlagRequired("username")
	gdAssetCmd.Flags().StringVarP(&assetLibrary.Password, "password", "p", "", "Asset Library password.")
	gdAssetCmd.MarkFlagRequired("password")
	gdAssetCmd.Flags().StringVarP(&assetLibrary.Category, "category", "c", "", "Asset category.")
	gdAssetCmd.MarkFlagRequired("category")
	gdAssetCmd.Flags().StringVarP(&assetLibrary.Host, "host", "h", "https://godotengine.org/asset-library/api", "Asset Library Host URL.")

	zipCmd := &cobra.Command{
		Use:   "zip [addon id] [output directory]",
		Short: "Zip specified Addon release ready.",
		Run: func(cmd *cobra.Command, args []string) {
			doActionZip(baseDir, args[0], args[1])
		},
	}

	rootCmd.AddCommand(ghCmd, gdAssetCmd, zipCmd)

	return rootCmd
}

func doActionGithub(baseDir string, addonId string, outputFile string) {
	addon := internal.NewAddon(addonId, baseDir)
	plg, err := addon.GetPluginCfg()
	if err != nil {
		log.Fatalln(err)
	}
	outputStr := fmt.Sprintf("version=%s\n", plg.Plugin.Version)
	descStr := ""
	if plg.Plugin.Name != "" {
		descStr += plg.Plugin.Name + " - " + plg.Plugin.Version + "\n"
	}
	if plg.Plugin.Description != "" {
		descStr += plg.Plugin.Description + "\n"
	}
	if plg.Plugin.Dependencies.Godot != "" {
		descStr += "Godot Compatibility: " + plg.Plugin.Dependencies.Godot + "\n"
	}
	changelog, err := internal.GetChangelog(addon, plg.Plugin.Version)
	if err != nil {
		log.Fatalln(err)
	}
	if changelog != "" {
		descStr += "\n## Changelog:\n\n" + changelog + "\n"
	}
	outputStr += fmt.Sprintf("notes<<%s\n%s%s\n", io.EOF, descStr, io.EOF)

	oFile, err := os.OpenFile(outputFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0o644)
	if err != nil {
		log.Fatalln(err)
	}
	defer oFile.Close()
	_, err = oFile.WriteString(outputStr)
	if err != nil {
		log.Fatalln(err)
	}
}

var rxMinVersion = regexp.MustCompile("(?:>=)?(.+)")

func doActionAssetLibrary(baseDir string, addonId string, cfg assetLibraryActionCfg) {
	addonDir := filepath.Join(baseDir, "addons", addonId)
	_, err := os.Stat(addonDir)
	if errors.Is(err, os.ErrNotExist) {
		log.Fatalf("Directory '%s' does not exist", addonDir)
	}
	if err != nil {
		log.Fatalln(err)
	}

	addon := internal.NewAddon(addonId, baseDir)
	plgCfg, err := addon.GetPluginCfg()
	if err != nil {
		log.Fatalln(err)
	}

	alClient := internal.NewAssetLibraryClient(cfg.Host)
	err = alClient.Login(cfg.Username, cfg.Password)
	if err != nil {
		log.Fatalf("Asset Library login failed: %v\n", err)
	}
	defer func(alClient *internal.AssetLibraryClient) {
		err := alClient.Logout()
		if err != nil {
			log.Fatalf("logout failed: %v\n", err)
		}
	}(alClient)

	gdMinversionMatch := rxMinVersion.FindStringSubmatch(plgCfg.Plugin.Dependencies.Godot)
	var gdMinversion string
	if gdMinversionMatch != nil {
		gdMinversion = gdMinversionMatch[1]
	} else {
		log.Fatalln("could not retrieve Godot minimum version")
	}
	assetData := internal.AssetData{
		AssetId:          cfg.AssetId,
		Title:            plgCfg.Plugin.Name,
		Description:      fmt.Sprintf("%s\n\n%s", plgCfg.Plugin.Description, fmt.Sprintf("More detailed information and documentation is available at https://kenyoni-software.github.io/godot-addons/addons/%s", addon.IDName())),
		VersionString:    plgCfg.Plugin.Version,
		GodotVersion:     gdMinversion,
		CategoryId:       cfg.Category,
		License:          "MIT",
		DownloadProvider: "Custom",
		DownloadCommit:   fmt.Sprintf("https://github.com/kenyoni-software/godot-addons/releases/download/%s-%s/%s-%s.zip", addonId, plgCfg.Plugin.Version, addonId, strings.ReplaceAll(plgCfg.Plugin.Version, ".", "_")),
		BrowseUrl:        "https://github.com/kenyoni-software/godot-addons",
		IssuesUrl:        "https://github.com/kenyoni-software/godot-addons/issues",
		IconUrl:          "https://godotengine.org/assets/press/icon_color.png",
	}
	if cfg.AssetId == "" {
		err = alClient.CreateAsset(assetData)
	} else {
		err = alClient.UpdateAsset(assetData)
	}
	if err != nil {
		log.Fatalf("asset update failed: %v\n", err)
	}
}

func doActionZip(baseDir string, addonId string, outputDir string) {
	addonDir := filepath.Join(baseDir, "addons", addonId)
	_, err := os.Stat(addonDir)
	if errors.Is(err, os.ErrNotExist) {
		log.Fatalf("Directory '%s' does not exist", addonDir)
	}
	if err != nil {
		log.Fatalln(err)
	}

	addon := internal.NewAddon(addonId, baseDir)
	plgCfg, err := addon.GetPluginCfg()
	if err != nil {
		log.Fatalln(err)
	}
	if outputDir == "" {
		outputDir = filepath.Join(addon.ProjectPath(), "archives")
	}
	outputFile := filepath.Join(outputDir, addon.IDName()+"-"+strings.ReplaceAll(plgCfg.Plugin.Version, ".", "_")+".zip")
	err = addon.Zip(outputFile)
	if err != nil {
		log.Fatalln(err)
	}
}
