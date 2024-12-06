img ?=itaru2622/ghclient:bookworm
node_ver ?=20

GHE_TOKEN ?=changeme
GHE_FQDN  ?=github.com
GHE_URL   ?=https://api.${GHE_FQDN}/graphql

GH_EXT_INSTALL_TOKEN ?=changeme

# cf. https://docs.docker.com/reference/cli/docker/buildx/build/#secret

build:
	#pass env:GH_EXT_INSTALL_TOKEN as secret id:TOKEN1
	docker build --build-arg node_ver=${node_ver}  --secret type=env,id=TOKEN1,env=GH_EXT_INSTALL_TOKEN -t ${img} .

start:
	docker run -it --rm -v ${PWD}:${PWD} -w ${PWD} \
	   -e BROWSER=false \
	   -e GHE_TOKEN=${GHE_TOKEN} -e GHE_FQDN=${GHE_FQDN}  -e GHE_URL=${GHE_URL} \
	   ${img} /bin/bash

login:
	echo ${GHE_TOKEN} | gh auth login -p https -h ${GHE_FQDN} --with-token
	gh auth status

list:
	gh api graphql --paginate -f query='{ organization(login: "${org}") { membersWithRole(first: 100) { totalCount edges { node { login name email } role } pageInfo { endCursor hasNextPage } } } }'
