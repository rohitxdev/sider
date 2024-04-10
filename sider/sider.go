package sider

func NewSider() *Sider {
	return &Sider{
		store: make(map[string]string),
	}
}

type Sider struct {
	store map[string]string
}

func (s *Sider) Get(key string) string {
	return s.store[key]
}

func (s *Sider) Set(key string, value string) {
	s.store[key] = value
}
