FROM google/cloud-sdk:479.0.0-alpine

ARG TARGETOS
ARG TARGETARCH

ENV HELM_VERSION=3.15.1
ENV KUBE_VERSION=1.29

# Use ash with options
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# Install Google Cloud components
RUN set -eux; \
	gcloud --quiet components install \
        gke-gcloud-auth-plugin \
        kubectl \
        kustomize

# Symlink kubectl binary
RUN set -eux; \
    KUBECTL_BIN="$(command -v kubectl)"; \
    ls -l "${KUBECTL_BIN}".*; \
    rm "${KUBECTL_BIN}"; \
    ln "${KUBECTL_BIN}.${KUBE_VERSION}" "${KUBECTL_BIN}"

# Install OpenSSL
# hadolint ignore=DL3018
RUN set -eux; \
    apk add --no-cache \
        openssl;

# Install Helm
# hadolint ignore=DL3018
RUN set -eux; \
    curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz | tar -xz --strip-components=1 -C /usr/local/bin;

# Install envsubst
# hadolint ignore=DL3018
RUN set -eux; \
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

# Install bash completion
# hadolint ignore=DL3018
RUN set -xe; \
    apk add --no-cache \
        bash-completion; \
    printf "source /google-cloud-sdk/completion.bash.inc\nsource <(kustomize completion bash)\nsource <(kubectl completion bash)\nsource <(helm completion bash)\n" >> /root/.bashrc

# Copy scripts into image
COPY bin/activate-service-account /usr/local/bin/activate-service-account

# Fix incompatible less behavior in alpine
ENV PAGER="busybox less"

# Reset default shell
SHELL ["/bin/sh", "-c"]

# Set default command
CMD ["gcloud"]
