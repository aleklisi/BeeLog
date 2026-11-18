.PHONY: elm_test e2e_test test_openspec test_all all_test build deploy

elm_test:
	cd frontend && elm-test

e2e_test:
	npx playwright test

test_openspec:
	openspec validate --all --strict

test_all: elm_test e2e_test test_openspec

all_test: test_all

build:
	npm run build

deploy: all_test build
	npx firebase deploy

