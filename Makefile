#!/usr/bin/env make
# Makefile readme (ru): <http://linux.yaroslavl.ru/docs/prog/gnu_make_3-79_russian_manual.html>
# Makefile readme (en): <https://www.gnu.org/software/make/manual/html_node/index.html#SEC_Contents>

.PHONY : help \
	inspect

.DEFAULT_GOAL := help

SHELL := $(shell command -v bash 2>/dev/null)
export PROJECT_ROOT := $(shell dirname $(realpath $(firstword ${MAKEFILE_LIST})))


help: \
	## Show this help
	@awk 'BEGIN {RS=""; FS=":[^#]*##( )*"; print \
		"Usage:\n" \
		"  make \033[36m<target>\033[0m\n\n" \
		"Targets:\n" \
	} \
	/^[a-zA-Z_-]+:[^#]*##/ || /^## --- \[[[:print:]]+\]/	\
	{ \
		if (/^## --- \[[[:print:]]+\]/) { \
			match($$0, /\[([[:print:]]+)\]/, arr); desc=arr[1];\
			sub(/^[[:space:]]+/,"",desc); \
			sub(/[[:space:]]+$$/,"",desc); \
			printf "\n\033[33m%s:\033[0m\n", desc \
		} else { \
			sub(/\n\t.*/, "", $$2); \
			printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 \
		}\
	} \
	END {print ""}' \
	$(MAKEFILE_LIST)


## --- [ Repository ] ------------------------------------------------------------------------------------------

init-local: \
	## Perform additional actions for the local repository
	@source ${PROJECT_ROOT}/.action/init-git-subtree.bash


## --- [ Project ] ------------------------------------------------------------------------------------------

inspect: \
	## Run code inspections
	@source ${PROJECT_ROOT}/.action/inspect-shellcode.bash ${files}
