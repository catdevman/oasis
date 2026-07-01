# All targets are delegated to mise tasks defined in .config/mise.toml

.PHONY: help
help:
	@mise tasks

# Delegate all other targets to mise
%:
	@mise run $@
