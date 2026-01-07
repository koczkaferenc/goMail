package main

import (
	"fmt"
	"goMail/isp"
	"log"
	"net/http"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /usersList", isp.ListUsers)
	mux.HandleFunc("GET /userForm", isp.UserForm)

	// var store = sessions.NewCookieStore([]byte("titkos-kulcs-123"))
	// type MySessionData struct {
	// 	UserID   int
	// 	UserName string
	// 	Theme    string // Például egyedi színbeállítás
	// }
	//
	//
	// func LoginHandler(w http.ResponseWriter, r *http.Request) {
	// 1. Lekérjük a munkamenetet (létrehozza, ha nincs)
	// session, _ := store.Get(r, "gomail-session")

	// 2. Beletesszük az egyedi adatokat
	// session.Values["user_id"] = 42
	// session.Values["user_name"] = "Kiss Lajos"

	// 3. Elmentjük (ez küldi el a sütit a böngészőnek)
	// session.Save(r, w)

	// fmt.Fprint(w, "Bejelentkezve!")
	// }
	//
	port := ":8080"
	fmt.Printf("Szerver: http://localhost%s\n", port)
	log.Fatal(http.ListenAndServe(port, mux))
}
