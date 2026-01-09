package db

import (
	"database/sql"
	"log"

	_ "github.com/go-sql-driver/mysql"
)

var Db *sql.DB

func Init() {
	var err error
	Db, err = sql.Open("mysql", "user:pass@tcp4(127.0.0.1:3306)/demo")
	if err != nil {
		log.Fatal(err)
	}
}
