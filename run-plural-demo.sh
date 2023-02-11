#!/bin/bash

#####################################################################
# This `run-plural-demo.sh` script will create a demo
# k8s-in-docker cluster and prep Terraform and
# Helm Charts to install Plural console.
#
# You can then apply the Terraform and log in to the
# Plural local demo UI and install Apps (Helm Charts)
# via the Plural interface.
#
# Based on instructions from:
# https://docs.plural.sh/reference/cli-reference
# https://docs.plural.sh/getting-started/quickstart
#####################################################################

set -eux

# https://docs.plural.sh/getting-started/quickstart#install-plural-cli
# brew install pluralsh/plural/plural
git clone https://github.com/johnko/plural-cli.git
pushd plural-cli
git checkout offline
if uname -a | grep -q -i darwin; then
  sed -i '' 's,linux,darwin,' Dockerfile
  sed -i '' 's,RUN /go/bin/plural,#,' Dockerfile
fi
make build
popd
if [ -d plural-cli ]; then
  rm -fr plural-cli
fi

PLURAL_IMAGE=$( docker image ls | grep plural.sh | head -n 1 | awk '{print$1":"$2}' )
docker run --rm -d --name pluralcli $PLURAL_IMAGE sleep 20 &
sleep 5
docker cp pluralcli:/go/bin/plural ./.plural

mkdir -p ${HOME}/.plural

./.plural init

./.plural bundle install console console-kind

./.plural build

./.plural deploy --commit "initial deploy"

# PASSWORD_FOR_RANCHER_ADMIN=$( cat /dev/random | LC_ALL=C tr -dc 'a-zA-Z0-9-_' | fold -w 30 | head -n 1 )

# open "https://localhost:8443/"

# for i in `seq 1 10`; do
#   sleep 15
#   kubectl -n cattle-system port-forward svc/rancher 8443:443 || true
# done

