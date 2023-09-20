OUTPUT_FILE_NAME=config/krakend-flexible-config.compiled.json
PATCH_VERSION?=$(shell grep 'VERSION' pkg/version/version.go | awk -F'[".]' '{ printf "%s.%s.%d", $$2, $$3, $$4+1 }')
MINOR_VERSION?=$(shell grep 'VERSION' pkg/version/version.go | awk -F'[".]' '{ printf "%s.%d.0", $$2, $$3+1 }')
MAJOR_VERSION?=$(shell grep 'VERSION' pkg/version/version.go | awk -F'[".]' '{ printf "%d.0.0", $$2+1 }')
VERSION?=$(shell grep 'VERSION' pkg/version/version.go | awk -F'[".]' '{ printf "%s.%s.%s", $$2, $$3, $$4 }')

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
		/usr/bin/sed -i '' "s/$$current/$$next/g" $$file; \
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
	
release-minor-version:  precommit
	echo "Releasing $(MINOR_VERSION)"
	git checkout -b release-$(MINOR_VERSION)
	make minor-version-set
	git add .
	git commit -m "bumping version from $(VERSION) to $(MINOR_VERSION)"
	git tag $(MINOR_VERSION)
	git push --set-upstream origin release-$(MINOR_VERSION)
	git push origin $(MINOR_VERSION)

release-major-version: precommit
	echo "Releasing $(MAJOR_VERSION)"
	git checkout -b release-$(MAJOR_VERSION)
	make major-version-set 
	git add .
	git commit -m "bumping version from $(VERSION) to $(MAJOR_VERSION)"
	git tag $(MAJOR_VERSION)
	git push --set-upstream origin release-$(MAJOR_VERSION)
	git push origin $(MAJOR_VERSION)

release-patch-version: precommit
	echo "Releasing $(PATCH_VERSION)"
	git checkout -b release-$(PATCH_VERSION)
	make patch-version-set
	git add .
	git commit -m "bumping version from $(VERSION) to $(PATCH_VERSION)"
	git tag $(PATCH_VERSION)
	git push --set-upstream origin release-$(PATCH_VERSION)
	git push origin $(PATCH_VERSION)

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

deploy:
	./deploy/deploy.sh

lint-gateway-configs:
	krakend check -tlc krakend.json

update-kustomize:
	./scripts/sync-kustomize.sh

gen: 
	FC_ENABLE=1 FC_SETTINGS="config/settings" FC_PARTIALS="config/partials" FC_TEMPLATES="config/templates" FC_OUT=$(OUTPUT_FILE_NAME) krakend check -t -ddd -c "config/krakend.tmpl"
	make update-kustomize

lint-output:
	krakend check -tlc $(OUTPUT_FILE_NAME)

prettiefy:
	cat $(OUTPUT_FILE_NAME) | jq >> krakend.compiled.json
	mv krakend.compiled.json krakend.json
	rm $(OUTPUT_FILE_NAME)

swagger:
	rm api.swagger.json
	cd ./postman-generator && go build ./cmd/krakend-postman/main.go &&  ./main -c ../krakend.json >> ../api.swagger.json

build-docs:
	cd docs && yarn generate


validate-manifests:
	./scripts/validate.sh


autogen: gen lint-output prettiefy swagger build-docs 

precommit:  gen lint-output prettiefy swagger update-kustomize validate-manifests lint

sync-kustomize:
	./scripts/sync-kustomize.sh