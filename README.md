# Fury Container Image Sync

![Push and Pull](https://marli.us/wp-content/uploads/2020/08/Mental-models.png)

This is a simple mechanism that pulls and pushes container images based on a configuration file (`yaml`).

The main goal of this project is to be independent of third parties repositories like `dockerhub`, `quay`, `gcr.io`
and so on.

Fury Distribution is the first SIGHUP product being benefit from this image sync automation.

## Configuration file

The configuration file: `images.yml` has to have a root attribute: `images`. Its value is an array of objects:

```yaml
  - name: # Simple description of the image
    source: # Source image. Where to pull the image
    destination: # Destination image. Where to push the image
```

Example `images.yml`:

```yaml
images:
  - name: Alpine 3
    source: docker.io/library/alpine:3
    destination: reg.sighup.io/sighupio/fury/alpine:3
```

## Execution

This automation runs once a day: `"0 2 * * *"` and every time someone pushes to the `main` branch.

## GitHub Action

Why does it run on GitHub action? It is free and it uses a different IP address than the SIGHUP drone instance
*(witch hits the dockerhub rate limit frequently)*
