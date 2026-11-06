.PHONY: elm_test e2e_test all_test build deploy

elm_test:
	cd frontend && elm-test

e2e_test:
	npx playwright test

all_test: elm_test e2e_test

build:
	npm run build

deploy: all_test build
	npx firebase deploy

