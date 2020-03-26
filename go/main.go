package main

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/rainycape/dl"
)

func main() {
	printHeader()

	filepath.Walk("lib", func(path string, info os.FileInfo, err error) error {
		if err != nil {
			panic(err)
		}
		if info.IsDir() {
			return nil
		}
		open(path).callMethods().close()
		return nil
	})
}

const (
	HEADER_COLOR = "\033[38;5;69m"
	INFO_COLOR   = "\033[38;5;238m"
	COLOR_RESET  = "\033[0m"
	SYMBOL_COLOR = "\033[38;5;240m"
)

func printHeader() {
	fmt.Println(HEADER_COLOR)
	fmt.Println(
		"┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓\n" +
			"┃    Go Application                          ┃\n" +
			"┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛")
	fmt.Println(COLOR_RESET)
}

func printInfo(info string) {
	fmt.Println(INFO_COLOR + "  " + info + COLOR_RESET)
}

func require(err error) {
	if err != nil {
		panic(err)
	}
}

func open(lib string) *wrap {
	printInfo("Loading library: " + SYMBOL_COLOR + lib)

	tmp, err := dl.Open(lib, dl.RTLD_LAZY)
	if err != nil {
		panic(err)
	}
	return &wrap{tmp}
}

type (
	helloFn func()
	addFn   func(a, b int) int
)

type wrap struct {
	dl *dl.DL
}

func (w *wrap) callMethods() *wrap {
	var (
		hello helloFn
		add   addFn
	)

	w._sym("sayHello", &hello)
	hello()

	w._sym("add", &add)
	fmt.Printf("add(3, 4) returned %d\n", add(3, 4))

	return w
}

func (w *wrap) close() {
	require(w.dl.Close())
}

func (w *wrap) _sym(name string, ptr interface{}) {
	printInfo("Loading Symbol: " + SYMBOL_COLOR + name)
	require(w.dl.Sym(name, ptr))
	fmt.Print("    ")
}
