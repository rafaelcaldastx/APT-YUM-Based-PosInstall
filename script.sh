#!/bin/bash
# ----------------------------------------------------------------------------------------------------- #
# Changelog:
#
#   v1.0 22/04/2022, Rafael Caldas (TX) - disponivel apenas para apt e yum:
#     - Instalação de pacotes pós instlação de SO para uso pessoal
#
# ----------------------------------------------------------------------------------------------------- #

# -------------------------------------------VARIÁVEIS------------------------------------------------- #


# Cores
VERMELHO='\033[01;31m'
VERDE='\033[01;32m'
AMARELO='\033[01;33m'
SEM_COR='\033[00;37m'
ERRO_COR='\033[05;31m'
NEGRITO='\033[01m'
# Pre-sets
INFO_PRE="[INFO.] -"
ERRO_PRE="[${ERRO_COR}ERROR${SEM_COR}] -"
ALERT_PRE="[${AMARELO}ALERT${SEM_COR}] -"
OK_PRE="[ ${VERDE}OK.${SEM_COR} ] -"

# Diretorios
DIR_DOWNLOADS="$HOME/Downloads"
DIR_PROGRAMAS="$DIR_DOWNLOADS/programas"

# Parametros
if [ -n "$1" ]; then
  PARAM=$1
else
  PARAM="erro"
fi

# Programas
PROGRAMAS_PARA_INSTALAR_DEB=(
  "google-chrome"
  "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
  "code"
  "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
)

PROGRAMAS_PARA_INSTALAR_RPM=(
  google-chrome
  https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
)

## ---------------------------------------------HELP---------------------------------------------------##

if [[ $PARAM == "-h" || $PARAM == "-help" ]]; then
  echo -e "\nScript pré-set de instalação 1.0 (amd64) \nUtilização: $0 [opção]\n"
  echo -e "Comandos disponíveis: \n"
  echo -e " -h   | -help          [ Exibe a ajuda do script.                         ]"
  echo -e " -dev | -desenvolvedor [ Instala os pacotes basicos para desenvolvimento. ]"
  exit 1
fi
# ---------------------------------------------------------------------------------------------------- #

# -------------------------------Verificador de dependencias ----------------------------------------- #

# Validação do gerenciador de pacotes
if [[ -x /usr/bin/apt ]]; then
  GERENCIADOR=apt
else
  if [[ -x /bin/yum ]]; then
    GERENCIADOR=yum
  else
    echo -e "${ERRO_PRE} Este script funciona apenas para sistemas com o gerenciador de pacotes ${NEGRITO}apt${SEM_COR} ou ${NEGRITO}yum${SEM_COR}. /nCancelando execução."
    exit 1
  fi
fi
echo -e "${INFO_PRE} Gerenciador de pacotes selecionado (${NEGRITO} $GERENCIADOR ${SEM_COR})."


check_dependency() {
  if [ $1 == "apt" ]; then
    if [ dpkg -l $2 &> /dev/null ]; then
      echo -e "0"
    else
      echo -e "1"
    fi
  fi
  if [ $1 == "yum" ]; then
    if [ rpm -q $2 &> /dev/null ]; then
      echo -e "0"
    else
      echo -e "1"
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
echo -e "${INFO_PRE} Verificando instalação do wget. ${GERENCIADOR} $(check_dependency $GERENCIADOR $PROGRAMA)"
if [ $(check_dependency $GERENCIADOR $PROGRAMA) == "0" ]; then
  echo -e "${ALERT_PRE} O programa wget não está instalado."
  echo -e "${INFO_PRE} Instalando o wget..."
  sudo $GERENCIADOR install wget -y &> /dev/null
else
  echo -e "${OK_PRE} O programa wget já está instalado."
fi

# ------------------------------------------------------------------------------- #

# -------------------------------FUNÇÕES----------------------------------------- #

atualizar_repositorios () {
  echo -e "${VERDE}[INFO] - Atualizando repositórios...${SEM_COR}"
  sudo apt update &> /dev/null
}

remover_locks () {
  echo -e "${INFO_PRE} Removendo locks...${SEM_COR}"
  if [ $1 == "apt" ]; then
    sudo rm /var/lib/dpkg/lock-frontend &> /dev/null
    sudo rm /var/cache/apt/archives/lock &> /dev/null
  else
    echo -e "${INFO_PRE} Sem locks para remover em yum."
  fi
}

instalar_programa () {
  if [ $1 == "apt" ]; then
    if [ $2 == "pacote" ]; then
      sudo dpkg -i $DIR_PROGRAMAS/${3##*/} &> /dev/null
    fi
    if [ $2 == "gerenciador" ]; then
      sudo apt install $3 -y &> /dev/null
    fi
  fi
  if [ $1 == "yum" ]; then
    if [ $2 == "pacote" ]; then
      sudo rpm -i $DIR_PROGRAMAS/${3##*/} &> /dev/null
    fi
    if [ $2 == "gerenciador" ]; then
      sudo yum install $3 -y &> /dev/null
    fi
  fi
}

baixar_pacotes_debs () {
  [[ ! -d "$DIR_DOWNLOADS" ]] && mkdir "$DIR_DOWNLOADS"
  [[ ! -d "$DIR_PROGRAMAS" ]] && mkdir "$DIR_PROGRAMAS"

  LENGHT=${#PROGRAMAS_PARA_INSTALAR_DEB[@]}

  for (( j=0; j<$LENGHT; j++ )); do
    if [ $((j%2)) -eq '0' ]; then
      PROGRAMA=${PROGRAMAS_PARA_INSTALAR_DEB[$j]}
      INSTALAR=$(check_dependency $GERENCIADOR $PROGRAMA)
    else
      if [ $INSTALAR == "0" ]; then
        echo -e "Instalar ${PROGRAMA}"
        echo -e "${INFO_PRE} Baixando o arquivo ${PROGRAMAS_PARA_INSTALAR_DEB[$j]##*/}..."
        wget -c "${PROGRAMAS_PARA_INSTALAR_DEB[$j]}" -P "$DIR_PROGRAMAS" &> /dev/null
        echo -e "${INFO_PRE} Instalando ${PROGRAMA}..."
        #sudo dpkg -i $DIRETORIO_DOWNLOAD_PROGRAMAS/${url##*/} &> /dev/null
        instalar_programa $GERENCIADOR "pacote" ${PROGRAMAS_PARA_INSTALAR_DEB[$j]}
        echo -e "${INFO_PRE} Instalando dependências..."
        if [ $GERENCIADOR == "apt" ]; then
          sudo apt -f install -y &> /dev/null
        fi
      else
        echo -e "${INFO_PRE} O programa ${NEGRITO}${PROGRAMA}${SEM_COR} já está instalado."
      fi
    fi
  done
}

# -------------------------------------------------------------------------------- #

# -------------------------------EXECUÇÃO----------------------------------------- #

remover_locks $GERENCIADOR
baixar_pacotes_debs

# ------------------------------------------------------------------------------ #
