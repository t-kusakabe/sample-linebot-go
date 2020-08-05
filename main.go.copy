package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"os"
	"time"
)

// ReceivedMessage ...
type ReceivedMessage struct {
	Result []Result `json:"result"`
}

// Result ...
type Result struct {
	ID          string  `json:"id"`
	From        string  `json:"from"`
	FromChannel string  `json:"fromChannel"`
	To          string  `json:"to"`
	ToChannel   string  `json:"toChannel"`
	EventType   string  `json:"eventType"`
	Content     Content `json:"content"`
}

// SendMessage ...
type SendMessage struct {
	To        []string `json:"to"`
	ToChannel int      `json:"toChannel"`
	EventType string   `json:"eventType"`
	Content   Content  `json:"content"`
}

// Content ...
type Content struct {
	ID          string   `json:"id"`
	ContentType int      `json:"contentType"`
	From        string   `json:"from"`
	CreatedTime int      `json:"createdTime"`
	To          []string `json:"to"`
	ToType      int      `json:"toType"`
	Text        string   `json:"text"`
}

// Const ...
const (
	EndPoint  = "https://line-bot-golang-test.herokuapp.com/"
	ToChannel = 1654607450
	EventType = "138311608800106203"
)

func main() {
	http.HandleFunc("/", helloHandler)
	http.HandleFunc("/callback", callbackHandler)
	port := os.Getenv("PORT")
	addr := fmt.Sprintf(":%s", port)
	http.ListenAndServe(addr, nil)
}

func helloHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, LINE Bot")
}

func callbackHandler(w http.ResponseWriter, r *http.Request) {
	decoder := json.NewDecoder(r.Body)
	var m ReceivedMessage
	err := decoder.Decode(&m)
	if err != nil {
		log.Println(err)
	}

	apiURI := EndPoint + "/v1/events"
	for _, result := range m.Result {
		from := result.Content.From
		text := result.Content.Text
		content := new(Content)
		content.ContentType = result.Content.ContentType
		content.ToType = result.Content.ToType
		content.Text = text
		request(apiURI, "PORT", []string{from}, *content)
	}
}

func request(endpointURI string, method string, to []string, content Content) {
	m := &SendMessage{}
	m.To = to
	m.ToChannel = ToChannel
	m.EventType = EventType
	m.Content = content
	b, err := json.Marshal(m)
	if err != nil {
		log.Print(err)
	}
	req, err := http.NewRequest(method, endpointURI, bytes.NewBuffer(b))
	if err != nil {
		log.Print(err)
	}
	req = setHeader(req)
	client := &http.Client{
		Transport: &http.Transport{Proxy: http.ProxyURL(getProxyURL())},
		Timeout:   time.Duration(30 * time.Second),
	}
	res, err := client.Do(req)
	if err != nil {
		log.Print(err)
	}
	defer res.Body.Close()

	var result map[string]interface{}
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		log.Print(err)
	}
	if err := json.Unmarshal(body, &result); err != nil {
		log.Print(err)
	}
	log.Print(result)
}

func setHeader(req *http.Request) *http.Request {
	req.Header.Add("Content-Type", "application/json; charset=UTF-8")
	req.Header.Add("X-Line-ChannelID", os.Getenv("ChannelID"))
	req.Header.Add("X-Line-ChannelSecret", os.Getenv("ChannelSecret"))
	req.Header.Add("X-Line-Trusted-User-With-ACL", os.Getenv("MID"))
	return req
}

func getProxyURL() *url.URL {
	proxyURL, err := url.Parse(os.Getenv("ProxyURL"))
	if err != nil {
		log.Print(err)
	}

	return proxyURL
}
