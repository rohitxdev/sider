package sider_test

import (
	"strconv"
	"testing"

	"github.com/rohitxdev/sider/sider"
)

var s = sider.NewSider()

func BenchmarkSet(b *testing.B) {
	for i := 0; i < b.N; i++ {
		key := strconv.FormatInt(int64(i), 10)
		value := key
		s.Set(key, value)
	}
}

func BenchmarkGet(b *testing.B) {
	for i := 0; i < b.N; i++ {
		key := strconv.FormatInt(int64(i), 10)
		s.Get(key)
	}
}
