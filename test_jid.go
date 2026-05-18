package main
import (
	"fmt"
	"strings"
)

// formatMXOrARNumber formats Mexican (52) or Argentine (54) numbers
func formatMXOrARNumber(jid string) string {
	if len(jid) < 2 {
		return jid
	}

	countryCode := jid[:2]

	// Check if it's MX (52) or AR (54)
	if countryCode == "52" && len(jid) == 13 {
		// Mexico: remove 2 digits (positions 2-3)
		// 5215551234567 -> 52 + 551234567 = 52551234567
		return countryCode + jid[4:]
	} else if countryCode == "54" && len(jid) == 13 {
		// Argentina: remove 1 digit (position 2)
		// 5411123456789 -> 54 + 11123456789 = 5411123456789
		return countryCode + jid[3:]
	}

	return jid
}

func formatBRNumber(jid string) string {
	return jid
}

func CreateJID(number string) (string, error) {
	if number == "" {
		return "", fmt.Errorf("number cannot be empty")
	}

	if strings.Contains(number, "@g.us") ||
		strings.Contains(number, "@s.whatsapp.net") ||
		strings.Contains(number, "@lid") ||
		strings.Contains(number, "@broadcast") ||
		strings.Contains(number, "@newsletter") {
		return number, nil
	}

	number = strings.ReplaceAll(number, " ", "")
	number = strings.ReplaceAll(number, "+", "")
	number = strings.ReplaceAll(number, "(", "")
	number = strings.ReplaceAll(number, ")", "")
	number = strings.Split(number, ":")[0]

	number = strings.Map(func(r rune) rune {
		if r >= '0' && r <= '9' {
			return r
		}
		return -1
	}, strings.TrimSpace(number))

	if number == "" {
		return "", fmt.Errorf("invalid number format")
	}

	number = formatMXOrARNumber(number)
	number = formatBRNumber(number)

	return number + "@s.whatsapp.net", nil
}

func main() {
	res, _ := CreateJID("+55 86 9520-6925")
	fmt.Printf("Result 1: '%s'\n", res)
	
	res2, _ := CreateJID("558695206925 ")
	fmt.Printf("Result 2: '%s'\n", res2)
}
