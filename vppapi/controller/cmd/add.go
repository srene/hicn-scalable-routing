package cmd


var addCmd = &cobra.Command{
  Use:   "add",
  Short: "add route",
  Long: `add a route towards internal router`,
  Run: func(cmd *cobra.Command, args []string) {
    // Do Stuff Here
    fmt.Println("here")
  },
}

func Execute() {
  if err := rootCmd.Execute(); err != nil {
    fmt.Fprintln(os.Stderr, err)
    os.Exit(1)
  }
}
