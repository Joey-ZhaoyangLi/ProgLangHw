package main

import (
	"encoding/json"
	"fmt"
	"os"
	"strconv"
)

var (
	bracesColor   = "DarkBlue"
	bracketsColor = "DarkViolet"
	commaColor    = "Black"
	colonColor    = "Maroon"
	boolColor     = "DarkBlue"
	stringColor   = "DarkSlateGray"
	escapeColor   = "Purple"
	keyColor      = "FireBrick"
	numberColor   = "SaddleBrown"
)

func parseString(str string) string {
	str = strconv.QuoteToASCII(str)
	res := ""
	for i := 0; i < len(str); i++ {
		if str[i] == '"' {
			res += "&quot;"
		} else if str[i] == '\'' {
			res += "&apos;"
		} else if str[i] == '<' {
			res += "&lt;"
		} else if str[i] == '>' {
			res += "&gt;"
		} else if str[i] == '&' {
			res += "&amp;"
		} else if str[i] == '\\' {
			if str[i+1] == 'u' {
				res += "<span style=\"color:" + escapeColor + "\">\\" + str[i+1:i+6] + "</span>"
				i = i + 5
			} else {
				res += "<span style=\"color:" + escapeColor + "\">\\" + string(str[i+1]) + "</span>"
				i++
			}
		} else {
			res += string(str[i])
		}
	}
	return res
}

func printJsonObject(jsonObject map[string]interface{}, indent int) {
	indentSpace := ""
	for i := 0; i < indent; i++ {
		indentSpace += "    "
	}
	count := 0
	for k, v := range jsonObject {
		fmt.Print(indentSpace)
		fmt.Print("<span style=\"color:" + keyColor + "\">" + parseString(k) + "</span>")
		fmt.Print("<span style=\"color:" + colonColor + "\"> : </span>")
		switch vv := v.(type) {
		case string:
			fmt.Print("<span style=\"color:" + stringColor + "\">" + parseString(vv) + "</span>")
		case json.Number:
			fmt.Printf("<span style=\"color:" + numberColor + "\">" + string(vv) + "</span>")
		case nil:
			fmt.Print("<span style=\"color:" + boolColor + "\">&quot;null&quot;</span>")
		case bool:
			if vv == true {
				fmt.Print("<span style=\"color:" + boolColor + "\">&quot;true&quot;</span>")
			} else {
				fmt.Print("<span style=\"color:" + boolColor + "\">&quot;false&quot;</span>")
			}

		case []interface{}:
			fmt.Println()
			fmt.Println(indentSpace + "<span style=\"color:" + bracketsColor + "\">[</span>")
			printJsonArray(vv, indent+1)
			fmt.Print(indentSpace + "<span style=\"color:" + bracketsColor + "\">]</span>")
		case map[string]interface{}:
			fmt.Println()
			fmt.Println(indentSpace + "<span style=\"color:" + bracesColor + "\">{</span>")
			printJsonObject(vv, indent+1)
			fmt.Print(indentSpace + "<span style=\"color:" + bracesColor + "\">}</span>")
		default:
			fmt.Print(vv, "is of a type I don't know how to handle")
		}
		count += 1
		if count == len(jsonObject) {
			fmt.Println("")
		} else {
			fmt.Println("<span style=\"" + commaColor + "\">,</span>")
		}
	}
}

func printJsonArray(jsonArray []interface{}, indent int) {
	indentSpace := ""
	for i := 0; i < indent; i++ {
		indentSpace += "    "
	}
	for i, v := range jsonArray {
		fmt.Print(indentSpace)
		switch vv := v.(type) {
		case string:
			fmt.Print("<span style=\"color:" + stringColor + "\">" + parseString(vv) + "</span>")
		case json.Number:
			fmt.Printf("<span style=\"color:" + numberColor + "\">" + string(vv) + "</span>")
		case nil:
			fmt.Print("<span style=\"color:" + boolColor + "\">&quot;null&quot;</span>")
		case bool:
			if vv == true {
				fmt.Print("<span style=\"color:" + boolColor + "\">&quot;true&quot;</span>")
			} else {
				fmt.Print("<span style=\"color:" + boolColor + "\">&quot;false&quot;</span>")
			}
		case []interface{}:
			fmt.Println("<span style=\"color:" + bracketsColor + "\">[</span>")
			printJsonArray(vv, indent+1)
			fmt.Print(indentSpace + "<span style=\"color:" + bracketsColor + "\">]</span>")
		case map[string]interface{}:
			fmt.Println("<span style=\"color:" + bracesColor + "\">{</span>")
			printJsonObject(vv, indent+1)
			fmt.Print(indentSpace + "<span style=\"color:" + bracesColor + "\">}</span>")
		default:
			fmt.Print(vv, "is of a type I don't know how to handle")
		}
		if i == len(jsonArray)-1 {
			fmt.Println("")
		} else {
			fmt.Println("<span style=\"" + commaColor + "\">,</span>")
		}
	}
}

func main() {
	// jsonData, err := ioutil.ReadFile(os.Args[1])
	jsonFile, err := os.Open(os.Args[1])
	if err != nil {
		panic(err)
	}
	var jsonItf interface{}
	// err = json.Unmarshal(jsonData, &jsonItf)
	dec := json.NewDecoder(jsonFile)
	dec.UseNumber()
	err = dec.Decode(&jsonItf)
	if err != nil {
		panic(err)
	}

	fmt.Println("<!DOCTYPE html>")
	fmt.Println("<html>")
	fmt.Println("<body>")
	fmt.Println("")
	fmt.Println("<span style=\"font-family:monospace; white-space:pre\">")

	switch js := jsonItf.(type) {
	case []interface{}:
		fmt.Println("<span style=\"color:" + bracketsColor + "\">[</span>")
		printJsonArray(js, 1)
		fmt.Print("<span style=\"color:" + bracketsColor + "\">]</span>")
	case map[string]interface{}:
		fmt.Println("<span style=\"color:" + bracesColor + "\">{</span>")
		printJsonObject(js, 1)
		fmt.Print("<span style=\"color:" + bracesColor + "\">}</span>")
	}
	fmt.Println()
	fmt.Println("</span>")
	fmt.Println("</body>")
	fmt.Println("</html>")
	jsonFile.Close()
}
