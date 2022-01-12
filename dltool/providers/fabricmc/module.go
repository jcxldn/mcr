package fabricmc

type Module int64

const (
	Unknown Module = iota
	Game
	Loader
	Installer
)

func (m Module) String() string {
	switch m {
	case Game:
		return "game"
	case Loader:
		return "loader"
	case Installer:
		return "installer"
	}
	return "unknown"
}
