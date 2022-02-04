package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strings"
	"sync"
)

var wg = sync.WaitGroup{}

type DomainStatus struct {
	domain string
	status int
}

func main() {
	allArgs := os.Args[1:]
	if len(allArgs) > 0 {
		filename := allArgs[0]

		content, err := ioutil.ReadFile(filename)
		if err != nil {
			log.Fatal(err)
		}

		checkDomains := strings.Split(string(content), "\n")

		wg.Add(len(checkDomains))
		for _, v := range checkDomains {
			go checkDomain(v)
		}
		wg.Wait()
	} else {
		fmt.Println("Domain checker v.0.1")
		fmt.Println("Usage: docmainCheck domains.txt")
	}
}

func checkDomain(domain string) {
	client := &http.Client{}
	req, err := http.NewRequest("GET", domain, nil)
	if err != nil {
		log.Fatalln(err)
	}
	req.Header.Set("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36")

	resp, err := client.Do(req)
	if err != nil {
		log.Fatalln(err)
	}
	defer resp.Body.Close()
	checkResult := DomainStatus{domain, resp.StatusCode}
	fmt.Println(checkResult)
	wg.Done()

}
