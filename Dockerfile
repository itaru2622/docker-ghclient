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

# libicu72: requires github/gh-gei extension
RUN apt update; apt install -y gh libicu72 git openssh-client         parallel jq make bash-completion vim nodejs
RUN npm install -g typescript tsx ts-node @octokit/graphql bun

# install github/gh-gei (standalone tool), NOTE: 'gh extension install' requires 'gh login' on install ops.
#RUN curl -L -o /usr/local/bin/gh-gei https://github.com/github/gh-gei/releases/download/v1.10.0/gei-linux-amd64; chmod a+x /usr/local/bin/gh-gei

RUN chown -R ${uname}:${uname} /home/${uname} ;\
    echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen; locale-gen; update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"

# gh_token4readonly:  create new personal token via github UI 'Fine-grained tokens' form, with just accessing for public repos access but any others.
# NOTE: ALL BUILD-ARG(INCLUDING GH_TOKEN4READONLY) IS VISIBLE FOR ANYONE BY INSPECTING DOCKER IMAGE.
ARG gh_token4readonly=changeme
ARG gh_url4install=github.com
USER ${uname}
RUN echo ${gh_token4readonly} | gh auth login -p https -h ${gh_url4install} --with-token; \
     gh extension install github/gh-gei; gh extension upgrade github/gh-gei; \
     gh auth logout; rm -rf /home/${uname}/.config/gh

# be sure you logout before ending...

ENV TZ=Asia/Tokyo
WORKDIR /home/${uname}
