package isp

import (
	"html/template"
	"log"
	"net/http"
	"strconv"
	"time"
)

type Domain struct {
	Id           int
	Name         string
	Mailboxlimit int
	Mailboxes    []Mbox
	Aliases      []Alias
}

type Mbox struct {
	Id              int
	Enabled         bool
	Localpart       string
	Domain          string
	Home            string
	Uid             int
	Gid             int
	Forward         string
	Copyto          string
	Vacationstart   time.Time
	Vacationend     time.Time
	Vacationmessage string
	CreatedAt       time.Time
	ExpiresAt       time.Time
	Mboxsize        int
	Lastlogged      time.Time
	Lastprotocol    string
}

type Alias struct {
	Id        int
	Localpart string
	Domain    string
	Addresses string
}

type User struct {
	Id       int
	Enabled  bool
	Admin    bool
	Name     string
	Password string
	Domains  []Domain
}

var n string

/**************************************************** */
// Felhasználók listázása
/**************************************************** */
func ListUsers(w http.ResponseWriter, r *http.Request) {
	Data := []User{}
	u := User{
		Id:   1,
		Name: "Kiss Lajos",
	}
	Data = append(Data, u)
	u2 := User{
		Id:   2,
		Name: "Szabó Pál",
	}
	Data = append(Data, u2)
	tmpl, _ := template.ParseFiles("templates/layout.html", "templates/usersList.html")
	tmpl.ExecuteTemplate(w, "layout", Data)
	log.Printf("%v", Data)
}

/**************************************************** */
// Felhasználó űrlapja
/**************************************************** */
func UserForm(w http.ResponseWriter, r *http.Request) {
	userId := r.URL.Query().Get("id")
	uid, _ := strconv.Atoi(userId)
	log.Printf("id=%d", 2*uid)

	User := User{}
	User.Id = uid
	User.Name = "Kiss Lajos"
	tmpl, _ := template.ParseFiles("templates/layout.html", "templates/userForm.html")
	tmpl.ExecuteTemplate(w, "layout", User)
}

/**************************************************** */
// Felhasználó rögzítése
/**************************************************** */
func userStore(u User) error {
	return nil
}

/**************************************************** */
// Felhasználó törlése
/**************************************************** */
func userDelete(u User) error {
	// A domaineket nem törljük!
	return nil
}

/**************************************************** */
// Login
/**************************************************** */
func login() {

}

/**************************************************** */
// Logout
/**************************************************** */
func logout() {

}
