HELM != helm

clean:
	rm templates/config/configmap.yaml

gen-expected:
	${HELM} dependency update tests/chart
	${HELM} template --namespace=default testwithveryveryverylongreleasename tests/chart > tests/expected.yaml
	sed -i 's/[[:blank:]]\+$$//g'  tests/expected.yaml

.PHONY gen-configmap:
gen-configmap: templates/config/configmap.yaml


templates/config/configmap.yaml:
	./scripts/createConfigMap.sh
