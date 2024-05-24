package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestMain(t *testing.T) {
	mux, err := New()
	if err != nil {
		panic(err)
	}

	// test eth_blockNumber
	body := strings.NewReader(`{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}`)
	r := httptest.NewRequest("POST", "/eth", body)
	r.Header.Add("Content-Type", "application/json")
	w := httptest.NewRecorder()
	mux.ServeHTTP(w, r)

	assert.Equal(t, http.StatusOK, w.Result().StatusCode)

	// test eth_getBlockByNumber
	type EthGetBlockByNumberResponse struct {
		Id       int    `json:"id"`
		Response string `json:"response"`
	}

	resp := new(EthGetBlockByNumberResponse)
	if err := json.Unmarshal(w.Body.Bytes(), resp); err != nil {
		t.Fatal(err)
	}

	body = strings.NewReader(
		fmt.Sprintf(
			`{"method":"eth_getBlockByNumber","params":[%q,false],"id":%v,"jsonrpc":"2.0"}`,
			resp.Response,
			resp.Id,
		),
	)
	r = httptest.NewRequest("POST", "/eth", body)
	r.Header.Add("Content-Type", "application/json")
	w = httptest.NewRecorder()
	mux.ServeHTTP(w, r)

	assert.Equal(t, http.StatusOK, w.Result().StatusCode)

	// test eth_getBlockByNumber
	body = strings.NewReader(`{"method":"eth_blockedMethod","params":[],"id":1,"jsonrpc":"2.0"}`)
	r = httptest.NewRequest("POST", "/eth", body)
	r.Header.Add("Content-Type", "application/json")
	w = httptest.NewRecorder()
	mux.ServeHTTP(w, r)

	assert.Equal(t, http.StatusBadRequest, w.Result().StatusCode)
}
