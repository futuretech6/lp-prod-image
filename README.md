# lp-prod-image

## Basic Usage

```bash
# build
docker build \
    --build-arg https_proxy=http://127.0.0.1:17890 \
    --network=host \
    --tag lp-prod:centos7 \
    --file Dockerfile.centos7 \
    .

# run
docker run --rm -it -v /path/to/repos:/workspace lp-prod:centos7
```

**Notes**

- Use relative paths for the soft links in the mounted directory.
- Add `-DCMAKE_CXX_COMPILER=/opt/rh/devtoolset-7/root/usr/bin/g++` as a cmake argument.
- Run `find /path/to/generic -name "sourcegen" -type d | xargs rm -rf` to clean up the generated protobuf files if errors occur.

## Dev Container

To enable [Dev Containers](https://github.com/devcontainers/spec), add the following configuration to `.devcontainer/devcontainer.json` in your workspace:

```json
{
  "name": "lp-prod",
  "image": "lp-prod:ubuntu22",
  "userEnvProbe": "loginInteractiveShell",
  "workspaceMount": "source=${localWorkspaceFolder}/..,target=${localWorkspaceFolder}/..,type=bind,consistency=cached",
  "workspaceFolder": "${localWorkspaceFolder}",
  "containerEnv": {
    "WORKSPACE": "${localWorkspaceFolder}/.."
  },
  "runArgs": ["--entrypoint=/entrypoint.sh", "--network=host"],
  "remoteUser": "prod",
  "customizations": {
    "vscode": {
      "extensions": [
        "llvm-vs-code-extensions.vscode-clangd",
        "vadimcn.vscode-lldb"
      ]
    }
  }
}
```
