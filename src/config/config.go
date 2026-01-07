package config

import (
	"os"
	"gopkg.in/yaml.v3"
)

type Config struct {
	Server struct {
		Port int `yaml:"port"`
		Session struct {
			Name string `yaml:"name"`
			Path string `yaml:"path"`
			Cookie struct {
				HttpOnly bool `yaml:"httpOnly"`
				Secure   bool `yaml:"secure"`
			} `yaml:"cookie"`
		} `yaml:"session"`
	} `yaml:"server"`
	DB struct {
		Host     string `yaml:"host"`
		Port     int    `yaml:"port"`
		User     string `yaml:"user"`
		Password string `yaml:"password"`
		Database string `yaml:"database"`
	} `yaml:"db"`
}

func LoadConfig(cfg *Config) error {
	var configfile string
	if os.Getenv("CONFIG_FILE") != "" {
        configfile = os.Getenv("CONFIG_FILE")
    } else {
        configfile = "config.yaml"
    }
	data, err := os.ReadFile(configfile)
	if err != nil {
		return err
	}
	if err := yaml.Unmarshal(data, &cfg); err != nil {
		return err
	}
	return nil
}
