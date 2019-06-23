#!/usr/bin/env bash
# --------------------------------[ Cabeçalho ]------------------------------- #
#
# ElementaryOS base 19.04 Disco Dingo
#
# Autor: Clayton Pereira
# Telegram: @Claytonpx13 - URL: https://telegram.me/Claytonpx13
#
# Descrição:
#    Este script foi criado para trocar a base do sistema Elementary OS 5.0
# mudando a plataforma do Ubuntu 18.04 para i Ubuntu 19.04.
#    Apesar de ter sido testado, toda e qualquer alteração no sistema pode
# causar danos e instabilidade no mesmo. Ao executar este script, você faz por
# sua conta e risco.
#
#    O uso é recomendado apenas para pessoas que já possuem um conhecimento
# intermediário sobre os arquivos do sistema linux.
#    Este codigo é livre para que você modifique conforme sua necessidade,
# podendo também redistribuir sua copia sem a necessidade da permissão do autor
# lembrando apenas de fazer mensão ao mesmo.
#
# Pré requisitos:
#    Sistema Operacional: Elementary OS 5.0 Juno
#    Usuário: root
#
# Versão: 1.0
#
# -----------------------------------------------------------------------------#
# ----------------------[ Validando usuário e sistema ]------------------------#
# Verifica se o usuário atual tem permissão administrativa.
[[ $(id -u) -ne 0 ]] && {
    zenity --info --ellipsize \
    --text="Você não tem permissão para executar este script.\n Tente novamente com a conta root."\
    &> /dev/null
    exit 1
}

# Verificando se o sistema é o Elementary OS 5.0 Juno base:18.04.x LTS.
if [[ $(grep ^"ID=" /etc/os-release | sed "s/.*=//") == "elementary" ]]
then
    [[ $(grep "DISTRIB_CODE" /etc/upstream-release/lsb-release | sed "s/.*=//") == "bionic" ]] || {
        zenity --info --ellipsize \
        --text="Este sistema não é compatível." &> /dev/null
        exit 1
    }
else
    zenity --info --ellipsize \
    --text="Este sistema não é compatível." &> /dev/null
    exit 1
fi
# -----------------------------------------------------------------------------#
# ----------------------------------[ Termos ]---------------------------------#
echo " Ao usar este script você afirma estar ciente que:
1) Não poderá interrompelo no meio do processo.

2) Após a Atualização todos os repositórios adicionais teram que ser instalados manualmente.

3) Qualquer modificação nesse script pode inutilizar o mesmo.

4) O script foi testado, mas não posso garantir que seja 100% funcional
(o uso dele é de sua responsabilidade).

5) Alguns serviços como bluethooth e outros serão parados durante a execução.

6) Você não deve deixar programas abertos durante o processo desde script e
nem deixar que a maquina entre em hibernação." > /tmp/termo.txt
if zenity --title="eOS Update base:19.04" --width=550 --height=400 \
--text-info --filename=/tmp/termo.txt --checkbox="Estou ciente e aceito" \
&> /dev/null; then
    rm -f /tmp/termo.txt

    # Parando alguns serviços para atualização.
    for service in apparmor bluetooth cron cups cups-browsed openvpn ufw
    do
        systemctl stop "$service" &> /dev/null
    done
else
    rm -f /tmp/termo.txt
    exit 1
fi
# -----------------------------------------------------------------------------#
# -------------------------------[ Atualização ]-------------------------------#
# Verificando se existe arquivo lock e excluindo.
[[ -f /var/lib/apt/lists/lock ]] && rm -f /var/lib/apt/lists/lock
[[ -f /var/cache/apt/archives/lock ]] && rm -f /var/cache/apt/archives/lock

# Atualizando o sistema e limpando o cache.
apt update &> /dev/null && apt upgrade -y &> /dev/null

echo
echo " Limpando cache e pacotes desnecessários..."; sleep 1

apt autoremove -y &> /dev/null
apt clean &> /dev/null

echo
echo "Verificando e instalando dependências, aguarde..."; sleep 1

if zenity --question --ellipsize \
--text="Deseja adicionar o repositório do flathub e elementary-tweaks?" \
&> /dev/null; then
    # Verifica se o software-properties-common está no sistema.
    [[ $(command -v add-apt-repository) ]] || {
        # Instalando software-properties para adição de repositórios.
        echo " Instalando software-properties para adição de repositórios..."
        apt install software-properties-common --no-install-recommends -y &> /dev/null
    }

    # Adicionando repositórios Flatpak e elementary-tweaks
    echo "Adicionando repositórios..."; sleep 1
    add-apt-repository ppa:alexlarsson/flatpak -y -n
    add-apt-repository ppa:philip.scott/elementary-tweaks -y -n
    apt install elementary-tweaks -y &> /dev/null
    apt install flatpak -y &> /dev/null
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "Concluido."
    reset; sleep 1

    [[ $(command -v add-apt-repository) ]] && {
        # Removendo software-properties pois não será mais necessário.
        echo "software-properties não será mais necessário."
        echo " Removendo software-properties..."
        apt remove software-properties-common -y &> /dev/null
    }
else
    # Verifica se o software-properties-common está no sistema.
    [[ $(command -v add-apt-repository) ]] && {
        # Removendo software-properties pois não será mais necessário.
        echo "software-properties não será mais necessário."
        echo " Removendo software-properties..."
        apt remove software-properties-common -y &> /dev/null
    }
fi

# Verificando a presença do update-manager no sistema.
echo
echo " Checando a presença do update-manager no sistema..."; sleep 1
[[ $(command -v do-release-upgrade) ]] || {
    # Instalando o update-manager
    echo " Baixando update-manager..."
    apt install update-manager -y &> /dev/null
}

echo
echo " Editando o arquivo release-updates..."; sleep 1

# Verificar o arquivo /etc/update-manager/release-updates
if grep "Prompt=never" /etc/update-manager/release-upgrades
then
    sed -i "s/Prompt=never/Prompt=normal/" /etc/update-manager/release-upgrades
elif grep "Prompt=lts" /etc/update-manager/release-updates
then
    sed -i "s/Prompt=lts/Prompt=normal/" /etc/update-manager/release-updates
fi

echo
echo " Movendo repositórios..."; sleep 2

# Movendo os repositórios adicionais do sistema para /tmp/repo
[[ "$(ls -A /etc/apt/sources.list.d/)" ]] && {
    rm -f /etc/apt/sources.list.d/*.save
    [[ -d /tmp/repo ]] || mkdir /tmp/repo
    mv /etc/apt/sources.list.d/* /tmp/repo
}

echo
echo " Criando backup do grub atual..."; sleep 2

# Copiando arquivo de configuração do grub para diretório temporário.
[[ -d /tmp/grub ]] || mkdir /tmp/grub
cp /etc/default/grub /tmp/grub/grub

echo
echo " Modificando repositório principal do sistema..."; sleep 2

# Modificando o arquivo /etc/apt/sources.list para a versão 19.04 disco.
sed -i "s/bionic-backports main restricted universe/disco-backports main restricted/" /etc/apt/sources.list
sed -i "s/bionic/disco/g" /etc/apt/sources.list

# Esta linha é opcional, serve para corrigir erros de janela em alguns softwares
# Caso não queira alterar o valor do GTK_CSD comente a linha abaixo.
echo "export GTK_CSD=0" >> /etc/profile

# Verificando se existe arquivo lock e excluindo.
[[ -f /var/lib/apt/lists/lock ]] && rm -f /var/lib/apt/lists/lock
[[ -f /var/cache/apt/archives/lock ]] && rm -f /var/cache/apt/archives/lock

reset; sleep 1
echo "Iniciando Atualização dos repositórios."; sleep 1

### Atualizando os repositórios Disco Dingo
apt update

zenity --info --ellipsize \
--text="Nesta etapa de atualização.\n Caso apareça perguntas sobre atualizar arquivos de serviços, confirme com 'Y'"\
&> /dev/null

### Atualizando sistema
sleep 1; apt upgrade -y
sleep 1; apt full-upgrade -y

reset; sleep 1

echo
echo "Limpando..."; sleep 1
apt remove imagemagick imagemagick-6.q16 -y &> /dev/null
apt autoremove -y &> /dev/null
apt clean &> /dev/null

echo
echo " Movendo repositórios..."; sleep 2

# Movendo os repositórios adicionais do /tmp/repo para o /etc/apt/sources.list.d/
mv /tmp/repo/* /etc/apt/sources.list.d/

# Excluindo diretório temporário.
rmdir /tmp/repo
[[ -d /tmp/repo ]] && rm -rf /tmp/repo # Forçar exclusão caso a primeira tentativa falhar.

# Movendo arquivo do grub
mv /tmp/grub/grub /etc/default

# Excluindo diretório temporário do grub.
rmdir /tmp/grub
[[ -d /tmp/grub ]] && rm -rf /tmp/grub # Forçar exclusão caso a primeira tentativa falhar.

# Atualizando o grub.
sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/" /etc/default/grub
update-grub

# Ajustando informações da nova base do sistema.
echo 'NAME="elementary OS"
VERSINO="5.0 Juno"
ID=elementary
ID_LIKE=ubuntu
PRETTY_NAME="elementary OS 5.0 Juno"
VERSION_ID="5.0"
HOME_URL="https://elementary.io/"
SUPPORT_URL="https://elementary.io/support"
BUG_REPORT_URL="https://github.com/elementary/appcenter/issues/new"
PRIVACY_POLICY_URL="https://elementary.io/privacy-policy"
VERSION_CODENAME=juno
UBUNTU_CODENAME=disco' > /usr/lib/os-release

echo 'DISTRIB_ID=elementary
DISTRIB_RELEASE=5.0
DISTRIB_CODENAME=juno
DISTRIB_DESCRIPTION="elementary OS 5.0 Juno"' > /etc/lsb-release

echo 'DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=19.04
DISTRIB_CODENAME=disco
DISTRIB_DESCRIPTION="Ubuntu 19.04"' > /etc/upstream-release/lsb-release

### Requerir reinicialização da maquina.
if zenity --question --ellipsize \
--text="O sistema precisa ser reiniciado. Quer fazer isso agora?" \
&> /dev/null; then
    echo "Reiniciando..."; sleep 1
    systemctl reboot now
else
    reset
    exit 0
fi
# -----------------------------------------------------------------------------#
