HELM ?= helm
LOCAL_IP ?= $(shell hostname -I | awk '{print $$1}')

.PHONY: examples-clean
examples-clean:
	rm -f examples/common/charts/*.tgz
	rm -f examples/datadir/charts/*.tgz
	rm -f examples/gwcStatefulSet/charts/*.tgz
	rm -f examples/jdbc/charts/*.tgz
	rm -f examples/pgconfig-acl/charts/*.tgz
	${HELM} uninstall gs-cloud-common || /bin/true
	${HELM} uninstall gs-cloud-datadir || /bin/true
	${HELM} uninstall gs-cloud-statefulset || /bin/true
	${HELM} uninstall gs-cloud-jdbc || /bin/true
	${HELM} uninstall gs-cloud-pgconfig-acl || /bin/true


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
	${HELM} template --namespace=default gs-cloud-common examples/common > tests/expected-common.yaml
	${HELM} template --namespace=default gs-cloud-datadir examples/datadir > tests/expected-datadir.yaml
	${HELM} template --namespace=default gs-cloud-jdbc examples/jdbc > tests/expected-jdbc.yaml
	${HELM} template --namespace=default gs-cloud-pgconfig-acl examples/pgconfig-acl > tests/expected-pgconfig-acl.yaml
	${HELM} template --namespace=default gs-cloud-statefulset examples/gwcStatefulSet > tests/expected-statefulset.yaml
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

.PHONY: example-pgconfig-acl
example-pgconfig-acl: example-common
	${HELM} dependency update examples/pgconfig-acl
	${HELM} upgrade --install gs-cloud-pgconfig-acl examples/pgconfig-acl
