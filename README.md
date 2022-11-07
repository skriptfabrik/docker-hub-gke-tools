# Google Kubernetes Engine Tools

This image provide a toolset to interact with the Google Kubenetes
Engine.

- `envsubst` [Environment variables substitution CLI](https://www.gnu.org/software/gettext/manual/html_node/envsubst-Invocation.html)
- `gcloud` [Google Cloud SDK Client](https://cloud.google.com/sdk/gcloud/)
- `helm` [Helm CLI](https://docs.helm.sh/helm/#helm)
- `jq` [JSON processor CLI](https://stedolan.github.io/jq/)
- `kubectl` [Kubernetes CLI](https://kubernetes.io/docs/reference/kubectl/overview/)
- `kustomize` [Kustomize CLI](https://kustomize.io/)
- `zsh` [Z shell](https://www.zsh.org/), together with [oh my zsh](https://ohmyz.sh/) and [Spaceship prompt](https://spaceship-prompt.sh/)

There is also a script `activate-service-account` to simplify the
authentication with a service account.

The image provides a `zsh` including plugins for `helm` and `kubectl`.
Autocomplete will work for all these tools.

## Supported tags and respective Dockerfile links
- `skriptfabrik/gke-tools:latest`, `skriptfabrik/gke-tools:VERSION` [(Dockerfile)](https://github.com/skriptfabrik/docker-gke-tools/blob/master/Dockerfile)

&rarr; Check out [Docker Hub](https://hub.docker.com/r/skriptfabrik/gke-tools/tags/) for available tags.

## How to use this image

Start the interactive shell:

```bash
docker run \
    --rm \
    --interactive \
    --tty \
    --volume "$(pwd)":/app \
    skriptfabrik/gke-tools \
    zsh
```

Authorizing access to the Google Cloud Platform and logging in to the
Google Container Registry using docker:

```bash
docker run \
    --rm \
    --interactive \
    --tty \
    --volume ~/.config/gcloud:/root/.config/gcloud \
    skriptfabrik/gke-tools \
    gcloud auth login

docker run \
    --rm \
    --volume ~/.config/gcloud:/root/.config/gcloud \
    skriptfabrik/gke-tools \
    gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://eu.gcr.io
```

Authorizing access to the Google Cloud Platform and using the tools
within a CI:

```bash
docker run \
    --rm \
    --volume "$(pwd)":/app \
    --env GKE_SERVICE_ACCOUNT_KEY=<BASE64-ENCODED-SERVICE-ACCOUNT-JSON-DATA> \
    --env GKE_CLUSTER_NAME=<CLUSTER-NAME> \
    --env GKE_REGION=<GKE-CLUSTER-REGION> \
    --env GKE_ZONE=<GKE-CLUSTER-ZONE> \
    skriptfabrik/gke-tools \
    sh -c " \
        activate-service-account; \
        <ALL THE FANCY COMMAND LINE TOOL CALLS>
    "
```

Aa an alternative mount the service account credentials:

```bash
docker run \
    --rm \
    --volume "$(pwd)":/app \
    --volume ./service-account.json:/root/.config/gcloud-credentials/service-account.json \
    --env GKE_CLUSTER_NAME=<CLUSTER-NAME> \
    --env GKE_REGION=<GKE-CLUSTER-REGION> \
    --env GKE_ZONE=<GKE-CLUSTER-ZONE> \
    skriptfabrik/gke-tools \
    sh -c " \
        activate-service-account; \
        <ALL THE FANCY COMMAND LINE TOOL CALLS>
    "
```

### Configuration

The image can be configured by using environment variables.

| Environment | Description |
| --- | --- |
| `GKE_SERVICE_ACCOUNT_KEY` | The base64 encoded content of the Google service account key json file which is provided by Google. |
| `GKE_CLUSTER_NAME` | The name of the Kubernetes cluster. |
| `GKE_REGION`* | The region of the Kubernetes cluster. |
| `GKE_ZONE`* | The zone of the Kubernetes cluster. |

\* Either one of these environments have to be defined.
If both are defined, `GKE_REGION` will be used.

If necessary, the configuaration if all tools can be mounted as volume.

| Tool | Configuration path within the container |
| --- | --- |
| Google Cloud SDK Client | `/root/.config/gcloud` |
| Google Cloud Credentials | `/root/.config/gcloud-credentials` |
| Helm | `/root/.helm` |
| Kubernetes | `/root/.kube` |

Instead of injecting the Google Cloud Credentials, the credential file can also be set as first argument to the `activate-service-account` script.

## Quick reference
-   **Where to get help:**
[the Docker Community Forums](https://forums.docker.com),
[the Docker Community Slack](https://blog.docker.com/2016/11/introducing-docker-community-directory-docker-community-slack),
or [Stack Overflow](https://stackoverflow.com/search?tab=newest&q=docker)

-   **Where to file issues:**
[Issue Tracker](https://github.com/skriptfabrik/docker-hub-gke-tools/issues)

-   **Maintained by:**
[The skriptfabrik Team](https://github.com/skriptfabrik)

-   **Source of this description:**
[Repository README.md](https://github.com/skriptfabrik/docker-hub-gke-tools/blob/master/README.md)
