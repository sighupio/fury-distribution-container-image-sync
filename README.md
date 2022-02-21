<h1>
    <img src="https://github.com/sighupio/fury-distribution/blob/master/docs/assets/fury-epta-white.png?raw=true" align="left" width="90" style="margin-right: 15px"/>
    Kubernetes Fury Distribution - Container Image Sync
</h1>

This is a simple mechanism that pulls and pushes container images based on a configuration file (`yaml`).

The main goal for this repository is to have a central location used to sync on our public SIGHUP registry all the 
upstream images used by all the Fury modules.

Features:
- Configurable via YAML files
- Skips images if the layers between src and dest are the same using `skopeo`
- Everything is executed with two bash scripts: `sync.sh` and `single_sync.sh`

## How it works

Inside the folder `modules/` there is a subfolder for each KFD module with an `images.yml` file. 
Each `images.yml` file has to have a root attribute: `images` and its value is an array of objects:

```yaml
  - name: # Simple description of the image
    source: # Source image. Where to pull the image
    tag: # Tags to sync
      - "xxx" 
    destination: 
      - # Destination registry
```

Example `images.yml`:

```yaml
  - name: Alpine
    source: docker.io/library/alpine
    tag:
      - "3"
      - "3.12"
      - "3.13"
      - "3.14"
    destinations:
      - registry.sighup.io/fury/alpine
```

## Automated execution

This automation runs once a day: `"0 2 * * *"` and every time someone pushes to the `main` branch.