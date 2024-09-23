# How to generate CVE reports for a distro version

This guide explains how to generate a new report (in MarkDown) for a version of the distribution.

## Requirements

* `trivy` command line installed
* `jq` command line installed
* `awk` command line installed

## Steps

### Scan single KDF Version

1) Create a new folder with the name of the version of KFD and create a new `furyctl.yaml` file with cluster name `sighup` and the same distribution version (everything can be disabled, we only need to download dependencies)
2) Execute `make download-deps KFD_VERSION=SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE` 
3) Execute `make gen-image-list KFD_VERSION=SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE`, this command will output an `SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE/images.txt` file with all the images found in the build kustomize manifest.
4) Execute `make scan-vulns KFD_VERSION=SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE`, this script will output a `SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE/README.md` file in the current directory with a table with all the CRITICAL CVEs
5) Check the `SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE/README.md` and commit the directory

### Scan all KFD versions

1) Execute `make all`
2) Check the `README.md` files in each version directory and commit them.

