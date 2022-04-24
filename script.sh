#!/bin/bash
# ----------------------------------------------------------------------------------------------------- #
# Changelog:
#
#   v1.0 22/04/2022, Rafael Caldas (TX) - disponivel apenas para apt e yum:
#     - Instalação de pacotes pós-instlação de SO para uso pessoal
#
#     -h     | -help          [ Exibe a ajuda do script.                         ]
#     -dev   | -desenvolvedor [ Instala os pacotes basicos para desenvolvimento. ]
#     -utils                  [ Instala utilitarios gerais                       ]
#
#     ** Prioridade de instalação: 1- Gerenciador nativo 2- Pacote Baixado 3- Snap
# ----------------------------------------------------------------------------------------------------- #

# -------------------------------------------VARIÁVEIS------------------------------------------------- #

# Estilo
NEGRITO='\033[01m'
# Cores
VERMELHO='\033[01;31m'
VERDE='\033[01;32m'
AMARELO='\033[01;33m'
SEM_COR='\033[00;37m'
ERRO_COR='\033[05;31m'

# Pre-sets
INFO_PRE="[INFO.] -"
ERRO_PRE="[${ERRO_COR}ERROR${SEM_COR}] -"
ALERT_PRE="[${AMARELO}ALERT${SEM_COR}] -"
OK_PRE="[ ${VERDE}OK.${SEM_COR} ] -"

# Diretorios
DIR_DOWNLOADS="$HOME/Downloads"
DIR_PROGRAMAS="$DIR_DOWNLOADS/programas"

# Parametros
if [ ! -n "$2" ]; then
  if [ -n "$1" ]; then
    PARAM=$1
  else
    echo -e "${ERRO_PRE} Esse script requer parametros, utilize ${NEGRITO}-h${SEM_COR} para verificar as opções disponíveis. \nNenhuma modificação foi realizada no seu sistema."
  fi
else
  echo -e "${ERRO_PRE} Parametros excessivos, 1 parametro permitido e $# passados."
  exit 1
fi

case $PARAM in
  -h             ) OP="help" ;;
  -help          ) OP="help" ;;
  -dev           ) OP="dev"  ;;
  -desenvolvedor ) OP="dev"  ;;
  *              ) echo -e "${ERRO_PRE} Parametro inválido, utilize -h para verificar as opções disponíveis." && exit 1 ;;
esac

if [[ $OP == "help" ]]; then
  echo -e "\nScript pré-set de instalação 1.0 (amd64) \nUtilização: $0 [opção]\n"
  echo -e "Comandos disponíveis: \n"
  echo -e " -h   | -help          [ Exibe a ajuda do script.                         ]"
  echo -e " -dev | -desenvolvedor [ Instala os pacotes basicos para desenvolvimento. ]"
  exit 1
fi

# Validação do gerenciador de pacotes
if [[ -x /usr/bin/apt ]]; then
  GERENCIADOR=apt
  PACOTES=deb
else
  if [[ -x /bin/yum ]]; then
    GERENCIADOR=yum
    PACOTES=rpm
  else
    echo -e "${ERRO_PRE} Este script funciona apenas para sistemas com o gerenciador de pacotes ${NEGRITO}apt${SEM_COR} ou ${NEGRITO}yum${SEM_COR}. /nCancelando execução."
    exit 1
  fi
fi
echo -e "Script de Pós-Instalação - Opção selecionada $OP - Gerenciador $GERENCIADOR - Pacotes $PACOTES"
echo -e "${SEM_COR}${INFO_PRE} Gerenciador de pacotes selecionado (${NEGRITO} $GERENCIADOR ${SEM_COR})."

# Programas
if [[ $OP == "dev" ]]; then
  if [[ $GERENCIADOR == "apt" ]]; then
    PROGRAMAS_PARA_INSTALAR=(
      "google-chrome-stable"
      "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
      "code"
      "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
      "git"
      "gerenciador"
      "nodejs"
      "gerenciador"
      "remmina"
      "gerenciador"
    )
  fi

  if [[ $GERENCIADOR == "yum" ]]; then
    PROGRAMAS_PARA_INSTALAR=(
      "snapd"
      "gerenciador"
      "google-chrome"
      "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm"
      "code"
      "snap"
      "git"
      "gerenciador"
      "nodejs"
      "gerenciador"
      "remmina"
      "snap"
      "postman"
      "snap"
    )
  fi
fi;



# ---------------------------------------------------------------------------------------------------- #

# -------------------------------Verificador de dependencias ----------------------------------------- #

verificar_instalacao () {
  if [ $1 == "apt" ]; then
    if dpkg -l $2 &> /dev/null; then
      INSTALAR="0"
    else
      INSTALAR="1"
    fi
  fi
  if [ $1 == "yum" ]; then
    if rpm -q $2 &> /dev/null; then
      INSTALAR="0"
    else
      INSTALAR="1"
    fi
  fi
}

# -------------------------------TESTES----------------------------------------- #

# Internet conectando?
if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
  echo -e "${ERRO_PRE} Seu computador não tem conexão com a Internet. Verifique os cabos e o modem."
  exit 1
else
  echo -e "${OK_PRE} Conexão com a Internet funcionando normalmente."
fi

# wget está instalado?
PROGRAMA="wget"
verificar_instalacao $GERENCIADOR $PROGRAMA
if [ "$INSTALAR" == "1" ]; then
  echo -e "${ALERT_PRE} O programa wget não está instalado."
  echo -e "${INFO_PRE} Instalando o wget..."
  sudo $GERENCIADOR install wget -y &> /dev/null
else
  echo -e "${OK_PRE} O programa wget já está instalado."
fi

# ------------------------------------------------------------------------------- #

# -------------------------------FUNÇÕES----------------------------------------- #

remover_locks () {
  echo -e "${INFO_PRE} Removendo locks..."
  if [ "$1" == "apt" ]; then
    sudo rm /var/lib/dpkg/lock-frontend &> /dev/null
    sudo rm /var/cache/apt/archives/lock &> /dev/null
  else
    echo -e "${INFO_PRE} Sem locks para remover em yum."
  fi
}

atualizar_repositorios () {
  echo -e "${INFO_PRE} Atualizando repositórios..."
  sudo apt update &> /dev/null
}

verificar_diretorios () {
  [[ ! -d "$DIR_DOWNLOADS" ]] && mkdir "$DIR_DOWNLOADS"
  [[ ! -d "$DIR_PROGRAMAS" ]] && mkdir "$DIR_PROGRAMAS"
}

instalar_programa () {
  if [ $1 == "apt" ]; then
    if [ $2 == "pacote" ]; then
      verificar_diretorios
      echo "$DIR_PROGRAMAS/$3.$PACOTES"
      sudo dpkg -i "$DIR_PROGRAMAS/$3.$PACOTES" &> /dev/null
      echo -e "${INFO_PRE} Instalando dependências..."
      sudo apt -f install -y &> /dev/null
    fi
    if [ $2 == "gerenciador" ]; then
      sudo apt install $3 -y &> /dev/null
    fi
  fi
  if [ $1 == "yum" ]; then
    if [ $2 == "pacote" ]; then
      sudo rpm -i "$DIR_PROGRAMAS/$3.$PACOTES" &> /dev/null
    fi
    if [ $2 == "gerenciador" ]; then
      sudo yum install $3 -y &> /dev/null
    fi
  fi
  if [ $2 == "snap" ]; then
    sudo snap install $3 &> /dev/null
  fi
}

verificar_e_instalar_programas () {

  LENGHT=${#PROGRAMAS_PARA_INSTALAR[@]}

  for (( j=0; j<$LENGHT; j++ )); do
    if [ $((j%2)) -eq '0' ]; then
      PROGRAMA=${PROGRAMAS_PARA_INSTALAR[$j]}
      verificar_instalacao $GERENCIADOR $PROGRAMA
    else
      if [ $INSTALAR == "1" ]; then
        echo -e "Instalar ${PROGRAMA}"
        MODO=${PROGRAMAS_PARA_INSTALAR[$j]}
        case $MODO in
          "gerenciador" )
            echo -e "${INFO_PRE} Instalando ${PROGRAMA} à partir do ${GERENCIADOR}..."
            instalar_programa $GERENCIADOR $MODO $PROGRAMA
            ;;
          "snap" )
            echo -e "${INFO_PRE} Instalando snap de ${PROGRAMA}..."
            instalar_programa $GERENCIADOR $MODO $PROGRAMA
            ;;
          * )
            echo -e "${INFO_PRE} Baixando o arquivo ${PROGRAMA}...$MODO"
            wget -c "$MODO" -O "$DIR_PROGRAMAS/$PROGRAMA.$PACOTES" &> /dev/null
            echo -e "${INFO_PRE} Instalando ${PROGRAMA}..."
            instalar_programa $GERENCIADOR "pacote" ${PROGRAMA}
            ;;
        esac
      else
        echo -e "${OK_PRE} O programa ${NEGRITO}${PROGRAMA}${SEM_COR} já está instalado."
      fi
    fi
  done
}

upgrade_e_limpa_sistema () {
  echo -e "${INFO_PRE} Fazendo upgrade e limpeza do sistema..."
  sudo apt dist-upgrade -y &> /dev/null
  sudo apt autoclean &> /dev/null
  sudo apt autoremove -y &> /dev/null
}
# -------------------------------------------------------------------------------- #

# -------------------------------EXECUÇÃO----------------------------------------- #

remover_locks $GERENCIADOR
atualizar_repositorios
verificar_e_instalar_programas
upgrade_e_limpa_sistema
echo -e "${OK_PRE} Excecuçao concuida."

# ------------------------------------------------------------------------------ #
