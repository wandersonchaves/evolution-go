package main
import (
	"fmt"
	"go.mau.fi/whatsmeow/types"
)

func main() {
	jidStr := "8695206925@s.whatsapp.net" // No space here!
	
	parsedJID, _ := types.ParseJID(jidStr)
	
	fmt.Printf("User: '%s'\n", parsedJID.User)
	fmt.Printf("Server: '%s'\n", parsedJID.Server)
	fmt.Printf("String: '%s'\n", parsedJID.String())
}
