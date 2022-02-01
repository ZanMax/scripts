package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
	"sync"
)

var matches []string
var wg = sync.WaitGroup{}
var lock = sync.Mutex{}

func fileSearch(dirname string, filename string) {
	files, _ := ioutil.ReadDir(dirname)
	for _, file := range files {
		if strings.Contains(file.Name(), filename) {
			lock.Lock()
			matches = append(matches, filepath.Join(dirname, filename))
			lock.Unlock()
		}
		if file.IsDir() {
			wg.Add(1)
			go fileSearch(filepath.Join(dirname, file.Name()), filename)
		}
	}
	wg.Done()
}

func main() {
	allArgs := os.Args[1:]

	if len(allArgs) == 2 {
		path := allArgs[0]
		name := allArgs[1]

		wg.Add(1)
		go fileSearch(path, name)
		wg.Wait()

		for _, file := range matches {
			fmt.Println("Found: ", file)
		}
	} else {
		fmt.Println("Async file searcher v.0.1")
		fmt.Println()
		fmt.Println("Usage:")
		fmt.Println("./filesearch /path filename")
	}
}
