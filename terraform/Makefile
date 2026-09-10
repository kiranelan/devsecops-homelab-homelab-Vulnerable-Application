.PHONY: validate infra image deploy test cleanup
validate:
	./scripts/validate.sh
infra:
	terraform -chdir=terraform init
	terraform -chdir=terraform apply
image:
	./scripts/build-and-push.sh
deploy:
	./scripts/deploy.sh
test:
	./scripts/security-test.sh
cleanup:
	./scripts/cleanup.sh
