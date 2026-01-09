package main

import (
	"fmt"
	"goMail/config"
	"goMail/db"
	"goMail/isp"
	"goMail/user"
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
		Store:  store,
		Config: cfg,
	}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /", app.Index)
	mux.HandleFunc("GET /usersList", app.ListUsers)
	mux.HandleFunc("GET /userForm", app.UserForm)
	mux.HandleFunc("GET /userLoginForm", app.UserLoginForm)
	mux.HandleFunc("POST /userLogin", app.UserLogin)
	mux.HandleFunc("GET /userLogout", app.UserLogout)
	mux.HandleFunc("GET /domainsList", app.DomainsList)

	db.Init()

	u := &user.User{}
	u.Load(1)
	fmt.Printf("Load: %s\n", u.Details())

	port := ":8080"
	fmt.Printf("Szerver: http://localhost%s\n", port)
	log.Fatal(http.ListenAndServe(port, mux))
}
