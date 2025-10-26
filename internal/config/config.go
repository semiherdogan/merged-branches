package config

// AppInfo holds application metadata
type AppInfo struct {
	Name     string
	Version  string
	Platform string
}

// These variables are set during build time using ldflags
var (
	// Version is the application version (set during build)
	Version = "dev"
	// Platform is the target platform (set during build)
	Platform = "unknown"
)

// GetAppInfo returns the application information
func GetAppInfo() AppInfo {
	return AppInfo{
		Name:     "merged-branches",
		Version:  Version,
		Platform: Platform,
	}
}
