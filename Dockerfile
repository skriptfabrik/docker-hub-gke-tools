FROM google/cloud-sdk:414.0.0-alpine

LABEL maintainer="frank.giesecke@skriptfabrik.com"

ARG TARGETOS
ARG TARGETARCH

ENV HELM_VERSION=3.11.0
ENV KUBE_VERSION=1.26
ENV SPACESHIP_PROMPT_VERSION=4.13.1

# Use ash with options
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# Update Google Cloud components
RUN set -xe; \
    gcloud --quiet components update

# Install gke-gcloud-auth-plugin as Google Cloud component
RUN set -xe; \
	gcloud --quiet components install gke-gcloud-auth-plugin

# Install kubectl as Google Cloud component
RUN set -xe; \
    gcloud --quiet components install kubectl; \
    KUBECTL_BIN="$(command -v kubectl)"; \
    ls -l "${KUBECTL_BIN}".*; \
    rm "${KUBECTL_BIN}"; \
    ln "${KUBECTL_BIN}.${KUBE_VERSION}" "${KUBECTL_BIN}"

# Install kustomize as Google Cloud component
RUN set -xe; \
    gcloud --quiet components install kustomize

# Install openssl
# hadolint ignore=DL3018
RUN set -xe; \
    apk add --no-cache \
        openssl;

# Install Helm
# hadolint ignore=DL3018
RUN set -xe; \
    curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz | tar -xz --strip-components=1 -C /usr/local/bin;

# Install envsubst
# hadolint ignore=DL3018
RUN set -xe; \
    apk add --no-cache \
        gettext \
        libintl; \
    cp "$(command -v envsubst)" /usr/local/bin/envsubst; \
    apk del --purge gettext

# Install jq
# hadolint ignore=DL3018
RUN set -xe; \
    apk add --no-cache \
        jq;

# Install zsh
# hadolint ignore=DL3018
RUN set -xe; \
    apk add --no-cache \
        zsh \
        zsh-vcs;

# Install oh-my-zsh
RUN set -xe; \
    curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh || true;

# Install and enable Spaceship prompt
RUN set -xe; \
    ZSH_CUSTOM=/root/.oh-my-zsh/custom; \
    mkdir -p "${ZSH_CUSTOM}/themes/spaceship-prompt"; \
    curl -fsSL https://github.com/denysdovhan/spaceship-prompt/archive/v${SPACESHIP_PROMPT_VERSION}.tar.gz | tar -xz --strip-components=1 -C "${ZSH_CUSTOM}/themes/spaceship-prompt"; \
    ln -sf "${ZSH_CUSTOM}/themes/spaceship-prompt/spaceship.zsh-theme" "${ZSH_CUSTOM}/themes/spaceship.zsh-theme";

# Configure zsh
RUN set -xe; \
    sed -i 's/ZSH_THEME=.*/ZSH_THEME=spaceship/' /root/.zshrc; \
    sed -i 's/# COMPLETION_WAITING_DOTS="true"/COMPLETION_WAITING_DOTS="true"/' /root/.zshrc; \
    sed -i 's/# CASE_SENSITIVE="true"/CASE_SENSITIVE="true"/' /root/.zshrc; \
    sed -i "s/# DISABLE_AUTO_UPDATE=\"true\"/DISABLE_AUTO_UPDATE=\"true\"\\nDISABLE_UPDATE_PROMPT=\"true\"/" /root/.zshrc; \
    sed -i 's/^plugins=(/plugins=(helm kubectl /' /root/.zshrc; \
    echo 'source /google-cloud-sdk/completion.zsh.inc' >> /root/.zshrc;

# Copy scripts into image
COPY bin/activate-service-account /usr/local/bin/activate-service-account

# Fix incompatible less behavior in alpine
ENV PAGER="busybox less"

# Reset default shell
SHELL ["/bin/sh", "-c"]

# Set default workdir
WORKDIR /app

# Set default command
CMD ["gcloud"]
