package main

import (
	"log"

	netipx "go4.org/netipx"
)

func main() {
	log.Println("Hello world!")

	ipRange, err := netipx.ParseIPRange("192.0.0.1-192.0.0.2")
	if err != nil {
		log.Fatalf("Something went wrong: %s", err)
	}
	log.Println(ipRange)
}
