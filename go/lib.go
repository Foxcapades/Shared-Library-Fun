package main

import (
	"C"
	"fmt"
)

//export sayHello
func sayHello() {
	fmt.Println("Hello from Go")
}

//export add
func add(a, b int) int {
	return a + b
}

func main() {}
