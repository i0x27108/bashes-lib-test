#!/usr/bin/env bash

config_file="$(realpath "$(dirname "${BASH_SOURCE[0]}")")/.action-config"
get_config=(git config --file "${ACTION_CONFIG:-"$config_file"}")
section="init-git-subtree.conf"
git_dir=".subtree"

IFS='|' && while read -r dest repo rev; do
    printf >&2 'Init subtree: %s <- %s%s\n' "${dest}" "${repo}" "${rev:+" - "}${rev}"

    [[ -z "${dest:+"x"}" ]] \
        && dest="${PROJECT_ROOT:-"."}/subtree/$(basename --suffix='.git' "${repo}")"

    [[ -d "${dest}" ]] && rm --recursive --force "${dest}"

    git=(git -C "${dest}" --git-dir="${git_dir}" --work-tree=".")

    mkdir -p "${dest}" \
        && "${git[@]}" init --quiet \
        && "${git[@]}" fetch --quiet --depth 1 "${repo}" "${rev}" \
        && "${git[@]}" checkout --quiet FETCH_HEAD \
        || exit $?

    if [[ -f "${dest}/.gitmodules" ]]; then
        printf >&2 '  -> init submodules recursively\n'

        "${git[@]}" submodule --quiet update \
            --require-init \
            --single-branch \
            --recursive \
            --checkout \
            --depth=1 \
            || exit $?

        find "${dest}" -type f -name ".git" -delete
    fi

    rm --recursive --force "${dest:?}/${git_dir}"

done < <("${get_config[@]}" --get-all "${section/conf/"target"}")
