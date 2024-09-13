# KFD v1.29.3

Updated to 2024-09-16

## CVEs

| Image | Severity | CVE | Reason | Package Affected | Status | Fixed in versions |
| --- | --- | --- | --- | --- | --- | --- |
| registry.sighup.io/fury/aws-ec2/aws-node-termination-handler:v1.20.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.20.5 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/bitnami/kubectl:1.28.5 | CRITICAL | CVE-2024-32002 | git: Recursive clones RCE | git 1:2.30.2-1+deb11u2 | fixed | 1:2.30.2-1+deb11u3 |
| registry.sighup.io/fury/bitnami/kubectl:1.28.5 | CRITICAL | CVE-2024-32002 | git: Recursive clones RCE | git-man 1:2.30.2-1+deb11u2 | fixed | 1:2.30.2-1+deb11u3 |
| registry.sighup.io/fury/bitnami/kubectl:1.28.5 | CRITICAL | CVE-2023-23914 | curl: HSTS ignored on multiple requests | libcurl3-gnutls 7.74.0-1.3+deb11u11 | will_not_fix |  |
| registry.sighup.io/fury/bitnami/kubectl:1.28.5 | CRITICAL | CVE-2019-8457 | sqlite: heap out-of-bound read in function rtreenode() | libdb5.3 5.3.28+dfsg1-0.8 | will_not_fix |  |
| registry.sighup.io/fury/bitnami/kubectl:1.28.5 | CRITICAL | CVE-2024-45490 | libexpat: Negative Length Parsing Vulnerability in libexpat | libexpat1 2.2.10-2+deb11u5 | affected |  |
| registry.sighup.io/fury/bitnami/kubectl:1.28.5 | CRITICAL | CVE-2024-45491 | libexpat: Integer Overflow or Wraparound | libexpat1 2.2.10-2+deb11u5 | affected |  |
| registry.sighup.io/fury/bitnami/kubectl:1.28.5 | CRITICAL | CVE-2024-45492 | libexpat: integer overflow | libexpat1 2.2.10-2+deb11u5 | affected |  |
| registry.sighup.io/fury/bitnami/kubectl:1.28.5 | CRITICAL | CVE-2024-37371 | krb5: GSS message token handling | libgssapi-krb5-2 1.18.3-6+deb11u4 | fixed | 1.18.3-6+deb11u5 |
| registry.sighup.io/fury/bitnami/kubectl:1.28.5 | CRITICAL | CVE-2024-37371 | krb5: GSS message token handling | libk5crypto3 1.18.3-6+deb11u4 | fixed | 1.18.3-6+deb11u5 |
| registry.sighup.io/fury/bitnami/kubectl:1.28.5 | CRITICAL | CVE-2024-37371 | krb5: GSS message token handling | libkrb5-3 1.18.3-6+deb11u4 | fixed | 1.18.3-6+deb11u5 |
| registry.sighup.io/fury/bitnami/kubectl:1.28.5 | CRITICAL | CVE-2024-37371 | krb5: GSS message token handling | libkrb5support0 1.18.3-6+deb11u4 | fixed | 1.18.3-6+deb11u5 |
| registry.sighup.io/fury/bitnami/kubectl:1.28.5 | CRITICAL | CVE-2023-45853 | zlib: integer overflow and resultant heap-based buffer overflow in zipOpenNewFileInZip4_6 | zlib1g 1:1.2.11.dfsg-2+deb11u2 | will_not_fix |  |
| registry.sighup.io/fury/calico/cni:v3.27.3 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.8 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/calico/cni:v3.27.3 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.8 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/calico/cni:v3.27.3 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.8 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/calico/cni:v3.27.3 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.8 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/calico/cni:v3.27.3 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.8 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/calico/cni:v3.27.3 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.8 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/calico/cni:v3.27.3 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.8 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/calico/cni:v3.27.3 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.8 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/calico/cni:v3.27.3 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.8 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/calico/kube-controllers:v3.27.3 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.8 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/calico/kube-controllers:v3.27.3 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.8 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/cilium/operator-generic:v1.15.2 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.8 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/cilium/operator-generic:v1.15.2 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.8 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/enix/x509-certificate-exporter:3.12.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.5 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/fluent/fluent-bit:2.1.8 | CRITICAL | CVE-2024-37371 | krb5: GSS message token handling | libgssapi-krb5-2 1.18.3-6+deb11u3 | fixed | 1.18.3-6+deb11u5 |
| registry.sighup.io/fury/fluent/fluent-bit:2.1.8 | CRITICAL | CVE-2024-37371 | krb5: GSS message token handling | libk5crypto3 1.18.3-6+deb11u3 | fixed | 1.18.3-6+deb11u5 |
| registry.sighup.io/fury/fluent/fluent-bit:2.1.8 | CRITICAL | CVE-2024-37371 | krb5: GSS message token handling | libkrb5-3 1.18.3-6+deb11u3 | fixed | 1.18.3-6+deb11u5 |
| registry.sighup.io/fury/fluent/fluent-bit:2.1.8 | CRITICAL | CVE-2024-37371 | krb5: GSS message token handling | libkrb5support0 1.18.3-6+deb11u3 | fixed | 1.18.3-6+deb11u5 |
| registry.sighup.io/fury/fluent/fluent-bit:2.1.8 | CRITICAL | CVE-2023-45853 | zlib: integer overflow and resultant heap-based buffer overflow in zipOpenNewFileInZip4_6 | zlib1g 1:1.2.11.dfsg-2+deb11u2 | will_not_fix |  |
| registry.sighup.io/fury/gangplank:1.1.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.22.1 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/gatekeeper-policy-manager:v1.0.10 | CRITICAL | CVE-2024-45490 | libexpat: Negative Length Parsing Vulnerability in libexpat | libexpat1 2.5.0-1 | affected |  |
| registry.sighup.io/fury/gatekeeper-policy-manager:v1.0.10 | CRITICAL | CVE-2024-45491 | libexpat: Integer Overflow or Wraparound | libexpat1 2.5.0-1 | affected |  |
| registry.sighup.io/fury/gatekeeper-policy-manager:v1.0.10 | CRITICAL | CVE-2024-45492 | libexpat: integer overflow | libexpat1 2.5.0-1 | affected |  |
| registry.sighup.io/fury/gatekeeper-policy-manager:v1.0.10 | CRITICAL | CVE-2024-37371 | krb5: GSS message token handling | libgssapi-krb5-2 1.20.1-2+deb12u1 | fixed | 1.20.1-2+deb12u2 |
| registry.sighup.io/fury/gatekeeper-policy-manager:v1.0.10 | CRITICAL | CVE-2024-37371 | krb5: GSS message token handling | libk5crypto3 1.20.1-2+deb12u1 | fixed | 1.20.1-2+deb12u2 |
| registry.sighup.io/fury/gatekeeper-policy-manager:v1.0.10 | CRITICAL | CVE-2024-37371 | krb5: GSS message token handling | libkrb5-3 1.20.1-2+deb12u1 | fixed | 1.20.1-2+deb12u2 |
| registry.sighup.io/fury/gatekeeper-policy-manager:v1.0.10 | CRITICAL | CVE-2024-37371 | krb5: GSS message token handling | libkrb5support0 1.20.1-2+deb12u1 | fixed | 1.20.1-2+deb12u2 |
| registry.sighup.io/fury/gatekeeper-policy-manager:v1.0.10 | CRITICAL | CVE-2023-45853 | zlib: integer overflow and resultant heap-based buffer overflow in zipOpenNewFileInZip4_6 | zlib1g 1:1.2.13.dfsg-1 | will_not_fix |  |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-38545 | curl: heap based buffer overflow in the SOCKS5 proxy handshake | curl 8.1.2-r0 | fixed | 8.4.0-r0 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-38545 | curl: heap based buffer overflow in the SOCKS5 proxy handshake | libcurl 8.1.2-r0 | fixed | 8.4.0-r0 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-49569 | go-git: Maliciously crafted Git server replies can lead to path traversal and RCE on go-git clients | github.com/go-git/go-git/v5 v5.4.2 | fixed | 5.11.0 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.20.4 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.20.4 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.20.4 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-24538 | golang: html/template: backticks not treated as string delimiters | stdlib 1.17.13 | fixed | 1.19.8, 1.20.3 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-24540 | golang: html/template: improper handling of JavaScript whitespace | stdlib 1.17.13 | fixed | 1.19.9, 1.20.4 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.17.13 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-24538 | golang: html/template: backticks not treated as string delimiters | stdlib 1.17.13 | fixed | 1.19.8, 1.20.3 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-24540 | golang: html/template: improper handling of JavaScript whitespace | stdlib 1.17.13 | fixed | 1.19.9, 1.20.4 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.17.13 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-24538 | golang: html/template: backticks not treated as string delimiters | stdlib 1.17.13 | fixed | 1.19.8, 1.20.3 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-24540 | golang: html/template: improper handling of JavaScript whitespace | stdlib 1.17.13 | fixed | 1.19.9, 1.20.4 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.17.13 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-24538 | golang: html/template: backticks not treated as string delimiters | stdlib 1.17.13 | fixed | 1.19.8, 1.20.3 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-24540 | golang: html/template: improper handling of JavaScript whitespace | stdlib 1.17.13 | fixed | 1.19.9, 1.20.4 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.17.13 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-24538 | golang: html/template: backticks not treated as string delimiters | stdlib 1.17.13 | fixed | 1.19.8, 1.20.3 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-24540 | golang: html/template: improper handling of JavaScript whitespace | stdlib 1.17.13 | fixed | 1.19.9, 1.20.4 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.17.13 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-24538 | golang: html/template: backticks not treated as string delimiters | stdlib 1.17.13 | fixed | 1.19.8, 1.20.3 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2023-24540 | golang: html/template: improper handling of JavaScript whitespace | stdlib 1.17.13 | fixed | 1.19.9, 1.20.4 |
| registry.sighup.io/fury/grafana/grafana:9.5.5 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.17.13 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v1.6 | CRITICAL | CVE-2022-32207 | curl: Unpreserved file permissions | curl 7.80.0-r1 | fixed | 7.80.0-r2 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v1.6 | CRITICAL | CVE-2022-32221 | curl: POST following PUT confusion | curl 7.80.0-r1 | fixed | 7.80.0-r4 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v1.6 | CRITICAL | CVE-2023-23914 | curl: HSTS ignored on multiple requests | curl 7.80.0-r1 | fixed | 7.80.0-r6 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v1.6 | CRITICAL | CVE-2023-38545 | curl: heap based buffer overflow in the SOCKS5 proxy handshake | curl 7.80.0-r1 | fixed | 8.4.0-r0 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v1.6 | CRITICAL | CVE-2022-32207 | curl: Unpreserved file permissions | libcurl 7.80.0-r1 | fixed | 7.80.0-r2 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v1.6 | CRITICAL | CVE-2022-32221 | curl: POST following PUT confusion | libcurl 7.80.0-r1 | fixed | 7.80.0-r4 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v1.6 | CRITICAL | CVE-2023-23914 | curl: HSTS ignored on multiple requests | libcurl 7.80.0-r1 | fixed | 7.80.0-r6 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v1.6 | CRITICAL | CVE-2023-38545 | curl: heap based buffer overflow in the SOCKS5 proxy handshake | libcurl 7.80.0-r1 | fixed | 8.4.0-r0 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v1.6 | CRITICAL | CVE-2022-37434 | zlib: heap-based buffer over-read and overflow in inflate() in inflate.c via a large gzip header extra field | zlib 1.2.12-r0 | fixed | 1.2.12-r2 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v1.6 | CRITICAL | CVE-2023-24538 | golang: html/template: backticks not treated as string delimiters | stdlib 1.18.1 | fixed | 1.19.8, 1.20.3 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v1.6 | CRITICAL | CVE-2023-24540 | golang: html/template: improper handling of JavaScript whitespace | stdlib 1.18.1 | fixed | 1.19.9, 1.20.4 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v1.6 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.18.1 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v2.0 | CRITICAL | CVE-2023-23914 | curl: HSTS ignored on multiple requests | curl 7.83.1-r4 | fixed | 7.83.1-r6 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v2.0 | CRITICAL | CVE-2023-38545 | curl: heap based buffer overflow in the SOCKS5 proxy handshake | curl 7.83.1-r4 | fixed | 8.4.0-r0 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v2.0 | CRITICAL | CVE-2023-23914 | curl: HSTS ignored on multiple requests | libcurl 7.83.1-r4 | fixed | 7.83.1-r6 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v2.0 | CRITICAL | CVE-2023-38545 | curl: heap based buffer overflow in the SOCKS5 proxy handshake | libcurl 7.83.1-r4 | fixed | 8.4.0-r0 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v2.0 | CRITICAL | CVE-2023-24538 | golang: html/template: backticks not treated as string delimiters | stdlib 1.19.3 | fixed | 1.19.8, 1.20.3 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v2.0 | CRITICAL | CVE-2023-24540 | golang: html/template: improper handling of JavaScript whitespace | stdlib 1.19.3 | fixed | 1.19.9, 1.20.4 |
| registry.sighup.io/fury/groundnuty/k8s-wait-for:v2.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.19.3 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/jimmidyson/configmap-reload:v0.5.0 | CRITICAL | CVE-2022-23806 | golang: crypto/elliptic: IsOnCurve returns true for invalid field elements | stdlib 1.15.7 | fixed | 1.16.14, 1.17.7 |
| registry.sighup.io/fury/jimmidyson/configmap-reload:v0.5.0 | CRITICAL | CVE-2023-24538 | golang: html/template: backticks not treated as string delimiters | stdlib 1.15.7 | fixed | 1.19.8, 1.20.3 |
| registry.sighup.io/fury/jimmidyson/configmap-reload:v0.5.0 | CRITICAL | CVE-2023-24540 | golang: html/template: improper handling of JavaScript whitespace | stdlib 1.15.7 | fixed | 1.19.9, 1.20.4 |
| registry.sighup.io/fury/jimmidyson/configmap-reload:v0.5.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.15.7 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/kiwigrid/k8s-sidecar:1.19.2 | CRITICAL | CVE-2022-37434 | zlib: heap-based buffer over-read and overflow in inflate() in inflate.c via a large gzip header extra field | zlib 1.2.12-r1 | fixed | 1.2.12-r2 |
| registry.sighup.io/fury/memcached:1.5.17-alpine | CRITICAL | CVE-2021-36159 | libfetch: an out of boundary read while libfetch uses strtol to parse the relevant numbers into address bytes leads to information leak or crash | apk-tools 2.10.4-r2 | fixed | 2.10.7-r0 |
| registry.sighup.io/fury/nginxinc/nginx-unprivileged:1.20.2-alpine | CRITICAL | CVE-2022-32207 | curl: Unpreserved file permissions | curl 7.79.1-r1 | fixed | 7.79.1-r2 |
| registry.sighup.io/fury/nginxinc/nginx-unprivileged:1.20.2-alpine | CRITICAL | CVE-2023-23914 | curl: HSTS ignored on multiple requests | curl 7.79.1-r1 | fixed | 7.79.1-r5 |
| registry.sighup.io/fury/nginxinc/nginx-unprivileged:1.20.2-alpine | CRITICAL | CVE-2022-32207 | curl: Unpreserved file permissions | libcurl 7.79.1-r1 | fixed | 7.79.1-r2 |
| registry.sighup.io/fury/nginxinc/nginx-unprivileged:1.20.2-alpine | CRITICAL | CVE-2023-23914 | curl: HSTS ignored on multiple requests | libcurl 7.79.1-r1 | fixed | 7.79.1-r5 |
| registry.sighup.io/fury/nginxinc/nginx-unprivileged:1.20.2-alpine | CRITICAL | CVE-2022-37434 | zlib: heap-based buffer over-read and overflow in inflate() in inflate.c via a large gzip header extra field | zlib 1.2.12-r0 | fixed | 1.2.12-r2 |
| registry.sighup.io/fury/nginxinc/nginx-unprivileged:1.25-alpine | CRITICAL | CVE-2024-45490 | libexpat: Negative Length Parsing Vulnerability in libexpat | libexpat 2.6.2-r0 | fixed | 2.6.3-r0 |
| registry.sighup.io/fury/nginxinc/nginx-unprivileged:1.25-alpine | CRITICAL | CVE-2024-45491 | libexpat: Integer Overflow or Wraparound | libexpat 2.6.2-r0 | fixed | 2.6.3-r0 |
| registry.sighup.io/fury/nginxinc/nginx-unprivileged:1.25-alpine | CRITICAL | CVE-2024-45492 | libexpat: integer overflow | libexpat 2.6.2-r0 | fixed | 2.6.3-r0 |
| registry.sighup.io/fury/prometheus-operator/prometheus-config-reloader:v0.67.1 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.20.6 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/prometheus-operator/prometheus-operator:v0.67.1 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.20.6 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/prometheus/alertmanager:v0.26.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.20.7 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/prometheus/alertmanager:v0.26.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.20.7 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/prometheus/blackbox-exporter:v0.24.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.20.4 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/prometheus/node-exporter:v1.6.1 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.20.6 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/prometheus/prometheus:v2.46.0 | CRITICAL | CVE-2024-41110 | moby: Authz zero length regression | github.com/docker/docker v24.0.4+incompatible | fixed | 23.0.15, 26.1.5, 27.1.1, 25.0.6 |
| registry.sighup.io/fury/prometheus/prometheus:v2.46.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.20.6 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/prometheus/prometheus:v2.46.0 | CRITICAL | CVE-2024-41110 | moby: Authz zero length regression | github.com/docker/docker v24.0.4+incompatible | fixed | 23.0.15, 26.1.5, 27.1.1, 25.0.6 |
| registry.sighup.io/fury/prometheus/prometheus:v2.46.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.20.6 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/thanos/thanos:v0.34.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.6 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/thanos:v0.30.2 | CRITICAL | CVE-2023-24538 | golang: html/template: backticks not treated as string delimiters | stdlib 1.19.5 | fixed | 1.19.8, 1.20.3 |
| registry.sighup.io/fury/thanos:v0.30.2 | CRITICAL | CVE-2023-24540 | golang: html/template: improper handling of JavaScript whitespace | stdlib 1.19.5 | fixed | 1.19.9, 1.20.4 |
| registry.sighup.io/fury/thanos:v0.30.2 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.19.5 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/tigera/operator:v1.32.7 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.8 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/velero/velero-plugin-for-aws:v1.9.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.6 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/velero/velero-plugin-for-aws:v1.9.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.6 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/velero/velero-plugin-for-csi:v0.7.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.6 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/velero/velero-plugin-for-csi:v0.7.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.6 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/velero/velero-plugin-for-gcp:v1.9.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.6 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/velero/velero-plugin-for-gcp:v1.9.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.6 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/velero/velero-plugin-for-microsoft-azure:v1.9.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.6 | fixed | 1.21.11, 1.22.4 |
| registry.sighup.io/fury/velero/velero-plugin-for-microsoft-azure:v1.9.0 | CRITICAL | CVE-2024-24790 | golang: net/netip: Unexpected behavior from Is methods for IPv4-mapped IPv6 addresses | stdlib 1.21.6 | fixed | 1.21.11, 1.22.4 |
