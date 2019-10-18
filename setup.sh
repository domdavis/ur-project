#!/usr/bin/env bash

DEFAULT_USER=idomdavis
DEFAULT_OWNER="Dom Davis"
README_LENGTH=8

FILES=(
    ".gitignore"
    ".golangci.yml"
    "bitbucket-pipelines.yml"
    "Makefile"
)

CWD=$(pwd -P)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PACKAGE=$(basename "${CWD}")

printf "Package Location: (default %s): " "${CWD}"
read -r dest

if [ -z "${dest}" ]; then
  dest="${CWD}"
fi

printf "Package name: (default: %s): " "${PACKAGE}"
read -r package

if [ -z "${package}" ]; then
  package="${PACKAGE}"
fi

printf "Bitbucket username (default %s): " "${DEFAULT_USER}"
read -r username

if [ -z "${username}" ]; then
  username="${DEFAULT_USER}"
fi

printf "Bitbucket repository (default %s): " "${package//[[space:]]/}"
read -r repository

if [ -z "${repository}" ]; then
  repository="${package//[[space:]]/}"
fi

printf "Bitbucket owner (default %s): " "${DEFAULT_OWNER}"
read -r owner

if [ -z "${owner}" ]; then
  owner="${DEFAULT_OWNER}"
fi

printf "Package overview: "
read -r overview

mkdir -p "${dest}"
cd "${dest}" || exit

for file in "${FILES[@]}"; do
  cp "${DIR}/${file}" "${dest}/${file}"
done

head -n "${README_LENGTH}" "${DIR}/README.md" | \
  sed "s/# Go Base/# ${package}/" | \
  sed "s/idomdavis/${username}/g" | \
  sed "s/gobase/${repository}/g" > "${dest}/README.md"
echo "${overview}" >> "${dest}/README.md"

sed "s/<OWNER>/${owner}/" "${DIR}/LICENSE" | \
  sed "s/<YEAR>/$(date +"%Y")/" > "${dest}/LICENSE"

sed "s/gobase/${package}/g" "${DIR}/doc.go" > "${dest}/doc.go"

go mod init "bitbucket.org/${username}/${repository}"
git init
git remote add origin "git@bitbucket.org:${username}/${repository}.git"
git add .

cd "${CWD}" || exit

echo "Done"
