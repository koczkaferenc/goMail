
package isp
import "goMail/config"
import "github.com/gorilla/sessions"

// Ez a struktúra fogja össze a "környezetet"
type Env struct {
    Store sessions.Store
    Config config.Config
}
