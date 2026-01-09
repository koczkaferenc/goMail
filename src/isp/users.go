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
	if ! e.amIAdmin(w, r) {
		return
	}

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
	if ! e.amIAdmin(w, r) {
		return
	}
	userId, _ := strconv.Atoi(r.URL.Query().Get("id"))
	u := User{}
	if userId > 0 {
		log.Printf("Adatok beolvasása az adatbázisból, Userid: %d", userId)
		u.Load(userId)
		log.Printf("User: %v",u)
	} else {
		log.Println("Új user")
	}

	session, _ := e.Store.Get(r, e.Config.Server.Session.Name)
	data := map[string]interface{}{
		"Session": session.Values,
		"User": u,
	}
	tmpl, _ := template.ParseFiles("templates/layout.html", "templates/userForm.html")
	tmpl.ExecuteTemplate(w, "layout", data)
}



/**************************************************** */
// Felhasználó rögzítése
/**************************************************** */
func (e *Env) UserStore(w http.ResponseWriter, r *http.Request) {
	if ! e.amIAdmin(w, r) {
		return
	}

	err := r.ParseForm()
    if err != nil {
        http.Error(w, "Hiba az adatok feldolgozásakor", http.StatusBadRequest)
        return
    }
    // name := r.FormValue("Name")
    // email := r.FormValue("Email")
    // password := r.FormValue("Password")
    // // Ha a checkbox nincs bepipálva, a FormValue üres string lesz.
    // enabled := r.FormValue("Enabled") == "on"
    // admin := r.FormValue("Admin") == "on"

	session, _ := e.Store.Get(r, e.Config.Server.Session.Name)
	http.Redirect(w, r, "/usersList", http.StatusSeeOther)
	log.Printf("userStore: Session=%v ", session.Values)
	log.Printf("userStore: r=%v ", r)
}

/**************************************************** */
// Felhasználó törlése
/**************************************************** */
func (e *Env) UserDelete(w http.ResponseWriter, r *http.Request) {
	if ! e.amIAdmin(w, r) {
		return
	}
	//
}

/**************************************************** */
// User Profile Form
/**************************************************** */
func (e *Env) UserProfileForm(w http.ResponseWriter, r *http.Request) {
	if ! e.amILogged(w, r) {
		return
	}
	session, _ := e.Store.Get(r, e.Config.Server.Session.Name)
	data := map[string]interface{}{
		"Session": session.Values,
	}
	tmpl, err := template.ParseFiles("templates/layout.html", "templates/userProfileForm.html")
	if err != nil {
		http.Error(w, "Sablon hiba: "+err.Error(), http.StatusInternalServerError)
		return
	}
	err = tmpl.ExecuteTemplate(w, "layout", data)
	if err != nil {
		http.Error(w, "Megjelenítési hiba: "+err.Error(), http.StatusInternalServerError)
		return
	}
}

/**************************************************** */
// User Profile rögzítése
/**************************************************** */
func (e *Env) UserProfileStore(w http.ResponseWriter, r *http.Request) {
	if ! e.amILogged(w, r) {
		return
	}
	// Rögzítés

	http.Redirect(w, r, "/", http.StatusSeeOther)
}

/**************************************************** */
// LoginForm
/**************************************************** */
func (e *Env) UserLoginForm(w http.ResponseWriter, r *http.Request) {
	tmpl, _ := template.ParseFiles("templates/layout.html", "templates/userLoginForm.html")
	tmpl.ExecuteTemplate(w, "layout", nil)
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

	if err = u.LoadByLoginData(email, password); err != nil {
		Data["ErrMsg"] = "Hiba! Érvénytelen bejelentkezési adatok."
		tmpl, _ := template.ParseFiles("templates/layout.html", "templates/userLoginForm.html")
		tmpl.ExecuteTemplate(w, "layout", Data)
		return
	}
	log.Printf("User: %v", u)
	session, _ := e.Store.Get(r, e.Config.Server.Session.Name)
	session.Values["user_Id"] = u.Id
	session.Values["user_Logged"] = true
	session.Values["user_Name"] = u.Name
	session.Values["user_Enabled"] = u.Enabled
	session.Values["user_Admin"] = u.Admin
	log.Printf("........................")

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
