.PHONY: download-deps gen-image-list scan-vulns

GGREP := $(shell command -v ggrep)

ifeq ($(GGREP),)
  GREP := grep
else
  GREP := ggrep
endif

download-deps:
	furyctl -o $$PWD download dependencies

gen-image-list:
	kustomize build . > built.yaml 
	cat built.yaml | $(GREP) -oP 'registry\.sighup\.io[^\s]+' | sort | uniq > images.txt

scan-vulns:
	../../scripts/scan_vuln.sh