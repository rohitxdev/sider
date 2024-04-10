package sider

import (
	"fmt"
	"log"
	"log/slog"
	"net"

	"github.com/oklog/ulid/v2"
)

type SiderServer struct {
	Host       string //Default is 127.0.0.1
	Port       string //Default is 6379
	HandleConn func(net.Conn)
}

func (s *SiderServer) Listen() {
	if s.Host == "" {
		s.Host = "127.0.0.1"
	}
	if s.Port == "" {
		s.Port = "6379"
	}
	address := s.Host + ":" + s.Port

	listener, err := net.Listen("tcp", address)
	if err != nil {
		panic(err)
	}
	log.Println("Listening...")

	for {
		conn, err := listener.Accept()
		if err != nil {
			slog.Error(fmt.Sprintf("failed to accept TCP connection: %s", err))
		} else {
			reqId := "req_" + ulid.Make().String()
			slog.Info("new connection: " + reqId)
		}
		go s.HandleConn(conn)
	}
}
