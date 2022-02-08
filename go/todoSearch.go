package main

import (
	"bufio"
	"fmt"
	"os"
	"path"
	"regexp"
	"strings"
)

func main() {
	allArgs := os.Args[1:]
	dirSearch := allArgs[0]

	dirList, err := os.ReadDir(dirSearch)
	if err != nil {
		fmt.Println(err)
	}

	fmt.Println("-> File:line Urgency TODO")
	fmt.Println("-------------------------")
	for _, v := range dirList {
		f, err := os.Open(path.Join(dirSearch, v.Name()))
		if err != nil {
			fmt.Println(err)
		}
		defer f.Close()

		scanner := bufio.NewScanner(f)

		line := 1

		for scanner.Scan() {
			lineText := strings.ToLower(scanner.Text())
			if strings.Contains(lineText, "todo") {
				formated := formatTODO(lineText)
				urgency := checkUrgency(lineText)
				fmt.Printf("-> %s:%d %d %s\n", v.Name(), line, urgency, formated)
			}

			line++
		}
	}
}

func formatTODO(todoStr string) string {
	re := regexp.MustCompile(`tod\w+`)
	res := re.Split(todoStr, -1)
	return res[len(res)-1]
}

func checkUrgency(todoStr string) int {
	re := regexp.MustCompile(`tod\w+`)
	match := re.FindStringSubmatch(todoStr)
	urgency := strings.Split(match[0], "d")
	size := len(urgency[len(urgency)-1])
	return size
}
