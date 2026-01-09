package isp

import (
	"html/template"
	"net/http"
)

/**************************************************** */
// Admin jogosultság ellenőrzése
/**************************************************** */
func (e *Env) amIAdmin(w http.ResponseWriter, r *http.Request) bool {
    session, _ := e.Store.Get(r, e.Config.Server.Session.Name)
    userAdmin, ok := session.Values["user_Admin"].(bool)
    if !ok || !userAdmin {
        http.Redirect(w, r, "/permissionDenied", http.StatusSeeOther)
        return false // Nem admin
    }
    return true
}

/**************************************************** */
// User jogosultság ellenőrzése
/**************************************************** */
func (e *Env) amILogged(w http.ResponseWriter, r *http.Request) bool {
    session, _ := e.Store.Get(r, e.Config.Server.Session.Name)
    userLogged, ok := session.Values["user_Logged"].(bool)
    if !ok || !userLogged {
        http.Redirect(w, r, "/permissionDenied", http.StatusSeeOther)
        return false // Nem admin
    }
    return true
}

/**************************************************** */
// NoRights
/**************************************************** */
func (e *Env) PermissionDenied(w http.ResponseWriter, r *http.Request) {
	tmpl, err := template.ParseFiles("templates/layout.html", "templates/permissionDenied.html")
	if err != nil {
		http.Error(w, "Sablon hiba: "+err.Error(), http.StatusInternalServerError)
		return
	}
	err = tmpl.ExecuteTemplate(w, "layout", nil)
	if err != nil {
		http.Error(w, "Megjelenítési hiba: "+err.Error(), http.StatusInternalServerError)
		return
	}
}
