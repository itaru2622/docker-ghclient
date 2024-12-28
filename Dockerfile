ARG base=debian:bookworm
FROM ${base}
ARG base=debian:bookworm

RUN apt update; apt install -y curl sudo locales-all locales;

# create user account, before nodejs(wants uid=1000)
ARG uid=1000
ARG uname=ghuser
ARG upass=ghuser
RUN addgroup --system --gid ${uid} ${uname} ; \
    adduser  --system --gid ${uid} --uid ${uid} --shell /bin/bash --home /home/${uname} ${uname} ; \
    echo "${uname}:${upass}" | chpasswd; \
    echo "${uname} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/local-user; \
    (cd /etc/skel; find . -type f -print | tar cf - -T - | tar xvf - -C/home/${uname} ) ; \
    echo "set mouse-=a" > /home/${uname}/.vimrc; \
    mkdir -p /home/${uname}/.ssh ;

ARG node_ver=20
RUN curl -fsSL https://deb.nodesource.com/setup_${node_ver}.x | bash -

# use github apt repo for latest gh client
RUN curl -L https://cli.github.com/packages/githubcli-archive-keyring.gpg | apt-key add -; \
    echo "deb https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list

# use MS repo for powershell required for github/gh-gei
RUN curl -L https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -o /tmp/ms-prod.deb; \
    apt install -y /tmp/ms-prod.deb;  \
    rm -f /tmp/ms-prod.deb

# libicu72: requires github/gh-gei extension
RUN apt update; apt install -y gh powershell libicu72 git openssh-client         parallel jq yq make bash-completion vim nodejs
RUN npm install -g typescript tsx @octokit/graphql @octokit/graphql-schema @octokit/plugin-paginate-graphql commander @commander-js/extra-typings
RUN curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 > /usr/local/bin/yq4; \
    chmod a+x /usr/local/bin/yq4


# install github/gh-gei (standalone tool), NOTE: 'gh extension install' requires 'gh login' on install ops.
#RUN curl -L -o /usr/local/bin/gh-gei https://github.com/github/gh-gei/releases/download/v1.10.0/gei-linux-amd64; chmod a+x /usr/local/bin/gh-gei

RUN chown -R ${uname}:${uname} /home/${uname} ;\
    echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen; locale-gen; update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"


ARG gh_url4install=github.com
USER ${uname}
# pass secret by 'docker build --secret', refer https://docs.docker.com/reference/cli/docker/buildx/build/#secret
#   deploy secret id:TOKEN1 to env:GH_TOKEN
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
     gh auth logout; rm -rf /home/${uname}/.config/gh ;

# be sure you logout before ending...

ENV TZ=Asia/Tokyo
WORKDIR /home/${uname}
