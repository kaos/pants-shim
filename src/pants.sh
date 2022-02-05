#!/usr/bin/env sh
# This is a thin Pants Build System shim, to locate and invoke the closest parent `pants` bootstrap
# script from the CWD.
set -euf -o pipefail

export PANTS_BIN_NAME=${PANTS_BIN_NAME:-pants}
relpath=
pants=

function find_pants_script {
    local path="$1"
    local script="${path}/${PANTS_BIN_NAME}"

    while [[ ! -x "${script}" || ! -f "${script}" ]]; do
        if [[ "${path}" = "/" ]]; then
            echo "Error: \`${PANTS_BIN_NAME}\` not found in or above of the directory ${1}" >&2
            exit 127
        fi
        path=$(dirname "${path}")
        script="${path}/${PANTS_BIN_NAME}"
    done

    pants="${script}"
    if [[ "${path}" != "${1}" ]]; then
        # Strip off the path to the repo root, so we can append that to all file path args.
        relpath="${1#${path}/}/"
    fi
}

function expand_path_parameters {
    for arg; do
        case "${arg}" in
            help|help-advanced|--help|--help-advanced)
                # No parameter path expansion for help invocations.
                echo "$@"
                return 0
        esac
    done

    for arg; do
        local opt=
        local val="${arg#*=}"

        if [[ "${arg}" =~ "=" ]]; then
            opt="${arg%%=*}="
        fi

        local maybe_path="${val%%:*}"
        local target=

        if  [[ "${val}" =~ ":" ]]; then
            target="${val#*:}"
        fi

        if [[ -e "${maybe_path}" ]]; then
            # Stitch everything together after adding the relpath from the repo root to our CWD.
            echo "${opt}${relpath}${maybe_path}${target}"
        else
            # Not a file path argument, leave as-is.
            echo "${arg}"
        fi
    done
}

find_pants_script "${PWD}"
if [[ -n "${pants}" ]]; then
    exec "${pants}" $(expand_path_parameters "$@")
fi
