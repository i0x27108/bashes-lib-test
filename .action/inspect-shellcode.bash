#!/usr/bin/env bash

set -e && targets=("${@}")

if [[ -z "$*" ]]; then
    config_file="$(realpath "$(dirname "${BASH_SOURCE[0]}")")/.action-config"
    get_config=(git config --file "${ACTION_CONFIG:-"$config_file"}")
    section="inspect-shellcode.conf"
    search_args=()

    # starting points to search
    if output="$("${get_config[@]}" "${section/conf/"dir"}")" \
        && [[ -n "$output" ]]; then
        IFS='|' && read -r -a search_args <<<"${output}"
    else
        search_args=("${PROJECT_ROOT:-"."}")
    fi

    # exclude some directories
    if output="$("${get_config[@]}" "${section/conf/"exclude-dir"}")" \
        && [[ -n "$output" ]]; then
        IFS='|' && read -r -a dirs <<<"${output}";
        dirs=("${dirs[@]@Q}")
        dirs=("${dirs[@]/#/-or -path }")
        IFS=' ' && eval "dirs=(${dirs[*]})"
        search_args+=('(' "${dirs[@]:1}" ')' '-prune' '-or')
    fi

    # specific file types
    if output="$("${get_config[@]}" "${section/conf/"file"}")" \
        && [[ -n "$output" ]]; then
        IFS='|' && read -r -a files <<<"${output}";
        files=("${files[@]@Q}")
        files=("${files[@]/#/-or -name }")
        IFS=' ' && eval "files=(${files[*]})"
        search_args+=('-type' 'f' '(' "${files[@]:1}" ')')
    else
        search_args+=('-type' 'f' '(' '-name' '*.sh' '-or' '-name' '*.bash' ')')
    fi

    # exclude some files
    if output="$("${get_config[@]}" "${section/conf/"exclude-file"}")" \
        && [[ -n "$output" ]]; then
        IFS='|' && read -r -a files <<<"${output}";
        files=("${files[@]@Q}")
        files=("${files[@]/#/-or -name }")
        IFS=' ' && eval "files=(${files[*]})"
        search_args+=('-not' '(' "${files[@]:1}" ')')
    fi

    while read -r -d $'\0'; do
        targets+=("$REPLY")
    done < <(find "${search_args[@]}" -print0 2>/dev/null)
fi

[[ ${#targets[@]} -eq 0 ]] || shellcheck "${targets[@]}"
