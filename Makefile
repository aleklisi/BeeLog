.PHONY: elm_test e2e_test all_test build

elm_test:
	cd frontend && elm-test

e2e_test:
	npx playwright test

all_test: elm_test e2e_test

build:
	npm run build
