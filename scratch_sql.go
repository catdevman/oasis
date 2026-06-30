package main

import (
	"database/sql"
	"fmt"

	_ "github.com/lib/pq"
)

func main() {
	db, err := sql.Open("postgres", "postgres://oasis:password@localhost:5432/oasis?sslmode=disable")
	if err != nil {
		panic(err)
	}

	var ptr *string
	err = db.QueryRow("SELECT NULL::text").Scan(&ptr)
	if err != nil {
		fmt.Printf("Scan NULL error: %v\n", err)
	} else {
		fmt.Printf("Scan NULL success, ptr is %v\n", ptr)
	}

	var ptr2 *string
	err = db.QueryRow("SELECT 'hello'::text").Scan(&ptr2)
	if err != nil {
		fmt.Printf("Scan 'hello' error: %v\n", err)
	} else {
		fmt.Printf("Scan 'hello' success, ptr2 is %v, value is %s\n", ptr2, *ptr2)
	}
}
