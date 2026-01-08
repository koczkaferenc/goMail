package isp

import (
	"time"
)

type Domain struct {
	Id           int
	Name         string
	Mailboxlimit int
	Mailboxes    []Mbox
	Aliases      []Alias
}

type Mbox struct {
	Id              int
	Enabled         bool
	Localpart       string
	Domain          string
	Home            string
	Uid             int
	Gid             int
	Forward         string
	Copyto          string
	Vacationstart   time.Time
	Vacationend     time.Time
	Vacationmessage string
	CreatedAt       time.Time
	ExpiresAt       time.Time
	Mboxsize        int
	Lastlogged      time.Time
	Lastprotocol    string
}

type Alias struct {
	Id        int
	Localpart string
	Domain    string
	Addresses string
}

type User struct {
	Id       int
	Logged   bool
	Enabled  bool
	Admin    bool
	Name     string
	Email    string
	Password string
	Domains  []Domain
}
