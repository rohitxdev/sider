package client

import "net"

type SiderClient struct {
	Host string
	Port string
}

func (s *SiderClient) Connect() (*net.Conn, error) {
	address := s.Host + ":" + s.Port
	conn, err := net.Dial("tcp", address)
	if err != nil {
		return nil, err
	}
	return &conn, nil
}
