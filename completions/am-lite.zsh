#compdef am-lite

_am_lite() {
	local line
	_arguments -C \
		'-y[Automatic yes to prompts]' \
		'--yes[Automatic yes to prompts]' \
		'(-g --global --system)'{-g,--global,--system}'[Force system-wide installation]' \
		'(-c --config)'{-c,--config}'[Use specific configuration file]:config file:_files' \
		'--verbose[Enable verbose debug logging]' \
		'(-V --version)'{-V,--version}'[Show version]' \
		'(-h --help)'{-h,--help}'[Show help]' \
		'1: :((
			install\:"Install application(s)"
			remove\:"Remove application(s)"
			update\:"Update application(s) or all"
			search\:"Search database"
			list\:"List installed applications"
			help\:"Show help"
		))' \
		'*::arg:->args'

	case "$line[1]" in
		install|remove|update|-i|-r|-u)
			local install_location
			if [ "$EUID" -eq 0 ]; then
				install_location="/opt"
			else
				install_location="${HOME}/.local/share/am-lite/opt"
			fi
			if [ -d "$install_location" ]; then
				local -a apps
				apps=($(find "$install_location" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null))
				_values 'installed applications' $apps
			fi
			;;
	esac
}

_am_lite "$@"
