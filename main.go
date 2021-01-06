package main

import (
	"fmt"

	"github.com/alexellis/release-it/version"
)

var (
	PublicKey string
)

func main() {
	fmt.Printf("release-it: %s, commit: %s\n", version.Version, version.GitCommit)

	if len(PublicKey) == 0 {
		panic("invalid public key")
	}
}
