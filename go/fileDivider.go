package main

import (
	"bufio"
	"fmt"
	"os"
)

func checkError(err error) {
	if err != nil {
		panic(err)
	}
}

func divideFile(targetFile string) {
	f, err := os.Open(targetFile)
	f1, err := os.Create("part1")
	f2, err := os.Create("part2")
	checkError(err)
	defer func() {
		if err := f.Close(); err != nil {
			panic(err)
		}
		if err := f1.Close(); err != nil {
			panic(err)
		}
		if err := f2.Close(); err != nil {
			panic(err)
		}
	}()

	fi, err := f.Stat()
	fileSize := int(fi.Size())
	fmt.Println("File size: ", fileSize)

	r := bufio.NewReader(f)
	b := make([]byte, 1)

	for i := 0; i < fileSize; i++ {
		if i%2 == 0 {
			_, err := r.Read(b)
			checkError(err)
			_, err1 := f1.Write(b)
			checkError(err1)
		} else {
			_, err := r.Read(b)
			checkError(err)
			_, err1 := f2.Write(b)
			checkError(err1)
		}
	}
	fmt.Println("Result in part1 and part2 files")
}

func glueFiles(file1, file2 string) {
	f1, err := os.Open(file1)
	checkError(err)
	f2, err := os.Open(file2)
	checkError(err)
	resultFile, err := os.Create("result")
	checkError(err)
	defer func() {
		if err := f1.Close(); err != nil {
			panic(err)
		}
		if err := f2.Close(); err != nil {
			panic(err)
		}
		if err := resultFile.Close(); err != nil {
			panic(err)
		}
	}()
	fi1, err := f1.Stat()
	checkError(err)
	f1Size := int(fi1.Size())

	fi2, err := f2.Stat()
	checkError(err)
	f2Size := int(fi2.Size())

	fmt.Println("File 1 size: ", f1Size)
	fmt.Println("File 2 size: ", f2Size)

	resulSize := f1Size + f2Size
	r1 := bufio.NewReader(f1)
	r2 := bufio.NewReader(f2)
	b := make([]byte, 1)

	for i := 0; i < resulSize; i++ {
		if i%2 == 0 {
			_, err := r1.Read(b)
			checkError(err)
			_, err1 := resultFile.Write(b)
			checkError(err1)
		} else {
			_, err := r2.Read(b)
			checkError(err)
			_, err1 := resultFile.Write(b)
			checkError(err1)
		}
	}
	fmt.Println("Result in result file")
}

func main() {
	if len(os.Args) == 1 {
		fmt.Println("--> DIVIDE FILE")
		fmt.Println("Usage: ./main file")
		fmt.Println("--> GLUE FILES")
		fmt.Println("Usage: ./main file1 file2")
		return
	} else if len(os.Args) == 2 {
		divideFile(os.Args[1])
	} else if len(os.Args) == 3 {
		glueFiles(os.Args[1], os.Args[2])
	}
}
