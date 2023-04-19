#!/usr/bin/env bash

project="${1}"
username="${2}"
repository="${3}"
dest="${4}"

sed "s/golang/${project}/" doc.go >> "${dest}/doc.go" || exit
cd "${dest}" || exit
go mod init "bitbucket.org/${username}/${repository}" || exit

cat << EOF
The following Bitbucket Pipeline Repository variables need to be set:
    AWS_ID - Your AWS ID
    IMAGE - docker image name in ECR (e.g. idomdavis/ur-project)
    BINARY - name of binary to compile
    AWS_DEFAULT_REGION - e.g. eu-west-2
    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY

The following BitBucket Pipeline deployments are needed:
    ecr-dev
    ecr-main
    ecr-latest
    ecs

The following Bitbucket Pipeline Deployment variables are needed in ecs:
    FAMILY_NAME - ECS Family name
    CLUSTER - ECS Cluster name
    SERVICE_NAME - ECS Service name
    SERVICE_MEMORY - eg: 512
    SERVICE_CPU - eg: 256
    SERVICE_COMMAND - eg "-c", "https://bucket.s3.eu-west-2.amazonaws.com/config.json"
EOF
