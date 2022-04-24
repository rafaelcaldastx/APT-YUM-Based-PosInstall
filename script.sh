#!/bin/bash
#
#   Script de Pós-Instalação
#   Autor: Rafael Caldas
#   GitHub: https://github.com/rafaelcaldastx
#   Fork do Projeto: https://github.com/Diolinux/Linux-Mint-19.x-PosInstall (Diolinux)
#
# ----------------------------------------------------------------------------------------------------- #
#   Este script foi feito com o intuito de instalar conjuntos de programas predefinidos
#   para algumas das atividades nas minhas instalações, upgrade dos pacotes existentes
#   e limpeza de pacotes descartáveis.
#
#   Para alterar os programas, altere a váriavel PROGRAMAS_PARA_INSTALAR dentro da opção
#   que deseja modificar da seguinte forma:
#   PROGRAMAS_PARA_INSTALAR=(
#     "nome do pacote"
#     "forma de instalacao"
#   )
#   **as formas de instalação podem ser gerenciador, snap ou diretamente a url do pacote
#
#   Utilização:
#   1-) Dê a permissão de execução do script para o usuário com chmod
#         ex. $ chmod u+x script.sh
#   2-) Execute o script com ./script.sh [opção]
#         ex. $ ./script.sh -dev
# ----------------------------------------------------------------------------------------------------- #
# Changelog:
#
#   v1.0 22/04/2022, Rafael Caldas (TX) - disponivel apenas para apt e yum:
#     - Instalação de pacotes pós-instlação de SO para uso pessoal
#
#     -h     | -help          [ Exibe a ajuda do script.                         ]
#     -dev   | -desenvolvedor [ Instala os pacotes basicos para desenvolvimento. ]
#
# ----------------------------------------------------------------------------------------------------- #
# Testado em:
#   bash 5.1.8
# ----------------------------------------------------------------------------------------------------- #

# ------------------------------------Variáveis e Funções iniciais------------------------------------- #

# Estilo
NEGRITO='\033[01m'

# Cores
VERMELHO='\033[01;31m'
VERDE='\033[01;32m'
AMARELO='\033[01;33m'
SEM_COR='\033[00;37m'
ERRO_COR='\033[05;31m'

# Pre-sets
INFO_PRE='[INFO.] -'
ERRO_PRE="[${ERRO_COR}ERROR${SEM_COR}] -"
ALERT_PRE="[${AMARELO}ALERT${SEM_COR}] -"
OK_PRE="[ ${VERDE}OK.${SEM_COR} ] -"

# Diretorios
DIR_DOWNLOADS="$HOME/Downloads"
DIR_PROGRAMAS="$DIR_DOWNLOADS/programas"

# Mensageiro
msg () {
  case $1 in
    'erro' )
      echo -e "${ERRO_PRE} $2"
      exit 1
      ;;
    'alerta' )
      echo -e "${ALERT_PRE} $2"
      ;;
    'info' )
      echo -e "${INFO_PRE} $2"
      ;;
    'ok' )
      echo -e "${OK_PRE} $2"
      ;;
  esac
}

# Verifica Parametros
if [[ ! -n "$2" ]]; then
  if [[ -n "$1" ]]; then
    PARAM=$1
  else
    msg 'erro' "Esse script requer parametros, utilize ${NEGRITO}-h${SEM_COR} para verificar as opções disponíveis. \nNenhuma modificação foi realizada no seu sistema."
  fi
else
  msg 'erro' "Parametros excessivos, 1 parametro permitido e $# passados."
fi

case $PARAM in
  '-h'|'-help' )
    OP='help' ;;
  '-dev'|'-desenvolvedor' )
    OP='dev' ;;
  * )
    msg 'erro' "Parametro inválido, utilize -h para verificar as opções disponíveis." ;;
esac

# Opção Help
if [[ $OP == 'help' ]]; then
  cat <<- END

  Script pré-set de instalação 1.0 (amd64)
  Utilização: $0 [opção]

  Comandos disponíveis:
  -h   | -help          [ Exibe a ajuda do script.                         ]
  -dev | -desenvolvedor [ Instala os pacotes basicos para desenvolvimento. ]

END
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
    msg 'erro' "Este script funciona apenas para sistemas com o gerenciador de pacotes ${NEGRITO}apt${SEM_COR} ou ${NEGRITO}yum${SEM_COR}. /nCancelando execução."
  fi
fi

# Programas para instalar
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

# ----------------------------------------Verificador de dependencias -------------------------------- #

verificar_instalacao () {
  if [[ $1 == "apt" ]]; then
    if dpkg -l $2 &> /dev/null; then
      INSTALAR="0"
    else
      INSTALAR="1"
    fi
  fi
  if [[ $1 == "yum" ]]; then
    if rpm -q $2 &> /dev/null; then
      INSTALAR="0"
    else
      INSTALAR="1"
    fi
  fi
}

# ---------------------------------------------------------------------------------------------------- #

# -------------------------------------------Testes no ambiente--------------------------------------- #

testa_ambiente () {
# Internet conectando?
msg 'info' "Verificando conexão..."
if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
  msg 'erro' "Seu computador não tem conexão com a Internet. Verifique os cabos e o modem."
else
  msg 'ok' "Conexão com a Internet funcionando normalmente."
fi

# wget está instalado?
PROGRAMA='wget'
msg 'info' "Verificando instalação do ${NEGRITO}${PROGRAMA}${SEM_COR}..."
verificar_instalacao $GERENCIADOR $PROGRAMA
if [[ "$INSTALAR" == '1' ]]; then
  msg 'alerta' "O programa ${NEGRITO}${PROGRAMA}${SEM_COR} não está instalado."
  msg 'info' "Instalando o wget..."
  sudo $GERENCIADOR install wget -y &> /dev/null
else
  msg 'ok' "O programa ${NEGRITO}${PROGRAMA}${SEM_COR} já está instalado."
fi
}

# ---------------------------------------------------------------------------------------------------- #

# ------------------------------------------Funções--------------------------------------------------- #

remover_locks () {
  msg 'info' "Removendo locks..."
  if [[ "$1" == 'apt' ]]; then
    sudo rm /var/lib/dpkg/lock-frontend &> /dev/null
    sudo rm /var/cache/apt/archives/lock &> /dev/null
  else
    msg 'info' "Sem locks para remover em yum."
  fi
}

atualizar_repositorios () {
  msg 'info' "Atualizando repositórios..."
  sudo apt update &> /dev/null
}

verificar_diretorios () {
  [[ ! -d "$DIR_DOWNLOADS" ]] && mkdir "$DIR_DOWNLOADS"
  [[ ! -d "$DIR_PROGRAMAS" ]] && mkdir "$DIR_PROGRAMAS"
}

instalar_programa () {
  if [[ "$1" == 'apt' ]]; then
    if [[ "$2" == 'pacote' ]]; then
      verificar_diretorios
      echo "$DIR_PROGRAMAS/$3.$PACOTES"
      sudo dpkg -i "$DIR_PROGRAMAS/$3.$PACOTES" &> /dev/null
      msg 'info' "Instalando dependências..."
      sudo apt -f install -y &> /dev/null
    fi
    if [[ "$2" == 'gerenciador' ]]; then
      sudo apt install "$3" -y &> /dev/null
    fi
  fi
  if [[ "$1" == 'yum' ]]; then
    if [[ "$2" == 'pacote' ]]; then
      sudo rpm -i "$DIR_PROGRAMAS/$3.$PACOTES" &> /dev/null
    fi
    if [[ "$2" == 'gerenciador' ]]; then
      sudo yum install "$3" -y &> /dev/null
    fi
  fi
  if [[ "$2" == "snap" ]]; then
    sudo snap install "$3" &> /dev/null
  fi
}

verificar_e_instalar_programas () {
  LENGHT=${#PROGRAMAS_PARA_INSTALAR[@]}

  for (( j=0; j<$LENGHT; j++ )); do
    if [[ $((j%2)) -eq '0' ]]; then
      PROGRAMA=${PROGRAMAS_PARA_INSTALAR[$j]}
      verificar_instalacao $GERENCIADOR $PROGRAMA
    else
      if [[ $INSTALAR == '1' ]]; then
        echo -e "Instalar ${PROGRAMA}"
        MODO=${PROGRAMAS_PARA_INSTALAR[$j]}
        case $MODO in
          'gerenciador' )
            msg 'info' "Instalando ${NEGRITO}${PROGRAMA}${SEM_COR} à partir do ${GERENCIADOR}..."
            instalar_programa $GERENCIADOR $MODO $PROGRAMA
            ;;
          'snap' )
            msg 'info' "Instalando snap de ${NEGRITO}${PROGRAMA}${SEM_COR}..."
            instalar_programa $GERENCIADOR $MODO $PROGRAMA
            ;;
          * )
            msg 'info' "Baixando o arquivo ${NEGRITO}${PROGRAMA}${SEM_COR}...$MODO"
            wget -c "$MODO" -O "$DIR_PROGRAMAS/$PROGRAMA.$PACOTES" &> /dev/null
            msg 'info' "Instalando ${PROGRAMA}..."
            instalar_programa $GERENCIADOR "pacote" ${PROGRAMA}
            ;;
        esac
      else
        msg 'ok' "O programa ${NEGRITO}${PROGRAMA}${SEM_COR} já está instalado."
      fi
    fi
  done
}

upgrade_e_limpa_sistema () {
  msg 'info' "Fazendo upgrade e limpeza do sistema..."
  sudo apt dist-upgrade -y &> /dev/null
  sudo apt autoclean &> /dev/null
  sudo apt autoremove -y &> /dev/null
}

# ---------------------------------------------------------------------------------------------------- #

# --------------------------------------------Execução------------------------------------------------ #

echo -e "\v${SEM_COR}Script de Pós-Instalação - Opção selecionada${NEGRITO}${OP}${SEM_COR}- Gerenciador de pacotes${NEGRITO} $GERENCIADOR ${SEM_COR}- Pacotes${NEGRITO}${PACOTES}${SEM_COR} \nSua senha de super usuário poderá ser solicitada durante a execução.\v"
testa_ambiente
remover_locks $GERENCIADOR
atualizar_repositorios
verificar_e_instalar_programas
upgrade_e_limpa_sistema
msg 'ok' "Excecuçao concuida."

# ---------------------------------------------------------------------------------------------------- #
