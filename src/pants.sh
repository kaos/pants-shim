#!/usr/bin/env sh
# This is a thin Pants Build System shim, to locate and invoke the closest parent `pants` bootstrap
# script from the CWD.


function find_pants_script {
    local path="$1"
    while [[ ! -x "${path}/pants" || ! -f "${path}/pants" ]]; do
        if [[ "${path}" = "/" ]]; then
            echo "Error: no \`pants\` script found in or above of the directory ${1}" >&2
            exit 127
        fi
        path=$(dirname "${path}")
    done
    echo "${path}/pants"
}


pants="$(find_pants_script $(pwd))"
if [[ -n "${pants}" ]]; then
    exec "${pants}" "$@"
fi
