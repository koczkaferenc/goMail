package isp

import (
	"html/template"
	"log"
	"net/http"
	"strconv"
)

/**************************************************** */
// Felhasználók listázása
/**************************************************** */
func (e *Env) ListUsers(w http.ResponseWriter, r *http.Request) {
	type UsersPageData struct {
		UserEmail string // A bejelentkezett felhasználó címe
		Users     []User // A listázandó felhasználók
	}
	session, _ := e.Store.Get(r, e.Config.Server.Session.Name)
	email, ok := session.Values["email"].(string)
	if !ok {
		email = "Vendég" // Alapértelmezett érték, ha nincs bejelentkezve
	}
	data := UsersPageData{
	    UserEmail: email,
	    Users: []User{
	        {Id: 1, Name: "Kiss Lajos"},
	        {Id: 2, Name: "Szabó Pál"},
	        {Id: 3, Name: "Nagy József"},
	    },
	}
	tmpl, _ := template.ParseFiles("templates/layout.html", "templates/usersList.html")
	tmpl.ExecuteTemplate(w, "layout", data)
	log.Printf("%v", session)
}

/**************************************************** */
// Felhasználó űrlapja
/**************************************************** */
func (e *Env) UserForm(w http.ResponseWriter, r *http.Request) {
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
func (e *Env) userStore(w http.ResponseWriter, r *http.Request) {
		//

}

/**************************************************** */
// Felhasználó törlése
/**************************************************** */
func (e *Env) userDelete(w http.ResponseWriter, r *http.Request) {
	//
}

/**************************************************** */
// Login
/**************************************************** */
func (e *Env) UserLoginForm(w http.ResponseWriter, r *http.Request) {
	tmpl, _ := template.ParseFiles("templates/layout.html", "templates/userLoginForm.html")
	tmpl.ExecuteTemplate(w, "layout", nil)
}

/**************************************************** */
// Login
/**************************************************** */
func (e *Env) UserLogin(w http.ResponseWriter, r *http.Request) {
	email := r.FormValue("email")
	password := r.FormValue("password")
	log.Printf("user: %s, password: %s", email, password)

	Errors := make(map[string]string)
	if email == "" || password == "" {
		Errors["Email"] = "Email is required"
		Data := map[string]interface{}{
			"Errors": Errors,
			"Email": email,
		}
		tmpl, _ := template.ParseFiles("templates/layout.html", "templates/userLoginForm.html")
		tmpl.ExecuteTemplate(w, "layout", Data)
		// http.Redirect(w, r, "/userLoginForm", http.StatusSeeOther)
		return
	}



	session, _ := e.Store.Get(r, e.Config.Server.Session.Name)
	session.Values["email"] = email
	session.Values["password"] = password
	session.Values["logged"] = true
	session.Save(r, w)
	log.Printf("Session: %v", session.Values)
	http.Redirect(w, r, "/", http.StatusSeeOther)

}

/**************************************************** */
// Logout
/**************************************************** */
func (e *Env) UserLogout(w http.ResponseWriter, r *http.Request) {
	log.Println("User logged out")
	session, _ := e.Store.Get(r, e.Config.Server.Session.Name)
	session.Values = make(map[interface{}]interface{})
	session.Options.MaxAge = -1
	err := session.Save(r, w)
	if err != nil {
		http.Error(w, "Hiba a kijelentkezés során", http.StatusInternalServerError)
		return
	}
	http.Redirect(w, r, "/userLoginForm", http.StatusSeeOther)

}
