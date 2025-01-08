# Docker image for github ops

## tools/API for github ops

- gh command line tool: https://github.com/cli/cli
- gh extensions : https://github.com/topics/gh-extension
- REST API : https://docs.github.com/en/rest?apiVersion=2022-11-28#all-docs
- GraphQL API : https://docs.github.com/en/graphql/reference

## preinstalled tools for github ops in prebuild image:

```
# gh extensions:
dlvhdr/gh-dash
gennaro-tedesco/gh-s
github.com/github/gh-es
github/gh-actions-importer
github/gh-gei
jrnxf/gh-eco
k1LoW/gh-grep
mislav/gh-repo-collab
mona-actions/gh-repo-stats
seachicken/gh-poi

# others:
curl
git
jq
@octokit with nodejs/typescript
powershell for gh-gei
yq

# and maybe more...
```

## prepare before using

```bash
# FQDN(URL) and TOKEN for github/github enterprise
export GH_FQDN=github.com
export GH_TOKEN=your_valid_token_for_ops
```

## basic usage

```bash
# start docker container with bash
make start

# make sure gh is ready to use.
gh -h

# sign-in to github with gh
#  case 1) use makefile
make login
#  case 2) pure gh command
echo "${GH_TOKEN}" | gh auth login -p https -h ${GH_FQDN} --with-token

# then, you can ops any by gh
gh repo list

# sign-out from github
gh auth logout
```

## build docker image by yourself
```bash
make build GH_EXT_INSTALL_TOKEN=your_valid_token_for_github.com
```

## hints for github ops

bash scripts for github ops:
- https://github.com/joshjohanning/github-misc-scripts

gh client and its extensions:
- https://github.com/cli/cli
- https://github.com/topics/gh-extension
- https://github.com/github/gh-gei

Github REST API:
- https://docs.github.com/en/rest?apiVersion=2022-11-28#all-docs

Github GraphQL:
- https://docs.github.com/en/graphql/reference
- https://docs.github.com/en/graphql/guides/forming-calls-with-graphql
- https://docs.github.com/en/graphql/overview/explorer
- https://github.com/graphql/graphiql/tree/main

@octokit:
- https://github.com/octokit

topics in github
- https://github.com/topics/gh-extension
- https://github.com/topics/github
- https://github.com/topics/github-api
- https://github.com/topics/github-api-v4
- https://github.com/topics/github-api-v3

Migration among Github Enterprises (Server and Cloud):
- https://docs.github.com/en/migrations/using-github-enterprise-importer/migrating-between-github-products/migrating-repositories-from-github-enterprise-server-to-github-enterprise-cloud?tool=cli

