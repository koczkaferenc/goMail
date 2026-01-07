package db

import (
	"goMail/isp"
	"os/user"
)

func (s *DBService) GetFullUser(userID int) (*user.User, error) {
	u := &user.User{Id: userID}

	// 1. Felhasználó lekérése
	err := s.DB.QueryRow("SELECT name FROM users WHERE id = ?", userID).Scan(&u.Name)
	if err != nil {
		return nil, err
	}

	// 2. Domainek lekérése az isp csomagba
	rows, _ := s.DB.Query("SELECT id, name FROM domains WHERE user_id = ?", userID)
	defer rows.Close()

	for rows.Next() {
		var d isp.Domain // Az isp csomag típusát példányosítjuk
		rows.Scan(&d.Id, &d.Name)
		u.Domains = append(u.Domains, d)
	}

	return u, nil
}
