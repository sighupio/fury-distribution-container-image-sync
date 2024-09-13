.PHONY: download-deps kustomize-build-all gen-image-list scan-vulns

KFD_VERSIONS := $(shell find . -type d -maxdepth 1 -mindepth 1 | cut -d/ -f2)

all:
	@for version in $(KFD_VERSIONS); do \
		( \
			$(MAKE) download-deps KFD_VERSION=$$version; \
			$(MAKE) kustomize-build-all KFD_VERSION=$$version; \
			$(MAKE) gen-image-list KFD_VERSION=$$version; \
			$(MAKE) scan-vulns KFD_VERSION=$$version; \
		) & \
	done; \
	wait

download-deps:
	furyctl -c $(KFD_VERSION)/furyctl.yaml -o $(KFD_VERSION) download dependencies

kustomize-build-all: download-deps
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

gen-image-list: kustomize-build-all
	awk '$$0 ~ /registry.sighup.io/ {if($$1 == "image:"){print $$2}}' $(KFD_VERSION)/built.yaml | sort -u > $(KFD_VERSION)/images.tmp.txt  #match image:
	awk '$$0 ~ /registry.sighup.io/ {if($$2 == "image:"){print $$3}}' $(KFD_VERSION)/built.yaml| sort -u >> $(KFD_VERSION)/images.tmp.txt  #match - image:
	awk -F= '$$2 ~ /registry.sighup.io/ {print $$2}' $(KFD_VERSION)/built.yaml | sort -u >> $(KFD_VERSION)/images.tmp.txt 				 #match --ARG=IMAGE
	awk '$$0 ~ /registry.sighup.io/ {if($$1 == "repository:"){repository=$$2;getline;tag=$$2; print repository":"tag}}' $(KFD_VERSION)/built.yaml | sort -u >> $(KFD_VERSION)/images.tmp.txt #match image.repository+image.tag

	sort -u $(KFD_VERSION)/images.tmp.txt -o $(KFD_VERSION)/images.txt && rm $(KFD_VERSION)/images.tmp.txt

scan-vulns:
	../scripts/scan_vuln.sh $(KFD_VERSION)


