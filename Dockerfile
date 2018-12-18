FROM google/cloud-sdk:alpine

LABEL maintainer="frank.giesecke@skriptfabrik.com"

ENV HELM_VERSION=2.11.0
ENV SPACESHIP_PROMPT_VERSION=3.9.0

ARG APK_BASH_VERSION=4.4.19-r1
ARG APK_GETTEXT_VERSION=0.19.8.1-r2
ARG APK_JQ_VERSION=1.6_rc1-r1
ARG APK_OPENSSL_VERSION=1.0.2q-r0
ARG APK_SED_VERSION=4.4-r2
ARG APK_ZSH_VERSION=5.5.1-r0

# Update components
RUN gcloud --quiet components update

# Install kubectl
RUN gcloud --quiet components install kubectl

# Install bash
RUN set -xe; \
    apk add --no-cache \
        bash=${APK_BASH_VERSION};

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Helm
RUN set -xe; \
    apk add --no-cache openssl=${APK_OPENSSL_VERSION}; \
    curl -fsSL https://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -xz --strip-components=1 -C /usr/local/bin; \
    helm init -c;

# Install tools
RUN set -xe; \
    apk add --no-cache \
        gettext=${APK_GETTEXT_VERSION} \
        jq=${APK_JQ_VERSION} \
        sed=${APK_SED_VERSION};

# Install zsh
RUN set -xe; \
    apk add --no-cache \
        zsh=${APK_ZSH_VERSION} \
        zsh-vcs=${APK_ZSH_VERSION};

# Install oh-my-zsh
RUN set -xe; \
    curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh || true;

# Install and enable spaceship theme
ARG ZSH_CUSTOM=/root/.oh-my-zsh/custom
RUN set -xe; \
    mkdir "${ZSH_CUSTOM}/themes/spaceship-prompt"; \
    curl -fsSL https://github.com/denysdovhan/spaceship-prompt/archive/v${SPACESHIP_PROMPT_VERSION}.tar.gz | tar -xz --strip-components=1 -C "${ZSH_CUSTOM}/themes/spaceship-prompt"; \
    ln -s "${ZSH_CUSTOM}/themes/spaceship-prompt/spaceship.zsh-theme" "${ZSH_CUSTOM}/themes/spaceship.zsh-theme";

# Configure zsh
RUN set -xe; \
    sed -i 's/ZSH_THEME=.*/ZSH_THEME=spaceship/' /root/.zshrc; \
    sed -i 's/# COMPLETION_WAITING_DOTS="true"/COMPLETION_WAITING_DOTS="true"/' /root/.zshrc; \
    sed -i 's/# CASE_SENSITIVE="true"/CASE_SENSITIVE="true"/' /root/.zshrc; \
    sed -i "s/# DISABLE_AUTO_UPDATE=\"true\"/DISABLE_AUTO_UPDATE=\"true\"\\nDISABLE_UPDATE_PROMPT=\"true\"/" /root/.zshrc; \
    sed -i 's/^plugins=(/plugins=(helm kubectl/' /root/.zshrc; \
    echo 'source /google-cloud-sdk/completion.zsh.inc' >> /root/.zshrc;

# Copy scripts into image
COPY bin/activate-service-account /usr/local/bin/activate-service-account

WORKDIR /app

CMD ["gcloud"]
