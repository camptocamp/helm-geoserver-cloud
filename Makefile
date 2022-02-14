HELM != helm

gen-expected:
	${HELM} dependency update tests/chart
	${HELM} template --namespace=default testwithveryveryverylongreleasename tests/chart > tests/expected.yaml
	sed -i 's/[[:blank:]]\+$$//g'  tests/expected.yaml
