#!/bin/bash
set -e

# Garante que o podman-compose encontre o socket do seu usuário
export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"

CONTAINER_FILE="Containerfile"
COMPOSE_FILE="compose.yml"
PROJECT_NAME="pure"
CONTAINER_NAME="pure-app"
CONTAINER_IGNORE=".dockerignore"
MODE="dev" # Padrão é desenvolvimento

# Função para extrair variável do .env (não usa `source`)
get_env_var() {
  local key="$1"
  if [ -f ".env" ]; then
    local line
    line=$(grep -E "^[[:space:]]*${key}[[:space:]]*=" .env || true)
    if [ -n "$line" ]; then
      echo "$line" | sed -E "s/^[[:space:]]*${key}[[:space:]]*=[[:space:]]*//; s/^[\"']?//; s/[\"']?$//"
      return 0
    fi
  fi
  return 1
}

# Detectar UID/GID
USER_ID=$(id -u)
GROUP_ID=$(id -g)

# Se .env não existir, criar com valores padrões
if [ ! -f .env ]; then
  echo "Arquivo .env não encontrado — criando com valores padrão..."
  cat <<EOF > .env
PUID=${USER_ID}
PGID=${GROUP_ID}
HOSTNAME=127.0.0.1
DB_HOSTNAME=127.0.0.1
PORT=3000
DB_PORT=28015
DB_PORT_WEB=8080
EOF
  chmod 600 .env
  echo "Arquivo .env criado com dados padrão (altere em .env)"
fi

# Ler variáveis do .env
PORT=$(get_env_var "PORT" || echo "3000")

# Valores padrão
ENGINE=""
CLI_PORT=""

# Parsing de argumentos com getopts
while getopts "m:e:p:" opt; do
  case $opt in
    m) MODE=$OPTARG ;;    # ex: -m dev ou -m prod
    e) ENGINE="$OPTARG" ;;   # --engine docker|podman
    p) CLI_PORT="$OPTARG" ;; # --port 4000
    *) echo "Uso: $0 [-m dev|prod] [-e engine] [-p porta] {up|down|build|logs|exec|restart|clean}" ; exit 1 ;;
  esac
done
shift $((OPTIND-1))

# Lógica de seleção de TARGET
if [[ "$MODE" == "prod" ]]; then
    TARGET="production"
    echo "🏗️  MODO: Produção (Imagem final)"
else
    TARGET="development"
    echo "🛠️  MODO: Desenvolvimento (TS-Node/Volumes)"
fi

# Se porta foi passada via CLI, sobrescreve
if [ -n "$CLI_PORT" ]; then
  PORT="$CLI_PORT"
fi

# Detectar engine se não foi passada
if [ -z "$ENGINE" ]; then
  if command -v docker &>/dev/null; then
    ENGINE="docker"
  elif command -v podman &>/dev/null; then
    ENGINE="podman"
  else
    echo "Erro: Docker ou Podman não instalados."
    exit 1
  fi
fi

# --- DEFINIÇÃO GLOBAL DE COMANDOS ---
# Usamos variáveis sem aspas na execução para expansão correta de argumentos
# --- DEFINIÇÃO DE COMANDOS VIA FUNÇÕES ---
compose_exec() {
    # Criamos um array com os argumentos fixos
    local args=(compose -f "$COMPOSE_FILE" -p "$PROJECT_NAME")
    if [[ "$ENGINE" == "podman" ]]; then
        # O "${args[@]}" garante que cada item seja passado como um argumento único e protegido
        command podman "${args[@]}" "$@"
    else
        command docker "${args[@]}" "$@"
    fi
}

engine_build() {
    if [[ "$ENGINE" == "podman" ]]; then
        command podman build -f "$CONTAINER_FILE" "$@"
    else
        command docker build -f "$CONTAINER_FILE" "$@"
    fi
}

show_help() {
    echo "Uso: ./manage.sh [-e engine] [-p porta] [comando]"
    echo ""
    echo "Opções:"
    echo "  -e engine   Define engine (docker|podman)"
    echo "  -p porta    Define porta da aplicação"
    echo ""
    echo "Comandos:"
    echo "  up             Inicia os containers em background"
    echo "  down           Para e remove os containers"
    echo "  build          Reconstroi a imagem da API"
    echo "  logs           Mostra os logs em tempo real"
    echo "  exec           Acessa o terminal do container"
    echo "  restart        Reinicia os containers"
    echo "  clean          Limpa imagens órfãs e volumes não usados"
    echo "  local-deploy   (Apenas Podman por enquanto) o systemd lê esses arquivos no boot e o Podman gera "na hora" um serviço do sistema para aquele container"
}

CMD="$1"

case "$CMD" in
# Adicione este bloco no seu case "$CMD"
    test)
        echo "🧪 Rodando testes no container..."
        $ENGINE compose exec -it app npm test
        ;;
    test-watch)
        echo "🧪 Rodando testes no container..."
        $ENGINE compose exec -it app npm run test:watch
        ;;
    run)
        # Permite rodar qualquer coisa: ./manager-container.bash run "npm run build"
        shift # remove o 'run' da lista de argumentos
        echo "🏃 Executando comando personalizado: $@"
        $ENGINE compose exec -it app "$@"
        ;;
    up)
        APP_MODE=$MODE compose_exec up -d
        echo "🚀 API rodando em http://localhost:${PORT}"
        ;;
    down)
        # Tenta rodar o down. Se falhar por erro de rede, o Podman geralmente 
        # resolve na segunda tentativa ou o container já sumiu.
        APP_MODE=$MODE compose_exec down || {
            echo "⚠️  Aviso: Erro ao limpar rede. Tentando remoção forçada de containers órfãos..."
            $ENGINE rm -f "${PROJECT_NAME}-app" 2>/dev/null || true
        }
        ;;
    build)
        echo "🔧 Construindo imagem usando $CONTAINER_FILE..."

        if [[ "$ENGINE" != "podman" ]]; then
          compose_exec build \
          --squash \
          --ignorefile "$CONTAINER_IGNORE" \
          --no-cache \
          .
        else
          $ENGINE build \
            -f "$CONTAINER_FILE" \
            --squash \
            -t "${PROJECT_NAME}:latest" \
            --label "project=${PROJECT_NAME}" \
            --ignorefile "$CONTAINER_IGNORE" \
            --target "$TARGET" \
            --no-cache \
            .
        fi
        # Verifica se o serviço do sistema existe e está ativo
        if systemctl --user is-active --quiet "${PROJECT_NAME}.service"; then
            echo "🔄 Imagem atualizada! Reiniciando serviço do sistema..."
            systemctl --user restart "${PROJECT_NAME}.service"
        fi

        # Limpa apenas o "lixo" gerado por ESSE build específico
        $ENGINE image prune --filter "dangling=true" -f
        ;;
    logs)
        compose_exec logs -f
        ;;
    exec)
        echo "🔍 Acessando terminal dentro do contêiner..."
        $ENGINE compose exec -it "$CONTAINER_NAME" /bin/sh
        ;;
    restart)
        echo "🔄 Reiniciando contêiner..."
        compose_exec down
        compose_exec up -d
        ;;
    clean)
        echo "🧹 Limpando apenas imagens órfãs do projeto..."
        # Lista as imagens sem nome e as remove, silenciando erros se a lista estiver vazia
        DANGLING_IMAGES=$($ENGINE images -f "dangling=true" -q)
        if [ -n "$DANGLING_IMAGES" ]; then
            $ENGINE rmi $DANGLING_IMAGES
        else
            echo "Nenhuma imagem órfã encontrada."
        fi
        ;;
    local-deploy)
        if [[ "$ENGINE" != "podman" ]]; then
            echo "❌ Erro: Deploy via Quadlets requer a engine Podman."
            exit 1
        fi

        QUADLET_DIR="$HOME/.config/containers/systemd"
        mkdir -p "$QUADLET_DIR"

        # Pega o caminho absoluto da pasta atual do projeto
        FULL_PROJECT_PATH=$(pwd)

        echo "🚀 Preparando deploy via Quadlet..."

        # Criar o arquivo de rede Quadlet
        cat <<EOF > "$QUADLET_DIR/${PROJECT_NAME}_net.network"
[Network]
Label=project=${PROJECT_NAME}
Driver=bridge
EOF

        # 1. Substitui ${PORT} no template e salva na pasta do systemd
        # Usamos 'envsubst' que é comum no Linux, ou um sed simples:
        # No sed, vamos substituir também o caminho do ENV no template
        sed -e "s|\${PORT}|${PORT}|g" \
            -e "s|\${ENV_PATH}|${FULL_PROJECT_PATH}/.env|g" \
            deploy/pure.container.template > "$QUADLET_DIR/${PROJECT_NAME}.container"        

        echo "🔄 Recarregando daemon do systemd..."
        systemctl --user daemon-reload
        
        echo "⚡ Iniciando serviço..."
        systemctl --user enable --now "${PROJECT_NAME}.service"
        
        echo "✅ Deploy concluído! Verifique com: systemctl --user status ${PROJECT_NAME}.service"
        ;;
    *)
        show_help
        ;;
esac
