# Variáveis
PYTHON := python3
PIP := pip
DB_CONTAINER := postgres_app
PGADMIN_CONTAINER := pgadmin
DOCKER_COMPOSE := docker-compose

# Nome do banco e scripts SQL
DB_INIT := db/esquema.sql
DB_SEED := db/dados.sql

# Variáveis do Programa
PROGRAM := main.py

.PHONY: help setup run stop clean db-init db-seed up down start

# Exibe os comandos disponíveis
help:
	@echo "Comandos disponíveis:"
	@echo "  make setup          - Configura o ambiente Python e instala dependências"
	@echo "  make run            - Executa o programa principal"
	@echo "  make stop           - Para os containers Docker"
	@echo "  make clean          - Remove containers e volumes Docker"
	@echo "  make db-init        - Cria o banco de dados utilizando o script de inicialização"
	@echo "  make db-seed        - Popula o banco de dados com dados iniciais"
	@echo "  make up             - Sobe os serviços Docker (PostgreSQL e pgAdmin)"
	@echo "  make down           - Remove os serviços Docker"
	@echo "  make start          - Sobe o banco de dados e executa o programa principal"

# Configura o ambiente Python
setup:
	@echo "Ativando o ambiente virtual e instalando dependências..."
	$(PIP) install psycopg2

# Executa o programa principal
run:
	@echo "Executando o programa..."
	$(PYTHON) $(PROGRAM)

# Para os containers Docker
stop:
	@echo "Parando os containers..."
	$(DOCKER_COMPOSE) stop

# Remove containers e volumes Docker
clean:
	@echo "Removendo containers e volumes..."
	$(DOCKER_COMPOSE) down -v

# Sobe os serviços Docker
up:
	@echo "Subindo os serviços Docker (PostgreSQL e pgAdmin)..."
	$(DOCKER_COMPOSE) up -d

# Remove os serviços Docker
down:
	@echo "Derrubando os serviços Docker..."
	$(DOCKER_COMPOSE) down

# Inicializa o banco de dados
db-init:
	@echo "Executando o script de inicialização do banco de dados..."
	docker exec -i $(DB_CONTAINER) psql -U user -d mydb < $(DB_INIT)

# Popula o banco de dados com dados iniciais
db-seed:
	@echo "Populando o banco de dados com dados iniciais..."
	docker exec -i $(DB_CONTAINER) psql -U user -d mydb < $(DB_SEED)

# Sobe o banco e executa o programa principal
start: setup
	@echo "Subindo o banco de dados e executando o programa..."
	$(DOCKER_COMPOSE) up -d
	@echo "Aguardando o banco de dados iniciar..."
	@ sleep 15
	@echo "Executando o script de inicialização do banco..."
	docker exec -i $(DB_CONTAINER) psql -U user -d mydb < $(DB_INIT)
	@echo "Populando o banco com dados iniciais..."
	docker exec -i $(DB_CONTAINER) psql -U user -d mydb < $(DB_SEED)
	@echo "Iniciando o programa Python..."
	$(PYTHON) $(PROGRAM)
