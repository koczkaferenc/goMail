package db

import (
	"database/sql"
	"log"
	_ "github.com/go-sql-driver/mysql"
)

var Db *sql.DB

func Init() {
	var err error
	Db, err = sql.Open("mysql", "gomail:Rochieyiekaba3ee@tcp(127.0.0.1:3306)/gomail?parseTime=true")
	if err != nil {
		log.Fatal(err)
	}
}
