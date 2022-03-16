FROM ruby:2.6.6

RUN apt-get update \ 
    && apt-get install -y locales locales-all \
    && apt-get install -y postgresql-client \
    && apt-get install -y chromium \
    && apt-get install -y libxml2 \
    && apt-get install -y libxml2-dev \ 
    && apt-get install -y libxslt1-dev \ 
    && apt-get install -y nodejs \ 
    && apt-get install -y file

# Install latest version of Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y ./google-chrome-stable_current_amd64.deb \
    && rm ./google-chrome-stable_current_amd64.deb

RUN gem install bundler:2.2.21 \
    && gem install solargraph \
    && gem install haml-lint

RUN apt-get install -y imagemagick

# Ensure gems are cached and only get updated when they change. This will
# drastically increase build times when your gems do not change.

ARG BRANCH=develop

# Invalidates the cache when branch changes
RUN curl -o version.json https://api.github.com/repos/AgileVentures/shf-project/git/refs/heads/$BRANCH

# Clones latest version of the branch
RUN mkdir /workspaces && cd /workspaces && git clone --branch $BRANCH https://github.com/AgileVentures/shf-project.git shf-project

RUN cd /workspaces/shf-project && bundle install 

ARG USERNAME=postgres
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create a postgres user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

RUN apt-get install -y postgresql

RUN mkdir -p /var/postgres/data \
    && mkdir -p /var/log/postgres \
    && chown postgres /var/postgres/data \
    && chown postgres /var/log/postgres

COPY createdb.sh /
RUN chmod +rwx createdb.sh

USER postgres

ENV LANG="sv_SE.UTF-8"

RUN ./createdb.sh
    
ENV LANG="C.UTF-8"

USER root

# Install latest wkhtmltox to get around this issue: https://github.com/pallymore/wkhtmltopdf-binary-edge/issues/15
RUN apt-get install -y xfonts-base \
    && apt-get install -y xfonts-75dpi \
    && apt --fix-broken install \
    && wget "https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.buster_amd64.deb" \
    && dpkg -i wkhtmltox_0.12.6-1.buster_amd64.deb \
    && cp /usr/local/bin/wkhtmltoimage /usr/local/bundle/gems/wkhtmltoimage-binary-0.12.5/libexec/wkhtmltoimage-amd64

RUN mkdir -p /workspaces/shf-project/tmp && echo "export TMPDIR=/workspaces/shf-project/tmp" >> /root/.bashrc
