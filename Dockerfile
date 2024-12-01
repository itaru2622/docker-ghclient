ARG base=debian:bookworm
FROM ${base}
ARG base=debian:bookworm

RUN apt update; apt install -y curl sudo locales-all locales


# create user account, before nodejs(wants uid=1000)
ARG uid=1000
ARG uname=ghuser
ARG upass=ghuser
RUN addgroup --system --gid ${uid} ${uname} ; \
    adduser  --system --gid ${uid} --uid ${uid} --shell /bin/bash --home /home/${uname} ${uname} ; \
    echo "${uname}:${upass}" | chpasswd; \
    (cd /etc/skel; find . -type f -print | tar cf - -T - | tar xvf - -C/home/${uname} ) ; \
    echo "${uname} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/local-user; \
    mkdir -p /home/${uname}/.ssh ;\
    echo "set mouse-=a" > /home/${uname}/.vimrc; \
    echo "ja_JP.UTF-8 UTF-8" > /etc/locale.gen; locale-gen; update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"

ARG node_ver=20
RUN curl -fsSL https://deb.nodesource.com/setup_${node_ver}.x | bash -

RUN apt update; \
    apt install -y gh git openssh-client parallel jq make bash-completion vim nodejs
RUN npm install -g typescript ts-node @octokit/graphql bun

# install github/gh-gei (standalone tool), NOTE: 'gh extension install' seems to require valid GH_TOKEN on install ops.
#    RUN gh extension install github/gh-gei; gh extension upgrade github/gh-gei
RUN curl -L -o /usr/local/bin/gh-gei https://github.com/github/gh-gei/releases/download/v1.10.0/gei-linux-amd64; chmod a+x /usr/local/bin/gh-gei

RUN chown -R ${uname}:${uname} /home/${uname}
ENV TZ=Asia/Tokyo
USER ${uname}
WORKDIR /home/${uname}
