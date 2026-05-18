package main
import (
	"fmt"
	"strings"
	"go.mau.fi/whatsmeow/types"
)

func main() {
	jidStr := "558695206925 @s.whatsapp.net"
	
	// How ParseJID works in whatsmeow:
	parts := strings.Split(jidStr, "@")
	parsedJID := types.JID{User: parts[0], Server: parts[1]}
	
	fmt.Printf("User: '%s'\n", parsedJID.User)
	fmt.Printf("Server: '%s'\n", parsedJID.Server)
	fmt.Printf("String: '%s'\n", parsedJID.String())
}
