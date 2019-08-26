package main

import (
	"crypto/x509"
	"crypto/tls"
	"flag"
	"fmt"
  "encoding/json"
	"io/ioutil"
	"log"
	"net/http"
)

const (
	localCertFile = "certs/ca.pem"
)

func main() {
	insecure := flag.Bool("insecure-ssl", false, "Accept/Ignore all server SSL certificates")
	flag.Parse()

	// Get the SystemCertPool, continue with an empty pool on error
	rootCAs, _ := x509.SystemCertPool()
	if rootCAs == nil {
		rootCAs = x509.NewCertPool()
	}

	// Read in the cert file
	certs, err := ioutil.ReadFile(localCertFile)
	if err != nil {
		log.Fatalf("Failed to append %q to RootCAs: %v", localCertFile, err)
	}

	// Append our cert to the system pool
	if ok := rootCAs.AppendCertsFromPEM(certs); !ok {
		log.Println("No certs appended, using system certs only")
	}

	// Trust the augmented cert pool in our client
	config := &tls.Config{
		InsecureSkipVerify: *insecure,
		RootCAs:            rootCAs,
	}
	tr := &http.Transport{TLSClientConfig: config}
	client := &http.Client{Transport: tr}

  req, err := http.NewRequest(http.MethodGet, "https://127.0.0.1:8200/v1/secret/foo", nil)
  req.Header.Set("X-Vault-Token", "6IGkbZURNjfnqteaQncyoBS4")
	resp, err := client.Do(req)
  body, err := ioutil.ReadAll(resp.Body)
  bs := string(body)
  fmt.Println(bs)

  var result map[string]interface{}
  json.Unmarshal([]byte(bs), &result)
  fmt.Println(result["data"].(map[string]interface{})["bar"])



  if err != nil {
// handle err
  }
defer resp.Body.Close()

	// ...
}
