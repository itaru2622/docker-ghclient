ARG base=debian:bookworm
FROM ${base}
ARG base=debian:bookworm

RUN apt update; apt install -y curl sudo locales-all locales; \
    echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen; locale-gen; update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"

ARG node_ver=20
RUN curl -fsSL https://deb.nodesource.com/setup_${node_ver}.x | bash -

# use github apt repo for latest gh client
RUN curl -L https://cli.github.com/packages/githubcli-archive-keyring.gpg | apt-key add -; \
    echo "deb https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list

# use MS repo for powershell required for github/gh-gei
RUN curl -L https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -o /tmp/ms-prod.deb; \
    apt install -y /tmp/ms-prod.deb;  \
    rm -f /tmp/ms-prod.deb

# install azure-cli for managing user on EMU. https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# libicu72: requires github/gh-gei extension
RUN apt update; apt install -y gh powershell libicu72 git openssh-client         parallel jq yq make bash-completion vim nodejs less pwgen expect
RUN npm install -g typescript tsx @octokit/graphql @octokit/graphql-schema @octokit/plugin-paginate-graphql commander @commander-js/extra-typings github-csv-tools
RUN curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 > /usr/local/bin/yq4; \
    chmod a+x /usr/local/bin/yq4

# python libs for MS x graphql and others.
RUN pip install msal msgraph-sdk gql[all]    pandas openpyxl pydantic jsonpath-ng python-dotenv

# msgraph cli
ARG msgcURL=https://github.com/microsoftgraph/msgraph-cli/releases/download/v1.9.0/msgraph-cli-linux-x64-1.9.0.tar.gz
RUN curl -L ${msgcURL} -o /tmp/msgcli.tgz; \
    tar zxvf /tmp/msgcli.tgz -C /usr/local/bin ; rm -f  /tmp/msgcli.tgz

# git-sizer
RUN curl -L https://github.com/github/git-sizer/releases/download/v1.5.0/git-sizer-1.5.0-linux-amd64.zip > /tmp/git-sizer.zip; \
    unzip -x /tmp/git-sizer.zip git-sizer -d /usr/local/bin; rm -f /tmp/git-sizer.zip

RUN echo "set mouse-=a" > /root/.vimrc;

# pass secret by 'docker build --secret', refer https://docs.docker.com/reference/cli/docker/buildx/build/#secret
# https://docs.docker.com/build/ci/github-actions/secrets/
# https://scrapbox.io/kiryuanzu-public/docker_build_%E5%AE%9F%E8%A1%8C%E6%99%82%E3%81%AB_GitHub_Actions_%E3%81%AE%E3%83%AF%E3%83%BC%E3%82%AF%E3%83%95%E3%83%AD%E3%83%BC%E3%81%8B%E3%82%89_secrets%E6%83%85%E5%A0%B1%E3%82%92%E6%B8%A1%E3%81%97%E3%81%9F%E3%81%84%E6%99%82
#
#   deploy secret id:TOKEN1 to env:GH_TOKEN
ARG gh_url4install=github.com
RUN  --mount=type=secret,id=TOKEN1,env=GH_TOKEN \
     gh auth login -p https -h ${gh_url4install} ; \
     gh extension install github/gh-gei; \
     gh extension install github.com/github/gh-es; \
     gh extension install mona-actions/gh-repo-stats; \
     gh extension install jrnxf/gh-eco; \
     gh extension install gennaro-tedesco/gh-s; \
     gh extension install seachicken/gh-poi; \
     gh extension install github/gh-actions-importer; \
     gh extension install k1LoW/gh-grep; \
     gh extension install mislav/gh-repo-collab; \
     gh extension install dlvhdr/gh-dash; \
     gh extension install timrogers/gh-migrate-project; \
     gh auth logout; rm -rf /home/${uname}/.config/gh ;
# be sure you logout before ending...

ARG  sDir=/opt/github-misc-scripts
RUN  git clone https://github.com/joshjohanning/github-misc-scripts.git ${sDir}

RUN { \
      echo "sDir=${sDir}"; \
      echo 'export PATH=${PATH}:${sDir}/gh-cli:${sDir}/gh-cli/internal:${sDir}/git:${sDir}/graphql:${sDir}/scripts:${sDir}/scripts/multi-gitter-scripts:${sDir}/scripts/recreate-security-in-repositories-and-teams'; \

} > ${sDir}/0-setPath.sh

#ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${sDir}/api:${sDir}/gh-cli:${sDir}/gh-cli/internal:${sDir}/git:${sDir}/graphql:${sDir}/scripts:${sDir}/scripts/multi-gitter-scripts:${sDir}/scripts/recreate-security-in-repositories-and-teams

ENV TZ=Asia/Tokyo
