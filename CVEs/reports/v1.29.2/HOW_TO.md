# How to generate CVE reports for a distro version

This guide explains how to generate a new report (in MarkDown) from a distribution version.

Requirements:

* `trivy` command line installed
* `jq` command line installed
* `grep` (GNU variation), if on MacOS, install it with `brew install grep`, and the Makefile will use `ggrep`

Steps

1) Create a new `furyctl.yaml` file with the correct distribution version (everything can be disabled, we only need to download dependencies)
2) Execute `make download-deps` 
3) Create a kustomization.yaml file with all the katalog bases that are used in the defined distribution version
4) Execute `make gen-image-list`, this command will output an images.txt file with all the images found in the build kustomize manifest.
5) Fix the images.txt file and fill tags that are note present (all the images inside CRs have tags under different keys, so grep is not able to get the versions)
6) Execute `make scan-vulns`, this script will output a `README.md` file in the current directory with a table with all the CRITICAL CVEs
7) Check the `README.md` and commit the directory