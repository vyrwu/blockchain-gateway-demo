package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/http/httputil"
	"net/url"
	"os"
	"slices"
	"strconv"
	"strings"
)

// HOST: https://polygon-rpc.com/
//
// >>> Get block number
//
// POST
// {
//   "jsonrpc": "2.0",
//   "method": "eth_blockNumber",
//   "id": 2
// }
//
// >>> Get block by number
//
// POST
// {
//   "jsonrpc": "2.0",
//   "method": "eth_getBlockByNumber",
//   "params": [
//     "0x134e82a",
//     true
//   ],
//   "id": 2
// }

type JSONRPC2Request struct {
	// TODO: implement https://www.jsonrpc.org/specification
	Method string `json:"method"`
}

type JSONRPC2Response struct {
	// TODO: implement https://www.jsonrpc.org/specification
	Error string `json:"error"`
}

type Options struct {
	TargetURL        string
	PathSegment      string
	SupportedMethods []string
}

func NewReverseProxy(optFns ...func(*Options)) (*http.ServeMux, error) {
	// TODO: improve config: 1. handle multiple domains, 2. pass from config map
	opts := &Options{
		TargetURL:        "https://polygon-rpc.com/",
		PathSegment:      "/eth",
		SupportedMethods: []string{"eth_blockNumber", "eth_getBlockByNumber"},
	}

	for _, fn := range optFns {
		fn(opts)
	}

	url, err := url.Parse(opts.TargetURL)
	if err != nil {
		return nil, err
	}

	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	// TODO: return at min. one gateway healthy
	mux.HandleFunc("GET /readyz", func(w http.ResponseWriter, r *http.Request) {
		reader := strings.NewReader(
			`{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":1}`,
		)

		resp, err := http.Post(url.String(), "application/json", reader)
		if err != nil {
			panic(err)
		}

		if resp.StatusCode != http.StatusOK {

			jresp := &JSONRPC2Response{}
			b, err := io.ReadAll(r.Body)
			if err != nil {
				slog.Error("error", err)
				w.WriteHeader(http.StatusInternalServerError)
				return
			}

			err = json.Unmarshal(b, jresp)
			if err != nil {
				slog.Error("error", err)
				w.WriteHeader(http.StatusInternalServerError)
				return
			}

			msg := fmt.Sprintf(
				"main: destination url healthz failed with %q\nerror: %s",
				resp.Status,
				jresp.Error,
			)

			panic(errors.New(msg))
		}
		w.WriteHeader(http.StatusOK)
	})

	mux.HandleFunc(
		fmt.Sprintf("POST %s", opts.PathSegment),
		func(w http.ResponseWriter, r *http.Request) {
			req := &JSONRPC2Request{}
			b, err := io.ReadAll(r.Body)
			if err != nil {
				slog.Error("error", err)
				w.WriteHeader(http.StatusInternalServerError)
				return
			}

			err = json.Unmarshal(b, req)
			if err != nil {
				slog.Error("error", err)
				w.WriteHeader(http.StatusInternalServerError)
				return
			}

			// FIX: might hinder performance for large response bodies.
			// Use io.TeeReader instead.
			r.Body = io.NopCloser(bytes.NewBuffer(b))

			if !slices.Contains(opts.SupportedMethods, req.Method) {
				w.WriteHeader(http.StatusBadRequest)
				fmt.Fprintf(w, "Unsupported RPC method %q", req.Method)
				return
			}

			r.URL.Host = url.Host
			r.URL.Scheme = url.Scheme
			r.Header.Set("X-Forwarded-Host", r.Header.Get("Host"))
			r.Host = url.Host
			path := r.URL.Path
			r.URL.Path = strings.TrimLeft(path, opts.PathSegment)
			proxy := httputil.NewSingleHostReverseProxy(url)
			proxy.ServeHTTP(w, r)
		},
	)

	return mux, nil
}

func GetenvInt(key string, fallback int) (int, error) {
	val := os.Getenv("PORT")
	if val == "" {
		return fallback, nil
	}

	i, err := strconv.Atoi(val)
	if err != nil {
		return 0, err
	}

	return i, err
}

func main() {
	port, err := GetenvInt("PORT", 8080)
	if err != nil {
		panic(err)
	}

	mux, err := NewReverseProxy()
	if err != nil {
		panic(err)
	}

	addr := fmt.Sprintf(":%v", port)
	slog.Info(fmt.Sprintf("Server started on %s...", addr))
	http.ListenAndServe(addr, mux)
}
