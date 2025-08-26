.PHONY: select_os

select_os:
	@echo "Selecione o sistema operacional:"
	@echo "1 - Ubuntu"
	@echo "2 - CentOS"
	@echo "3 - Fedora"
	@echo "4 - Debian"
	@echo "Escolha uma opção (1-4): "
	@read choice; \
	if [ $$choice -eq 1 ]; then \
		echo "Executando script para Ubuntu..."; \
		./docker_ubuntu.sh; \
	elif [ $$choice -eq 2 ]; then \
		echo "Executando script para CentOS..."; \
		./docker_centos.sh; \
	elif [ $$choice -eq 3 ]; then \
		echo "Executando script para Fedora..."; \
		./docker_fedora.sh; \
	elif [ $$choice -eq 4 ]; then \
		echo "Executando script para Debian..."; \
		./docker_debian.sh; \
	else \
		echo "Opção inválida!"; \
	fi
