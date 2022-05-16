# Inicia o docker
docker:
	sudo docker-compose up

bash:
	sudo docker exec -it finance /bin/bash

debug:
	# Para sair da tela deste comando, CTRL + P CTRL + Q
	sudo docker attach $(container)

build:
	sudo docker-compose build