HELM ?= helm
GEN_EXPECTED_HELM_VERSION ?= 3.11.0
LOCAL_IP ?= $(shell hostname -I | awk '{print $$1}')
YQ ?=

.PHONY: examples-clean
examples-clean:
	rm -f examples/common/charts/*.tgz
	rm -f examples/datadir/charts/*.tgz
	rm -f examples/gwcStatefulSet/charts/*.tgz
	rm -f examples/jdbc/charts/*.tgz
	rm -f examples/pgconfig-acl/charts/*.tgz
	rm -f examples/pgconfig-wms-hpa/charts/*.tgz
	${HELM} uninstall gs-cloud-common || true
	${HELM} uninstall gs-cloud-datadir || true
	${HELM} uninstall gs-cloud-statefulset || true
	${HELM} uninstall gs-cloud-jdbc || true
	${HELM} uninstall gs-cloud-pgconfig-acl || true
	${HELM} uninstall gs-cloud-pgconfig-wms-hpa || true


.PHONY: dependencies
dependencies:
	${HELM} dependency update .

.PHONY: check-gen-expected-helm
check-gen-expected-helm:
	@detected_version="$$( ${HELM} version --short 2>/dev/null | sed -E 's/^v([0-9]+\.[0-9]+\.[0-9]+).*/\1/' )"; \
	if [ "$$detected_version" != "${GEN_EXPECTED_HELM_VERSION}" ]; then \
		echo "ERROR: 'make gen-expected' must be run with Helm ${GEN_EXPECTED_HELM_VERSION}. Detected Helm version: $${detected_version:-unknown}." >&2; \
		exit 1; \
	fi

.PHONY: gen-expected
gen-expected: check-gen-expected-helm dependencies
	${HELM} dependency update examples/common
	${HELM} dependency update examples/datadir
	${HELM} dependency update examples/pgconfig-acl
	${HELM} dependency update examples/gwcStatefulSet
	${HELM} dependency update examples/pgconfig-wms-hpa
	# Generate expected manifests and normalize dynamic fields that cause spurious diffs in CI.
ifeq (${YQ},)
	# Use sed-based normalization if yq is not provided.
	${HELM} template --namespace=default gs-cloud-common examples/common \
	  | sed -E '/^\s*resourceVersion:/d; /^\s*uid:/d; /^\s*generation:/d' \
	  | sed -E '/^\s*managedFields:/,/^\s*[A-Za-z0-9\-_]+:/d' \
	  > tests/expected-common.yaml
	${HELM} template --namespace=default gs-cloud-datadir examples/datadir \
	  | sed -E '/^\s*resourceVersion:/d; /^\s*uid:/d; /^\s*generation:/d' \
	  | sed -E '/^\s*managedFields:/,/^\s*[A-Za-z0-9\-_]+:/d' \
	  > tests/expected-datadir.yaml
	${HELM} template --namespace=default gs-cloud-pgconfig-acl examples/pgconfig-acl \
	  | sed -E '/^\s*resourceVersion:/d; /^\s*uid:/d; /^\s*generation:/d' \
	  | sed -E '/^\s*managedFields:/,/^\s*[A-Za-z0-9\-_]+:/d' \
	  > tests/expected-pgconfig-acl.yaml
	${HELM} template --namespace=default gs-cloud-statefulset examples/gwcStatefulSet \
	  | sed -E '/^\s*resourceVersion:/d; /^\s*uid:/d; /^\s*generation:/d' \
	  | sed -E '/^\s*managedFields:/,/^\s*[A-Za-z0-9\-_]+:/d' \
	  > tests/expected-statefulset.yaml
	${HELM} template --namespace=default gs-cloud-pgconfig-wms-hpa examples/pgconfig-wms-hpa \
	  | sed -E '/^\s*resourceVersion:/d; /^\s*uid:/d; /^\s*generation:/d' \
	  | sed -E '/^\s*managedFields:/,/^\s*[A-Za-z0-9\-_]+:/d' \
	  > tests/expected-pgconfig-wms-hpa.yaml
else
	# If YQ is provided, use it to remove dynamic metadata in a more reliable way.
	${HELM} template --namespace=default gs-cloud-common examples/common \
	  | ${YQ} eval 'del(..metadata.managedFields) | del(..metadata.uid) | del(..metadata.resourceVersion) | del(..metadata.generation)' - \
	  > tests/expected-common.yaml
	${HELM} template --namespace=default gs-cloud-datadir examples/datadir \
	  | ${YQ} eval 'del(..metadata.managedFields) | del(..metadata.uid) | del(..metadata.resourceVersion) | del(..metadata.generation)' - \
	  > tests/expected-datadir.yaml
	${HELM} template --namespace=default gs-cloud-pgconfig-acl examples/pgconfig-acl \
	  | ${YQ} eval 'del(..metadata.managedFields) | del(..metadata.uid) | del(..metadata.resourceVersion) | del(..metadata.generation)' - \
	  > tests/expected-pgconfig-acl.yaml
	${HELM} template --namespace=default gs-cloud-statefulset examples/gwcStatefulSet \
	  | ${YQ} eval 'del(..metadata.managedFields) | del(..metadata.uid) | del(..metadata.resourceVersion) | del(..metadata.generation)' - \
	  > tests/expected-statefulset.yaml
	${HELM} template --namespace=default gs-cloud-pgconfig-wms-hpa examples/pgconfig-wms-hpa \
	  | ${YQ} eval 'del(..metadata.managedFields) | del(..metadata.uid) | del(..metadata.resourceVersion) | del(..metadata.generation)' - \
	  > tests/expected-pgconfig-wms-hpa.yaml
endif
	sed -i 's/[[:blank:]]\+$$//g'  tests/expected*.yaml

.PHONY: example-common
example-common: dependencies
	${HELM} dependency update examples/common
	${HELM} upgrade --install --set-json 'nfsserver="${LOCAL_IP}"' gs-cloud-common examples/common

.PHONY: example-datadir
example-datadir: example-common
	${HELM} dependency update examples/datadir
	${HELM} upgrade --install gs-cloud-datadir examples/datadir

.PHONY: example-statefulset
example-statefulset: example-common
	${HELM} dependency update examples/gwcStatefulSet
	${HELM} upgrade --install gs-cloud-statefulset examples/gwcStatefulSet

.PHONY: example-jdbc
example-jdbc: example-common
	${HELM} dependency update examples/jdbc
	${HELM} upgrade --install gs-cloud-jdbc examples/jdbc

.PHONY: example-common-no-nfs
example-common-no-nfs: dependencies
	${HELM} dependency update examples/common
	${HELM} upgrade --install --set-json 'nfsenabled=false' gs-cloud-common examples/common

.PHONY: example-pgconfig-acl
example-pgconfig-acl: example-common-no-nfs
	${HELM} dependency update examples/pgconfig-acl
	${HELM} upgrade --install gs-cloud-pgconfig-acl examples/pgconfig-acl

.PHONY: example-pgconfig-wms-hpa
example-pgconfig-wms-hpa: example-common-no-nfs
	${HELM} dependency update examples/pgconfig-wms-hpa
	${HELM} upgrade --install gs-cloud-pgconfig-wms-hpa examples/pgconfig-wms-hpa
