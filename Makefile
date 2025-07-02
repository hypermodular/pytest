.PHONY: help build up down logs clean test restart

# Variables
DOCKER_COMPOSE=docker-compose

# Help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

up: ## Start all services in detached mode
	$(DOCKER_COMPOSE) up -d

down: ## Stop and remove all containers
	$(DOCKER_COMPOSE) down

restart: down up ## Restart all services

logs: ## View logs from all services
	$(DOCKER_COMPOSE) logs -f

##@ Testing

test: ## Run DNS and service tests
	chmod +x tests/test_dns.sh
	./tests/test_dns.sh

##@ Maintenance

clean: down ## Remove all unused containers, networks, and images
	docker system prune -f

docker-clean: ## Remove all stopped containers and unused images
	docker container prune -f
	docker image prune -f

##@ Debugging

shell: ## Open a shell in the test client container
	$(DOCKER_COMPOSE) exec test-client sh

status: ## Show status of containers
	$(DOCKER_COMPOSE) ps

##@ Web Access

web: ## Open web interface in default browser
	xdg-open http://localhost:8081 || open http://localhost:8081

reload-dns: ## Force reload of DNS configuration
	$(DOCKER_COMPOSE) kill -s SIGHUP $(SERVICE_NAME)

check-dns: ## Check DNS resolution
	@echo "Testing DNS resolution..."
	@docker run --rm --dns=172.20.0.2 alpine nslookup example.local || (echo "DNS resolution failed"; exit 1)

##@ Documentation

docs: ## Generate documentation
	@echo "Documentation can be viewed in README.md"

##@ Helpers

version: ## Show Docker and Docker Compose versions
	@echo "Docker:"
	@docker --version
	@echo "\nDocker Compose:"
	@docker-compose --version

.DEFAULT_GOAL := help
