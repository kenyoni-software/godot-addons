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

const (
	actionGithub = "github"
	actionZip    = "zip"
)

type githubActionCfg struct {
	OutputFile string
}

type zipActionCfg struct {
	OutputDir string
}

type assetLibraryActionCfg struct {
	Username string
	Password string
	AssetId  string
	Category string
	Host     string
}

type cli struct {
	rootCmd *cobra.Command

	Addon   string
	BaseDir string

	GithubAction githubActionCfg
	ZipAction    zipActionCfg
	AssetLibrary assetLibraryActionCfg
}

func newCli() *cli {
	c := cli{
		GithubAction: githubActionCfg{},
		AssetLibrary: assetLibraryActionCfg{},
		ZipAction:    zipActionCfg{},
	}

	c.rootCmd = &cobra.Command{
		Short: "Kenyoni Godot Addon publishing helper",
	}
	c.rootCmd.PersistentFlags().StringVarP(&c.BaseDir, "baseDir", "b", "./", "Base directory of the project.")
	c.rootCmd.MarkFlagRequired("baseDir")
	c.rootCmd.PersistentFlags().StringVarP(&c.Addon, "Addon", "a", "", "Addon to proceed.")
	c.rootCmd.MarkFlagRequired("Addon")

	ghCmd := &cobra.Command{
		Use:   "github",
		Short: "Save information about an Addon to the given file, to be used with $GITHUB_OUTPUT",
		Run: func(cmd *cobra.Command, args []string) {
			doActionGithub(c.BaseDir, c.Addon, c.GithubAction)
		},
	}
	ghCmd.Flags().StringVarP(&c.GithubAction.OutputFile, "output", "o", "", "Output file to write the result into.")
	ghCmd.MarkFlagRequired("output")

	gdAssetCmd := &cobra.Command{
		Use:   "asset-library",
		Short: "Publish given Addon to an Asset Library.",
		Run: func(cmd *cobra.Command, args []string) {
			doActionAssetLibrary(c.BaseDir, c.Addon, c.AssetLibrary)
		},
	}
	gdAssetCmd.Flags().StringVarP(&c.AssetLibrary.AssetId, "asset-id", "", "", "Asset ID.")
	gdAssetCmd.Flags().StringVarP(&c.AssetLibrary.Username, "username", "u", "", "Asset Library username.")
	gdAssetCmd.MarkFlagRequired("username")
	gdAssetCmd.Flags().StringVarP(&c.AssetLibrary.Password, "password", "p", "", "Asset Library password.")
	gdAssetCmd.MarkFlagRequired("password")
	gdAssetCmd.Flags().StringVarP(&c.AssetLibrary.Category, "category", "c", "", "Asset category.")
	gdAssetCmd.MarkFlagRequired("category")
	gdAssetCmd.Flags().StringVarP(&c.AssetLibrary.Host, "host", "host", "https://godotengine.org/asset-library/api", "Asset Library Host URL.")

	zipCmd := &cobra.Command{
		Use:   "zip",
		Short: "Zip specified Addon release ready.",
		Run: func(cmd *cobra.Command, args []string) {
			doActionZip(c.BaseDir, c.Addon, c.ZipAction)
		},
	}
	zipCmd.Flags().StringVarP(&c.ZipAction.OutputDir, "output", "o", "", "Output directory to place the archive into.")
	zipCmd.MarkFlagRequired("output")

	c.rootCmd.AddCommand(ghCmd, gdAssetCmd, zipCmd)

	return &c
}

func (c *cli) Execute() {
	err := c.rootCmd.Execute()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func doActionGithub(baseDir string, addonId string, cfg githubActionCfg) {
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
	outputStr += fmt.Sprintf("notes<<%s\n%s%s\n", io.EOF, descStr, io.EOF)

	oFile, err := os.OpenFile(cfg.OutputFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
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
		Description:      fmt.Sprintf("%s\n\n%s", plgCfg.Plugin.Description, fmt.Sprintf("More detailed information and documentation is available at https://kenyoni-software.github.io/godot-addons/addons/%s", addon.Id())),
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

func doActionZip(baseDir string, addonId string, cfg zipActionCfg) {
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
	outputDir := cfg.OutputDir
	if outputDir == "" {
		outputDir = filepath.Join(addon.ProjectPath(), "archives")
	}
	outputFile := filepath.Join(outputDir, addon.Id()+"-"+strings.ReplaceAll(plgCfg.Plugin.Version, ".", "_")+".zip")
	err = addon.Zip(outputFile)
	if err != nil {
		log.Fatalln(err)
	}
}
