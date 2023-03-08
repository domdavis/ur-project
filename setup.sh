#!/usr/bin/env bash

DEFAULT_USER="idomdavis"
DEFAULT_OWNER="Dom Davis"

choose() {
  PS3="${1}: "
  files=("${2}/"*)
  select file in "${files[@]}"; do
      if [[ -z $file ]]; then
          printf "Please select a valid %s" "${1}" >&2
      else
          break
      fi
  done
  echo "${file}"
}

CWD=$(pwd -P)
PROJECT=$(basename "${CWD}")

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${root}" || exit

printf "Project Location: (default %s): " "${CWD}"
read -r dest

if [ -z "${dest}" ]; then
  dest="${CWD}"
fi

mkdir -p "${dest}" || exit
cd "${dest}" || exit

printf "Project name: (default: %s): " "${PROJECT}"
read -r project

if [ -z "${project}" ]; then
  project="${PROJECT}"
fi

printf "Package owner (default %s): " "${DEFAULT_OWNER}"
read -r owner

if [ -z "${owner}" ]; then
  owner="${DEFAULT_OWNER}"
fi

printf "Bitbucket username (default %s): " "${DEFAULT_USER}"
read -r username

if [ -z "${username}" ]; then
  username="${DEFAULT_USER}"
fi

printf "Bitbucket repository (default %s): " "${project//[[space:]]/}"
read -r repository

if [ -z "${repository}" ]; then
  repository="${project//[[space:]]/}"
fi

git init || exit
git remote add origin "git@bitbucket.org:${username}/${repository}.git" || exit
cd "${root}" || exit

license=$(choose "License" "license")
type=$(choose "Project type" "project")

printf "Package overview: "
read -r overview

sed "s/{YEAR}/$(date +"%Y")/" "${license}" | \
  sed "s/{OWNER}/${owner}/g" >> "${dest}/LICENCE" || exit

find "${type}/files" ! -name files > tmp
while IFS= read -r file
do
  sed "s/{PROJECT}/${project}/g" "${file}" | \
      sed "s/{OWNER}/${owner}/g" | \
      sed "s/{USERNAME}/${username}/g" | \
      sed "s/{REPOSITORY}/${repository}/g" | \
      sed "s/{OVERVIEW}/${overview}/g" >> "${dest}/$(basename "${file}")" || exit
done < tmp
rm tmp

cd "${type}" || exit
./setup.sh "${project}" "${username}" "${repository}" "${dest}" || exit

cd "${dest}" || exit
git add . || exit

cd "${CWD}" || exit
echo "Done"
