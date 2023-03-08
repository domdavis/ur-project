#!/usr/bin/env bash

project="${1}"
username="${2}"
repository="${3}"
dest="${4}"

sed "s/golang/${project}/" doc.go >> "${dest}/doc.go" || exit
cd "${dest}" || exit
go mod init "bitbucket.org/${username}/${repository}" || exit
