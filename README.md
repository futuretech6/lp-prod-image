# lp-prod-image

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

- Add `-DCMAKE_CXX_COMPILER=/opt/rh/devtoolset-7/root/usr/bin/g++` as a cmake argument.
- Run `find /path/to/generic -name "sourcegen" -type d | xargs rm -rf` to clean up the generated protobuf files if errors occur.
