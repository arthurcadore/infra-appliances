.PHONY: create_networks remove_networks install

NET_INFRA_FRONTEND_NAME = infra_frontend
NET_INFRA_BACKEND_NAME = infra_backend
NET_INFRA_FRONTEND_SUBNET = 172.16.238.0/24
NET_INFRA_BACKEND_SUBNET = 172.16.239.0/24

create_networks:
	@echo "Criando a rede $(NET_INFRA_FRONTEND_NAME)"
	docker network create \
		--driver bridge \
		--subnet $(NET_INFRA_FRONTEND_SUBNET) \
		$(NET_INFRA_FRONTEND_NAME)

	@echo "Criando a rede $(NET_INFRA_BACKEND_NAME)"
	docker network create \
		--driver bridge \
		--subnet $(NET_INFRA_BACKEND_SUBNET) \
		$(NET_INFRA_BACKEND_NAME)

remove_networks:
	@echo "Removendo a rede $(NET_INFRA_FRONTEND_NAME)"
	docker network rm $(NET_INFRA_FRONTEND_NAME)

	@echo "Removendo a rede $(NET_INFRA_BACKEND_NAME)"
	docker network rm $(NET_INFRA_BACKEND_NAME)

install-docker:
	@echo "Instalando o Docker e Docker Compose"
	$(MAKE) -C ./scripts

deploy-services:
	@echo "Selecione os serviços para fazer o deploy:"
	@echo "1 - Grafana"
	@echo "2 - Zabbix"
	@echo "Escolha uma ou mais opções separadas por espaço (ex: 1 2): "
	@read -r choice; \
	for ch in $$choice; do \
		if [ $$ch -eq 1 ]; then \
			echo "Fazendo deploy do Grafana..."; \
			$(MAKE) -C ./grafana; \
		elif [ $$ch -eq 2 ]; then \
			echo "Fazendo deploy do Zabbix..."; \
			$(MAKE) -C ./zabbix; \
		else \
			echo "Opção $$ch inválida"; \
		fi \
	done

remove-services:
	@echo "Selecione os serviços para remover:"
	@echo "1 - Grafana"
	@echo "2 - Zabbix"
	@echo "Escolha uma ou mais opções separadas por espaço (ex: 1 2): "
	@read -r choice; \
	for ch in $$choice; do \
		if [ $$ch -eq 1 ]; then \
			echo "Removendo Grafana..."; \
			$(MAKE) -C ./grafana clean; \
		elif [ $$ch -eq 2 ]; then \
			echo "Removendo Zabbix..."; \
			$(MAKE) -C ./zabbix clean; \
		else \
			echo "Opção $$ch inválida"; \
		fi \
	done