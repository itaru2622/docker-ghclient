img ?=itaru2622/ghclient:bookworm
node_ver ?=20

wDir ?=${PWD}

GH_TOKEN         ?=changeme
GH_FQDN          ?=github.com

GH_EXT_INSTALL_TOKEN ?=changeme

# cf. https://docs.docker.com/reference/cli/docker/buildx/build/#secret

# SAMPLE:    make build GH_EXT_INSTALL_TOKEN=
build:
	#pass env:GH_EXT_INSTALL_TOKEN as secret id:TOKEN1
	docker build --build-arg node_ver=${node_ver}  --secret type=env,id=TOKEN1,env=GH_EXT_INSTALL_TOKEN -t ${img} .

# SAMPLE:    make start GH_TOKEN= [ wDir= GH_FQDN= ]
start:
	docker run --name ghclient -it --rm -v ${wDir}:${wDir} -w ${wDir} \
	   -e http_proxy=${http_proxy} -e https_proxy=${https_proxy} \
	   -e BROWSER=false \
	   -e GH_TOKEN=${GH_TOKEN} -e GH_FQDN=${GH_FQDN} \
	   ${img} /bin/bash

# SAMPLE:    make login [ GH_TOKEN= GH_FQDN= ]
login:
	echo ${GH_TOKEN} | gh auth login -p https -h ${GH_FQDN} --with-token
	-gh auth status

# SAMPLE:    make logout
logout:
	gh auth logout
	-gh auth status

# SAMPLE:    make graphql qf=some.gql v='key1=val1 key2=val2' gh_opt='--paginate --slurp'
#             qf: get query statement from file and remove comments.
#             v:  variables to pass as query params, and adds prefix '-f ' for each key=val pairs
#             NOTE: in graphQL, cursor variable name must be '$endCursor' for gh qpi graphql otherwise, you get endless loop.
graphql:
	$(eval    q:='$$(shell cat "${qf}"  | sed "s/#.*//")')
	$(eval vars:=$(addprefix -f , ${v}))
	@gh api graphql ${gh_opt} -f query=${q} ${vars}

# SAMPLE:    make list org=some_org
list:
	gh api graphql --paginate -f query='{ organization(login: "${org}") { membersWithRole(first: 100) { totalCount edges { node { login name email } role } pageInfo { endCursor hasNextPage } } } }'
