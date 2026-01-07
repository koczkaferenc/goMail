package main

import (
	"fmt"
	"goMail/isp"
	"goMail/config"
	"log"
	"net/http"
	"os"

	"github.com/gorilla/sessions"
)

var cfg config.Config
var store *sessions.FilesystemStore

func main() {
	// Konfiguráció beolvasása
    if err := config.LoadConfig(&cfg); err != nil {
        fmt.Println(err.Error())
        os.Exit(1)
    }
	err := os.MkdirAll(cfg.Server.Session.Path, 0755)
	if err != nil {
		log.Fatal("Nem sikerült létrehozni a session mappát:", err)
	}

	store = sessions.NewFilesystemStore(cfg.Server.Session.Path, []byte("nagyon-titkos-kulcs"))

	app := &isp.Env{
        Store: store,
        Config: cfg,
    }

	mux := http.NewServeMux()
	mux.HandleFunc("GET /", app.ListUsers)
	mux.HandleFunc("GET /usersList", app.ListUsers)
	mux.HandleFunc("GET /userForm", app.UserForm)
	mux.HandleFunc("GET /userLoginForm", app.UserLoginForm)
	mux.HandleFunc("POST /userLogin", app.UserLogin)
	mux.HandleFunc("GET /userLogout", app.UserLogout)

	port := ":8080"
	fmt.Printf("Szerver: http://localhost%s\n", port)
	log.Fatal(http.ListenAndServe(port, mux))
}
