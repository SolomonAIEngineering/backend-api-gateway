OUTPUT_FILE_NAME_PROD=config/krakend-flexible-config.compiled.prod.json
OUTPUT_FILE_NAME_STAGING=config/krakend-flexible-config.compiled.staging.json
PATCH_VERSION?=$(shell grep 'VERSION' pkg/version/version.go | awk -F'[".]' '{ printf "%s.%s.%d", $$2, $$3, $$4+1 }')
MINOR_VERSION?=$(shell grep 'VERSION' pkg/version/version.go | awk -F'[".]' '{ printf "%s.%d.0", $$2, $$3+1 }')
MAJOR_VERSION?=$(shell grep 'VERSION' pkg/version/version.go | awk -F'[".]' '{ printf "%d.0.0", $$2+1 }')
VERSION?=$(shell grep 'VERSION' pkg/version/version.go | awk -F'[".]' '{ printf "%s.%s.%s", $$2, $$3, $$4 }')
AUTH_DOMAIN_PROD=solomon-ai.us.auth0.com
AUTH_AUDIENCE_PROD=https://solomon-ai.us.auth0.com/api/v2/
AUTH_DOMAIN_STAGING=dev-26i1fsf2m1n6hqk1.us.auth0.com
AUTH_AUDIENCE_STAGING=https://dev-26i1fsf2m1n6hqk1.us.auth0.com/api/v2/
PROD_ENV=prod
STAGING_ENV=staging

tell:
	@echo Next Major Version: $(MAJOR_VERSION)
	@echo Next Minor Version: $(MINOR_VERSION)
	@echo Next Patch Version: $(PATCH_VERSION)


# Define a function to update version
define update-version
	@next="$(1)"; \
	current="$(VERSION)"; \
	echo "version-set: current: $$current, next: $$next"; \
	FILES="pkg/version/version.go \
	charts/api-gateway/values.yaml \
	charts/api-gateway/values.production.yaml \
	charts/api-gateway/values.staging.yaml \
	charts/api-gateway/Chart.yaml \
	kustomize/base/deployment.yaml \
	kustomize/overlays/production/patch-deployment.yaml \
	kustomize/overlays/staging/patch-deployment.yaml"; \
	for file in $$FILES; do \
		sed -i '' "s/$$current/$$next/g" $$file; \
	done; \
	echo "Version $$next set in code, deployment, chart and kustomize"; \
	make sync-kustomize
endef

minor-version-set: 
	$(call update-version,$(MINOR_VERSION))

major-version-set: 
	$(call update-version,$(MAJOR_VERSION))

patch-version-set:
	$(call update-version,$(PATCH_VERSION))
	
release-minor-version:  
	gh auth login
	echo "Releasing $(MINOR_VERSION)"
	git checkout -b release-$(MINOR_VERSION)
	make minor-version-set
	git add .
	git commit -m "bumping version from $(VERSION) to $(MINOR_VERSION)"
	git tag $(MINOR_VERSION)
	git push --set-upstream origin release-$(MINOR_VERSION)
	git push origin $(MINOR_VERSION)
	gh pr create -B main -H release$(MINOR_VERSION) --title "Merge release$(MINOR_VERSION) into main" --body 'Created by Github action'

release-major-version: 
	gh auth login 
	echo "Releasing $(MAJOR_VERSION)"
	git checkout -b release-$(MAJOR_VERSION)
	make major-version-set 
	git add .
	git commit -m "bumping version from $(VERSION) to $(MAJOR_VERSION)"
	git tag $(MAJOR_VERSION)
	git push --set-upstream origin release-$(MAJOR_VERSION)
	git push origin $(MAJOR_VERSION)
	gh pr create -B main -H release$(MAJOR_VERSION) --title "Merge release$(MAJOR_VERSION) into main" --body 'Created by Github action'

release-patch-version: 
	gh auth login
	echo "Releasing $(PATCH_VERSION)"
	git checkout -b release-$(PATCH_VERSION)
	make patch-version-set
	git add .
	git commit -m "bumping version from $(VERSION) to $(PATCH_VERSION)"
	git tag $(PATCH_VERSION)
	git push --set-upstream origin release-$(PATCH_VERSION)
	git push origin $(PATCH_VERSION)
	gh pr create -B main -H release$(PATCH_VERSION) --title "Merge release$(PATCH_VERSION) into main" --body 'Created by Github action'

validate:
	krakend check --config krakend.json -ddd -t
	cat krakend.json | jq >> output.json
	mv output.json krakend.json

lint:
	helm lint ./charts/api-gateway

start-local:
	krakend run -c krakend.json -d

compose-up:
	docker-compose up

compose-up-d:
	docker-compose up -d

compose-down:
	docker-compose down

clean: ## Clean all Docker Containers and Volumes
	docker-compose down --rmi local --remove-orphans -v
	docker-compose rm -f -v

update-chart:
	cp krakend.json ./charts/api-gateway

start-minikube:
	minikube start --memory 8192 --cpus 2

dev: start-minikube
	skaffold dev

deploy-minikube:
	eval $(minikube docker-env)
	docker build -t feelguuds/gateway:latest .
	helm upgrade --install api-gateway ./charts/api-gateway
	minikube dashboard

build:
	docker build -t feelguuds/gateway:latest .

run: build
	docker run -p 8081:80 feelguuds/gateway:latest

deploy:
	./deploy/deploy.sh

lint-gateway-configs:
	krakend check -tlc krakend.json

update-kustomize:
	./scripts/sync-kustomize.sh

validate-manifests:
	./scripts/validate.sh

gen-prod: 
	FC_ENABLE=1 \
	FC_SETTINGS="config/settings" \
	FC_PARTIALS="config/partials/$(PROD_ENV)" \
	FC_TEMPLATES="config/templates" \
	FC_OUT=$(OUTPUT_FILE_NAME_PROD) \
	AUTH_DOMAIN=solomon-ai.us.auth0.com \
	NUM_PODS=1 \
	AUTH_AUDIENCE=https://solomon-ai.us.auth0.com/api/v2/ \
	krakend check -t -ddd -c "config/krakend.tmpl"

gen-staging: 
	FC_ENABLE=1 \
	FC_SETTINGS="config/settings" \
	FC_PARTIALS="config/partials/$(STAGING_ENV)" \
	FC_TEMPLATES="config/templates" \
	FC_OUT=$(OUTPUT_FILE_NAME_STAGING) \
	AUTH_DOMAIN=solomon-ai.us.auth0.com \
	NUM_PODS=1 \
	AUTH_AUDIENCE=https://solomon-ai.us.auth0.com/api/v2/ \
	krakend check -t -ddd -c "config/krakend.tmpl"

lint-output-prod:
	krakend check -tlc $(OUTPUT_FILE_NAME_PROD)

lint-output-staging:
	krakend check -tlc $(OUTPUT_FILE_NAME_STAGING)

prettiefy-prod:
	cat $(OUTPUT_FILE_NAME_PROD) | jq >> krakend.compiled.json
	mv krakend.compiled.json krakend.$(PROD_ENV).json
	rm $(OUTPUT_FILE_NAME_PROD)

prettiefy-staging:
	cat $(OUTPUT_FILE_NAME_STAGING) | jq >> krakend.compiled.json
	mv krakend.compiled.json krakend.$(STAGING_ENV).json
	rm $(OUTPUT_FILE_NAME_STAGING)

audit-staging:
	krakend audit -c krakend.$(STAGING_ENV).json 

audit-prod:
	krakend audit -c krakend.$(PROD_ENV).json 

autogen-prod: gen-prod lint-output-prod prettiefy-prod
autogen-staging: gen-staging lint-output-staging prettiefy-staging
swagger:
	rm api.swagger.$(PROD_ENV).json api.swagger.$(STAGING_ENV).json || true
	cd ./postman-generator && \
		go build ./cmd/krakend-postman/main.go && \
		 ./main -c ../krakend.$(PROD_ENV).json >> ../api.swagger.$(PROD_ENV).json && \
		 	./main -c ../krakend.$(STAGING_ENV).json >> ../api.swagger.$(STAGING_ENV).json

build-docs:
	cd docs && yarn install && yarn generate

precommit: autogen-prod autogen-staging swagger build-docs  update-kustomize validate-manifests audit-staging audit-prod

sync-kustomize:
	./scripts/sync-kustomize.sh

release:
	./scripts/release.sh