#!/bin/bash

set +e

if [ -z $1 ]; then
  error "Please set the 'version' variable"
  exit 1
fi

VERSION="$1"

set -e

cd $(dirname $0)
cur=$PWD

# The temporary directory to clone Trivy adapter source code
TEMP=$(mktemp -d ${TMPDIR-/tmp}/trivy-adapter.XXXXXX)
git clone https://github.com/aquasecurity/trivy.git $TEMP
cd $TEMP; git checkout $VERSION; cd -

cat > Dockerfile.binary <<eof
FROM golang:1.13.8
ADD .   /go/src/github.com/aquasecurity/trivy/
WORKDIR /go/src/github.com/aquasecurity/trivy/
RUN export GOOS=linux GO111MODULE=on CGO_ENABLED=0 && \
	go build -o scanner-trivy cmd/trivy/main.go
eof

echo "Building Trivy adapter binary based on golang:1.13.8..."
cp Dockerfile.binary $TEMP
docker build -f $TEMP/Dockerfile.binary -t zhangdber/harbor-trivy-bin:v2.0.0 $TEMP
docker login -u zhangdber -p 123456aaa docker.io
docker push zhangdber/harbor-trivy-bin:v2.0.0

#echo "Copying Trivy adapter binary from the container to the local directory..."
#ID=$(docker create trivy-adapter-golang)
#docker cp $ID:/go/src/github.com/aquasecurity/harbor-scanner-trivy/scanner-trivy binary

#docker rm -f $ID
#docker rmi -f trivy-adapter-golang

echo "Building Trivy adapter binary finished successfully"
cd $cur
rm -rf $TEMP
