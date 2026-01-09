package isp

import (
	"html/template"
	"log"
	"net/http"
	"strconv"
)

/**************************************************** */
// Index
/**************************************************** */
func (e *Env) Index(w http.ResponseWriter, r *http.Request) {
	session, _ := e.Store.Get(r, e.Config.Server.Session.Name)
	data := map[string]interface{}{
		"Session": session.Values,
	}
	tmpl, err := template.ParseFiles("templates/layout.html", "templates/index.html")
	if err != nil {
		http.Error(w, "Sablon hiba: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// 2. Hibakezelés a rendereléskor
	err = tmpl.ExecuteTemplate(w, "layout", data)
	if err != nil {
		http.Error(w, "Megjelenítési hiba: "+err.Error(), http.StatusInternalServerError)
		return
	}
}

/**************************************************** */
// Felhasználók listázása
/**************************************************** */
func (e *Env) ListUsers(w http.ResponseWriter, r *http.Request) {

	session, _ := e.Store.Get(r, e.Config.Server.Session.Name)
	users := []User{
		{Id: 1, Name: "Kiss Lajos"},
		{Id: 2, Name: "Szabó Pál"},
		{Id: 3, Name: "Nagy József"},
	}
	data := map[string]interface{}{
		"Users":   users,
		"Session": session.Values,
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

func getUserData(email string, password string) (User, error) {
	return User{
		Id:       1,
		Logged:   true,
		Enabled:  true,
		Admin:    true,
		Name:     "Koczka Ferenc",
		Email:    email,
		Password: password,
	}, nil
}

/**************************************************** */
// Login
/**************************************************** */
func (e *Env) UserLogin(w http.ResponseWriter, r *http.Request) {
	var (
		u   User
		err error
	)

	email := r.FormValue("email")
	password := r.FormValue("password")
	log.Printf("user: %s, password: %s", email, password)

	// Ellenőrzések
	Errors := make(map[string]string)
	Data := map[string]interface{}{
		"Email":  email,
		"ErrMsg": "",
		"Errors": Errors,
	}

	if email == "" {
		Errors["Email"] = "Az e-mail cím megadása kötelező."
	}
	if password == "" {
		Errors["Password"] = "A jelszó megadása kötelező."
	}
	if len(Errors) > 0 {
		tmpl, _ := template.ParseFiles("templates/layout.html", "templates/userLoginForm.html")
		Data["ErrMsg"] = "Hiba! Ellenőrizze a megadott adatokat!"
		tmpl.ExecuteTemplate(w, "layout", Data)
		return
	}

	if u, err = getUserData(email, password); err != nil {
		Data["ErrMsg"] = "Hiba! Érvénytelen bejelentkezési adatok."
		tmpl, _ := template.ParseFiles("templates/layout.html", "templates/userLoginForm.html")
		tmpl.ExecuteTemplate(w, "layout", Data)
		return
	}
	log.Printf("User: %v", u)
	session, _ := e.Store.Get(r, e.Config.Server.Session.Name)
	session.Values["user_Id"] = u.Id
	session.Values["user_Logged"] = u.Logged
	session.Values["user_Enabled"] = u.Enabled
	session.Values["user_Admin"] = u.Admin
	session.Values["user_Name"] = u.Name
	session.Values["user_Email"] = u.Email
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
