package main

import (
	"errors"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/spf13/cobra"
)

const (
	actionGithub = "github"
	actionZip    = "zip"
)

type cli struct {
	rootCmd *cobra.Command

	Addon   string
	BaseDir string

	GithubAction struct {
		OutputFile string
	}
	ZipAction struct {
		OutputDir string
	}
}

func newCli() *cli {
	c := cli{
		GithubAction: struct{ OutputFile string }{},
		ZipAction:    struct{ OutputDir string }{},
	}

	c.rootCmd = &cobra.Command{
		Use:   "publisher",
		Short: "Kenyoni Godot Addon publishing helper",
	}
	c.rootCmd.PersistentFlags().StringVarP(&c.BaseDir, "baseDir", "b", "./", "Base directory of the project.")
	c.rootCmd.MarkFlagRequired("baseDir")
	c.rootCmd.PersistentFlags().StringVarP(&c.Addon, "addon", "a", "", "Addon to proceed.")
	c.rootCmd.MarkFlagRequired("addon")

	ghCmd := &cobra.Command{
		Use:   "github",
		Short: "Save information about an addon to the given file, to be used with $GITHUB_OUTPUT",
		Run: func(cmd *cobra.Command, args []string) {
			doActionGithub(c.BaseDir, c.Addon, c.GithubAction.OutputFile)
		},
	}
	ghCmd.Flags().StringVarP(&c.GithubAction.OutputFile, "output", "o", "", "Output file to write the result into.")
	ghCmd.MarkFlagRequired("output")

	zipCmd := &cobra.Command{
		Use:   "zip",
		Short: "Zip specified addon release ready.",
		Run: func(cmd *cobra.Command, args []string) {
			doActionZip(c.BaseDir, c.Addon, c.ZipAction.OutputDir)
		},
	}
	zipCmd.Flags().StringVarP(&c.ZipAction.OutputDir, "output", "o", "", "Output directory to place the archive into.")
	zipCmd.MarkFlagRequired("output")

	c.rootCmd.AddCommand(ghCmd, zipCmd)

	return &c
}

func (c *cli) Execute() {
	err := c.rootCmd.Execute()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func doActionGithub(baseDir string, addon string, outputFile string) {
	addonCfg := newAddon(addon, baseDir)
	plg, err := addonCfg.GetPluginCfg()
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

	oFile, err := os.OpenFile(outputFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		log.Fatalln(err)
	}
	defer oFile.Close()
	_, err = oFile.WriteString(outputStr)
	if err != nil {
		log.Fatalln(err)
	}
}

func doActionZip(baseDir string, addon string, outputDir string) {
	addonDir := filepath.Join(baseDir, "addons", addon)
	_, err := os.Stat(addonDir)
	if errors.Is(err, os.ErrNotExist) {
		log.Fatalf("Directory '%s' does not exist", addonDir)
	}
	if err != nil {
		log.Fatalln(err)
	}

	addonCfg := newAddon(addon, baseDir)
	plgCfg, err := addonCfg.GetPluginCfg()
	if err != nil {
		log.Fatalln(err)
	}
	outputFile := filepath.Join(addonCfg.ProjectPath(), "archives", addonCfg.Id()+"-"+strings.ReplaceAll(plgCfg.Plugin.Version, ".", "_")+".zip")
	err = addonCfg.Zip(outputFile)
	if err != nil {
		log.Fatalln(err)
	}
}
