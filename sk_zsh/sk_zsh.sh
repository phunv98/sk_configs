#!/bin/bash
OMZ_PLUGINS="git dotenv"

check_version_zsh() {
        MAJOR_MIN=5
        MINOR_MIN=0
        PATCH_MIN=8
        MAJOR=`echo $1 | cut -d'.' -f1`
        MINOR=`echo $1 | cut -d'.' -f2`
        PATCH=`echo $1 | cut -d'.' -f3`
        if [ $((MAJOR)) -gt $((MAJOR_MIN)) ] || \
                ([ $((MAJOR)) -eq $((MAJOR_MIN)) ] && [ $((MINOR)) -gt $((MINOR_MIN)) ]) || \
                ([ $((MAJOR)) -eq $((MAJOR_MIN)) ] && [ $((MINOR)) -eq $((MINOR_MIN)) ] && [ $((PATCH)) -ge $((PATCH_MIN)) ]); then
                return 1
        fi
        return 2
}

install_ohmyzsh() {
        if [ -x "$(command -v curl)" ]; then
                # install using curl
                sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        elif [ -x "$(command -v wget)" ]; then
                # install using wget
                sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        elif [ -x "$(command -v fetch)" ]; then
                #install using fetch
                sh -c "$(fetch -o - https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        else
                echo "You need install curl or wget or fetch to install neovim (or insall manually) <3"
        fi
}

install_p10k() {
        if [ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]; then
                git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        fi
}

install_plugin_ohmyzsh() {
     # install plugins
        sed -i "s/^plugins=.*/plugins=(${OMZ_PLUGINS})/"  ~/.zshrc
}

set_theme_ohmyzsh() {
        # set theme for ohmyzsh
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
}

set_alias() {
        # remove all before alias
        sed -i  "/^alias.*/d" ~/.zshrc
        # add new alias
        echo "alias cls='clear'
alias ll='ls -al'" >> ~/.zshrc

        `which zsh` -i -c "source ~/.zshrc" &> /dev/null
}

config_omz() {
        # Check version of zsh
        ZSH_VERSION=`zsh --version | cut -d' ' -f2`
        check_version_zsh $ZSH_VERSION
        if [ $? -eq 1 ]; then
                if [ ! -f ~/.zshrc_origin ]; then
                        mv ~/.zshrc ~/.zshrc_origin
                        cp ~/.zshrc_origin ~/.zshrc
                fi
                OMZ_V=$(`which zsh` -i -c "command -v omz")
                if ! [ ${OMZ_V} == "omz" ]; then
                        install_ohmyzsh
                fi
                install_plugin_ohmyzsh
                install_p10k
                set_theme_ohmyzsh
                set_alias
                # config with powerlevel10k
                echo -e "\nUse exec zsh to config p10k - have fun <3\n"
        else
                echo "You need update to newer version of zsh"
        fi
}

if ! [ -x "$(command -v zsh)" ]; then
        sudo apt install zsh -y
        if [ $? -ne "0" ]; then
                echo "Cannot install zsh"
        else
               config_omz
        fi
else
        config_omz
fi
