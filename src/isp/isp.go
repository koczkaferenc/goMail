package isp

import (
	"html/template"
	"log"
	"net/http"
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
	Logged   bool
	Enabled  bool
	Admin    bool
	Name     string
	Email    string
	Password string
	CreatedAt string
	LoggedAt string
	Domains  []Domain
}

/**************************************************** */
// DomainsList
/**************************************************** */
func (e *Env) DomainsList(w http.ResponseWriter, r *http.Request) {
	if ! e.amILogged(w, r) {
		return
	}
	session, _ := e.Store.Get(r, e.Config.Server.Session.Name)
	Domains := []Domain{
		{Id: 1, Name: "alma.hu"},
		{Id: 2, Name: "korte.hu"},
		{Id: 3, Name: "szilva.hu"},
	}
	data := map[string]interface{}{
		"Domains": Domains,
		"Session": session.Values,
	}

	tmpl, _ := template.ParseFiles("templates/layout.html", "templates/domainsList.html")
	tmpl.ExecuteTemplate(w, "layout", data)
	log.Printf("%v", session)
}
