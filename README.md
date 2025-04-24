# lp-prod-image

```bash
# build
docker build \
    --build-arg https_proxy=http://127.0.0.1:17890 \
    --network=host \
    --tag lp-prod \
    .

# run
docker run --rm -it -v /path/to/repos:/workspace lp-prod
```
