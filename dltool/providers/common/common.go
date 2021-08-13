package common

import (
	"github.com/buger/jsonparser"
)

func GetLastItemIndex(bytes []byte) int {

	length := 0

	jsonparser.ArrayEach(bytes, func(value []byte, dataType jsonparser.ValueType, offset int, err error) {
		length++
	})

	// Take away one to match indexes starting from 0
	return length - 1

}
