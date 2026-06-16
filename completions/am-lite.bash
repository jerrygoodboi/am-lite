# am-lite completion for Bash

_am_lite_completion() {
	local cur prev opts commands
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"

	# Global options
	opts="-y --yes -g --global --system -c --config --verbose -V --version -h --help"
	# Commands
	commands="-i install -r remove -u update -s search -l list -h help"

	case "$prev" in
		-c|--config)
			_filedir
			return 0
			;;
		-i|install|-r|remove|-u|update)
			# Complete installed apps for remove/update
			local install_location
			# Check user space config or fallback to system-wide
			if [ "$EUID" -eq 0 ]; then
				install_location="/opt"
			else
				install_location="${HOME}/.local/share/am-lite/opt"
			fi
			if [ -d "$install_location" ]; then
				local apps
				apps=$(find "$install_location" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null)
				COMPREPLY=( $(compgen -W "${apps}" -- "$cur") )
			fi
			return 0
			;;
		-s|search)
			return 0
			;;
	esac

	# Complete commands or global options
	if [[ "$cur" == -* ]]; then
		COMPREPLY=( $(compgen -W "${opts} ${commands}" -- "$cur") )
	else
		local cmd_nouns="install remove update search list help"
		COMPREPLY=( $(compgen -W "${cmd_nouns}" -- "$cur") )
	fi
}

complete -F _am_lite_completion am-lite
