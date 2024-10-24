HELM ?= helm
LOCAL_IP ?= $(shell hostname -I | awk '{print $$1}')

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

.PHONY: gen-expected
gen-expected: dependencies
	${HELM} dependency update examples/common
	${HELM} dependency update examples/datadir
	${HELM} dependency update examples/jdbc
	${HELM} dependency update examples/pgconfig-acl
	${HELM} dependency update examples/gwcStatefulSet
	${HELM} dependency update examples/pgconfig-wms-hpa
	${HELM} template --namespace=default gs-cloud-common examples/common > tests/expected-common.yaml
	${HELM} template --namespace=default gs-cloud-datadir examples/datadir > tests/expected-datadir.yaml
	${HELM} template --namespace=default gs-cloud-jdbc examples/jdbc > tests/expected-jdbc.yaml
	${HELM} template --namespace=default gs-cloud-pgconfig-acl examples/pgconfig-acl > tests/expected-pgconfig-acl.yaml
	${HELM} template --namespace=default gs-cloud-statefulset examples/gwcStatefulSet > tests/expected-statefulset.yaml
	${HELM} template --namespace=default gs-cloud-pgconfig-wms-hpa examples/pgconfig-wms-hpa > tests/expected-pgconfig-wms-hpa.yaml
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
