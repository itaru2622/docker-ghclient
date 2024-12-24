img ?=itaru2622/ghclient:bookworm
node_ver ?=20

wDir ?=${PWD}

GH_TOKEN         ?=changeme
GH_FQDN          ?=github.com
GH_URL           ?=https://api.${GH_FQDN}
GH_URL_graphQL   ?=https://api.${GH_FQDN}/graphql

GH_EXT_INSTALL_TOKEN ?=changeme

# cf. https://docs.docker.com/reference/cli/docker/buildx/build/#secret

build:
	#pass env:GH_EXT_INSTALL_TOKEN as secret id:TOKEN1
	docker build --build-arg node_ver=${node_ver}  --secret type=env,id=TOKEN1,env=GH_EXT_INSTALL_TOKEN -t ${img} .

start:
	docker run --name ghclient -it --rm -v ${wDir}:${wDir} -w ${wDir} \
	   -e BROWSER=false \
	   -e GH_TOKEN=${GH_TOKEN} -e GH_FQDN=${GH_FQDN}  -e GH_URL=${GH_URL} -e GH_URL_graphQL=${GH_URL_graphQL}\
	   ${img} /bin/bash

login:
	echo ${GH_TOKEN} | gh auth login -p https -h ${GH_FQDN} --with-token
	-gh auth status

logout:
	gh auth logout
	-gh auth status

# SAMPLE:    make graphql qf=./Graphql/some.gql v='key1=val1 key2=val2' gh_opt='--paginate --slurp'
#             qf: get query statement from file and cut comments.
#             v:  variables to pass as query params, add prefix '-f ' for each key=val pairs
#             NOTE: in graphQL, cursor variable name must be '$endCursor' for gh qpi graphql otherwise, you get endless loop.
graphql:
	$(eval    q:='$$(shell cat "${qf}"  | sed "s/#.*//")')
	$(eval vars:=$(addprefix -f , ${v}))
	@gh api graphql ${gh_opt} -f query=${q} ${vars}

list:
	gh api graphql --paginate -f query='{ organization(login: "${org}") { membersWithRole(first: 100) { totalCount edges { node { login name email } role } pageInfo { endCursor hasNextPage } } } }'
