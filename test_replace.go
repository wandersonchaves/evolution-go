package main
import (
	"fmt"
	"strings"
)

func main() {
	phone1 := "558695206925 @s.whatsapp.net"
	phone2 := "8695206925 @s.whatsapp.net"
	
	fmt.Printf("Phone1 before: '%s'\n", phone1)
	phone1 = strings.ReplaceAll(phone1, " @", "@")
	fmt.Printf("Phone1 after: '%s'\n", phone1)
	
	fmt.Printf("Phone2 before: '%s'\n", phone2)
	phone2 = strings.ReplaceAll(phone2, " @", "@")
	fmt.Printf("Phone2 after: '%s'\n", phone2)
}
