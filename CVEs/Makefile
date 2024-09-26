.PHONY: scan scan-parallel patch download-deps kustomize-build-all gen-image-list trivy-download-db scan-vulns patch-vulns

KFD_VERSIONS := $(shell find . -type d -maxdepth 1 -mindepth 1 | cut -d/ -f2 | sort )

all: scan-parallel patch

scan:
	@for version in $(KFD_VERSIONS); do \
		$(MAKE) download-deps KFD_VERSION=$$version; \
		$(MAKE) kustomize-build-all KFD_VERSION=$$version; \
		$(MAKE) gen-image-list KFD_VERSION=$$version; \
		$(MAKE) scan-vulns KFD_VERSION=$$version; \
	done;

scan-parallel:
	@for version in $(KFD_VERSIONS); do \
		( \
			$(MAKE) download-deps KFD_VERSION=$$version; \
			$(MAKE) kustomize-build-all KFD_VERSION=$$version; \
			$(MAKE) gen-image-list KFD_VERSION=$$version; \
			$(MAKE) scan-vulns KFD_VERSION=$$version; \
		) & \
	done; \
	wait

patch:
	@for version in $(KFD_VERSIONS); do \
  		$(MAKE) patch-vulns KFD_VERSION=$$version; \
	done

download-deps:
	furyctl -c $(KFD_VERSION)/furyctl.yaml -o $(KFD_VERSION) download dependencies

kustomize-build-all:
	# to remove KFD unused cluster-autoscaler images
	KFD_VERSION=$(KFD_VERSION)
	echo "" > $(KFD_VERSION)/built.yaml
	for kustomize in `find $(KFD_VERSION)/.furyctl/sighup/vendor/modules \
		\( -name "kustomization.y*ml" \) \
	  	-not -path "*cluster-autoscaler/*/kustomization.yaml" \
		-and -not -path "*examples*" \
		-or -path "*/cluster-autoscaler/$${KFD_VERSION%.*}*/kustomization.yaml"`; do \
			`find $(KFD_VERSION)/.furyctl/bin -name kustomize -type f` build `dirname $$kustomize` >> $(KFD_VERSION)/built.yaml; \
	done

gen-image-list:
	awk '$$0 ~ /registry.sighup.io/ {if($$1 == "image:"){print $$2}}' $(KFD_VERSION)/built.yaml | sort -u > $(KFD_VERSION)/images.tmp.txt  #match image:
	awk '$$0 ~ /registry.sighup.io/ {if($$2 == "image:"){print $$3}}' $(KFD_VERSION)/built.yaml| sort -u >> $(KFD_VERSION)/images.tmp.txt  #match - image:
	awk -F= '$$2 ~ /registry.sighup.io/ {print $$2}' $(KFD_VERSION)/built.yaml | sort -u >> $(KFD_VERSION)/images.tmp.txt 				 #match --ARG=IMAGE
	awk '$$0 ~ /registry.sighup.io/ {if($$1 == "repository:"){repository=$$2;getline;tag=$$2; print repository":"tag}}' $(KFD_VERSION)/built.yaml | sort -u >> $(KFD_VERSION)/images.tmp.txt #match image.repository+image.tag

	sort -u $(KFD_VERSION)/images.tmp.txt -o $(KFD_VERSION)/images.txt && rm $(KFD_VERSION)/images.tmp.txt

trivy-download-db:
	trivy image --download-db-only --db-repository registry.sighup.io/fury-secured/aquasecurity/trivy-db:2
	trivy image --download-java-db-only --java-db-repository registry.sighup.io/fury-secured/aquasecurity/trivy-java-db:1

scan-vulns:
	../scripts/scan_vuln.sh $(KFD_VERSION)

patch-vulns:
	../scripts/patch_images_with_copacetic.sh $(KFD_VERSION)


