# Github Ops Hack

## github tools

- gh (https://github.com/cli/cli)
- gh extensions (https://github.com/topics/gh-extension)
- graphQL API (https://docs.github.com/en/graphql/reference)
- REST API (https://docs.github.com/en/rest?apiVersion=2022-11-28)

## build image by yourself
```bash
make build GH_EXT_INSTALL_TOKEN=your_valid_token_for_github.com
```

## setup parameters

```bash
# FQDN(URL) and TOKEN for github/github enterprise
export GH_FQDN=github.com
export GH_TOKEN=your_valid_token_for_ops
```

## gh login

```bash
echo "${GH_TOKEN}" | gh auth login -p https -h ${GH_FQDN} --with-token
```

## hints for gh ops

- https://github.com/cli/cli
- https://github.com/topics/gh-extension
- https://docs.github.com/en/graphql/reference
- https://docs.github.com/en/graphql/guides/forming-calls-with-graphql
- https://docs.github.com/en/graphql/overview/explorer
- https://github.com/graphql/graphiql/tree/main
- https://github.com/github/gh-gei
- https://docs.github.com/en/migrations/using-github-enterprise-importer/migrating-between-github-products/migrating-repositories-from-github-enterprise-server-to-github-enterprise-cloud?tool=cli
- https://github.com/mona-actions/gh-repo-stats
