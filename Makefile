HELM != helm

gen-expected:
	${HELM} dependency update tests/chart
	${HELM} template --namespace=default test tests/chart > tests/expected.yaml
	sed -i 's/[[:blank:]]\+$$//g'  tests/expected.yaml
