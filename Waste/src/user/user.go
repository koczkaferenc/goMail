package user

import (
	"fmt"
	"log"
	"demo/db"
	"demo/isp"
	_ "github.com/go-sql-driver/mysql"
)

type User struct {
	Id   int    `json:"id"`
	Name string `json:"name"`
	Domains []isp.Domain `json:"domains"`
}

func (u *User) Details() string {
	res := fmt.Sprintf("User Id: %d, Name: %s", u.Id, u.Name)
	for _, domain := range u.Domains {
		res += fmt.Sprintf(", Domain: %s", domain.Name)
	}
	return res
}



func (u *User) Update() {
	_, err := db.Db.Query("UPDATE users SET name = ? WHERE id = ?", u.Name, u.Id)
	if err != nil {
		log.Println("Error updating user:", err)
		return
	}
	log.Println("User updated successfully")
}

func (u *User) Insert () {
	sqlResult, err := db.Db.Exec("INSERT INTO users(Name) VALUES (?)", u.Name)
	if err != nil {
		log.Println("Error inserting user:", err)
		return
	}
	id, err := sqlResult.LastInsertId()
	if err != nil {
		log.Println("Error getting last inserted ID:", err)
		return
	}
	u.Id = int(id)
	log.Println("User inserted successfully")
}

func (u * User) Delete() {
	_, err := db.Db.Exec("DELETE FROM users WHERE id = ?", u.Id)
	if err != nil {
		log.Println("Error deleting user:", err)
		return
	}
	log.Println("User deleted successfully")
}

func ListUsers() {
	rows, err := db.Db.Query("SELECT id, name FROM users")
	if err != nil {
		log.Println("Error listing users:", err)
		return
	}
	defer rows.Close()


	for rows.Next() {
		var id int
		var name string
		err := rows.Scan(&id, &name)
		if err != nil {
			log.Println("Error scanning user:", err)
			continue
		}
		fmt.Printf("User ID: %d, Name: %s\n", id, name)
	}
}

func NumOfUsers() int {
	var count int
	err := db.Db.QueryRow("SELECT COUNT(*) FROM users").Scan(&count)
	if err != nil {
		log.Println("Error counting users:", err)
		return 0
	}
	return count
}

func (u *User) Load(id int) error  {
	err := db.Db.QueryRow("SELECT id, name FROM users WHERE id = ?", id).Scan(&u.Id, &u.Name)
	if err != nil {
		log.Println("Error loading user:", err)
		return err
	}
	u.LoadDomains()
	return nil
}

func (u *User) LoadDomains() {
	rows, err := db.Db.Query("SELECT id, name FROM domains WHERE ownerid = ?", u.Id)
	if err != nil {
		log.Println("Error listing domains:", err)
		return
	}
	defer rows.Close()

	domains := []isp.Domain{}
	for rows.Next() {
		var id int
		var name string
		if err := rows.Scan(&id, &name); err != nil {
			log.Println("Error scanning domain:", err)
			continue
		}
		domains = append(domains, isp.Domain{Id: id, Name: name})
	}
	u.Domains = domains
}
