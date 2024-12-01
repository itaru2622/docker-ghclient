# Github Ops Hack

## github tools

- graphql API (https://docs.github.com/ja/graphql/reference)
- gh (https://github.com/cli/cli)
- gh-gei
- gh-repo-stats
- @octokit/graphql
- git

## setup parameters

```bash
# FQDN(URL) and TOKEN for github/github enterprise
export GHE_FQDN=github.com
export GHE_URL=https://api.${GHE_FQDN}/graphql
export GHE_TOKEN=your_valid_token
```

## login

```bash
echo "${GHE_TOKEN}" | gh auth login -p https -h ${GHE_FQDN} --with-token
```

## hints for gh ops

- https://docs.github.com/ja/graphql/overview/explorer https://docs.github.com/ja/graphql/reference https://docs.github.com/ja/graphql/guides/forming-calls-with-graphql
- https://github.com/cli/cli
- https://github.com/topics/gh-extension
- https://docs.github.com/ja/migrations/using-github-enterprise-importer/migrating-between-github-products/migrating-repositories-from-github-enterprise-server-to-github-enterprise-cloud?tool=cli
- https://github.com/github/gh-gei
- https://github.com/mona-actions/gh-repo-stats
- https://developer.mamezou-tech.com/blogs/2024/10/04/build-simple-github-org-admin-site/  with bun(https://github.com/oven-sh/bun)
