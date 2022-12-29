package main

import (
	"fmt"
	"github.com/tidwall/pretty"
	"os"
)

func readFromFile(fileName string) []byte {
	data, err := os.ReadFile(fileName)
	if err != nil {
		panic(err)
	}
	return data
}

func writeToFile(fileName string, data []byte) {
	err := os.WriteFile(fileName, data, 0644)
	if err != nil {
		panic(err)
	}
}

func main() {
	argLen := len(os.Args[1:])
	if argLen < 2 {
		fmt.Println("JSON Pretty Formatter")
		fmt.Println("Usage: json-pretty-formatter <input_file> <output_file>")
		fmt.Println("Example: json-pretty-formatter input.json output.json")
		fmt.Println("Author: https://github.com/ZanMax")
		return
	} else {
		inFile := os.Args[1]
		outFile := os.Args[2]
		example := readFromFile(inFile)
		result := pretty.Pretty(example)
		writeToFile(outFile, result)
	}
}
