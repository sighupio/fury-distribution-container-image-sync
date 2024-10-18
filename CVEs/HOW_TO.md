# How to generate CVE reports for a distro version

This guide explains how to generate a new report (in MarkDown) for a version of the distribution.

## Requirements

* `trivy` command line installed
* `jq` command line installed
* `awk` command line installed

## Steps

### Scanning for CVEs

#### Scan a single KFD Version

1) Create a new folder with the name of the version of KFD and create a new `furyctl.yaml` file with cluster name `sighup` and the same distribution version with kind KFDDistribution (everything can be disabled, we only need to download the dependencies): `furyctl create config --name sighup --version v1.X.Y --kind KFDDistribution --config v1.X.Y/furyctl.yaml`
2) Execute `make download-deps KFD_VERSION=SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE` 
3) Execute `make kustomize-build-all KFD_VERSION=SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE` 
4) Execute `make trivy-download-db`
5) Execute `make generate-image-list-from-manifests KFD_VERSION=SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE`, this command will output an `SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE/images.txt` file with all the images found in the build kustomize manifest. 
6) Execute `make scan-vulns KFD_VERSION=SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE`, this script will output a `SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE/CVEs.md` file in the current directory with a table with all the CRITICAL CVEs 
7) Check the `SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE/CVEs.md`.

#### Scan all KFD versions

1) Execute `make trivy-download-db`
2) Execute `make scan-pre-patch`
3) Check the `FURY-CVEs.md` file in each version directory

### Patching CVEs

By default the patching phase will not push the images on the registry. To push images use `make patch DRY_RUN=0 [...]`

#### Patching a single KFD Version

1) Create a new folder with the name of the version of KFD and create a new `furyctl.yaml` file with cluster name `sighup` and the same distribution version with kind KFDDistribution (everything can be disabled, we only need to download the dependencies): `furyctl create config --name sighup --version v1.X.Y --kind KFDDistribution --config v1.X.Y/furyctl.yaml`
2) Execute `make trivy-download-db`
3) Execute `make scan-pre-patch KFD_VERSIONS=SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE` 
4) Execute `make patch PATCH_FILE_IMAGE_LIST_TO_PATCHING=SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE/images.txt`
5) Check the `SOME_VALID_KFD_VERSION_WITH_A_FURYCTLYAML_INSIDE/PATCHED.md`.

#### Patching all KFD versions

1) Execute `make trivy-download-db`
2) Execute `make scan-pre-patch`
2) Execute `make concat-multiple-kfd-images-list`
2) Execute `make patch`
3) Check the `PATCHED.md` file in each version directory