package main

import (
	"goMail/db"
	"fmt"
	"goMail/user"
)

func main() {
	db.Init()

	u := &user.User{}
	u.Load(1)
	fmt.Printf("Load: %s\n", u.Details())
}
