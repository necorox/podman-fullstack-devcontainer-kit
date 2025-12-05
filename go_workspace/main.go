package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/golang-jwt/jwt/v5"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello from Go! Public endpoint.")
	})

	http.HandleFunc("/protected", protectedHandler)

	port := "8080"
	log.Printf("Starting server on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

func protectedHandler(w http.ResponseWriter, r *http.Request) {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		http.Error(w, "Missing Authorization header", http.StatusUnauthorized)
		return
	}

	tokenString := strings.TrimPrefix(authHeader, "Bearer ")
	if tokenString == authHeader {
		http.Error(w, "Invalid token format", http.StatusUnauthorized)
		return
	}

	// In a real application, you would fetch the JWKS from Authentik
	// and validate the token signature using the public key.
	// For this demo, we will just parse the token (unverified) or verify against a shared secret if configured.
	// Since we don't have the public key easily accessible without fetching JWKS,
	// we'll demonstrate parsing.

	// WARNING: This example does NOT verify the signature for simplicity in this "Hello World" context
	// unless you provide the key. In production, use jwt.ParseWithClaims and a Keyfunc that fetches JWKS.
	
	token, _, err := new(jwt.Parser).ParseUnverified(tokenString, jwt.MapClaims{})
	if err != nil {
		http.Error(w, fmt.Sprintf("Failed to parse token: %v", err), http.StatusUnauthorized)
		return
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"message": "Access granted",
			"user":    claims["sub"],
			"claims":  claims,
		})
	} else {
		http.Error(w, "Invalid token claims", http.StatusUnauthorized)
	}
}
