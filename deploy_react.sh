#!/usr/bin/env bash
set -x
set -o errexit
set -o pipefail
# set -u
# set -o xtrace

get_var() {
  local name="$1"

  curl -s -H "Metadata-Flavor: Google" \
    "http://metadata.google.internal/computeMetadata/v1/instance/attributes/${name}"
}

update_and_upgrade_operating_system() {
    # install updates for ubuntu machine
    sudo apt-get -y update
    # install upgrades for ubuntu machine
    sudo apt-get -y upgrade
}

install_application_dependencies() {
    # install git update if needed
    sudo apt-get -y install git
 
    # install nodejs tar file of a specific dependency
    if [[ ! -f "/node-v9.4.0-linux-x64.tar.xz" ]];then
        cd / && sudo wget https://nodejs.org/dist/v9.4.0/node-v9.4.0-linux-x64.tar.xz
    fi
    # unzip the tar file storing node
    sudo tar xvfJ /node-v9.4.0-linux-x64.tar.xz
    # create a symlink for the node and npm installed
    if [[ ! -f "/usr/bin/npm" ]];then
        sudo ln -s /node-v9.4.0-linux-x64/bin/npm /usr/bin/npm
    else
        # if the npm file exists delete it as it may be of a
        # lower dependency value
        sudo rm -rf /usr/bin/npm
        sudo ln -s /node-v9.4.0-linux-x64/bin/npm /usr/bin/npm
    fi
    if [[ ! -f "/usr/bin/node" ]];then
        sudo ln -s /node-v9.4.0-linux-x64/bin/node /usr/bin/node
    else
        # if the node file exists delete it as it may be of a
        # lower dependency value
        sudo rm -rf /usr/bin/node
        sudo ln -s /node-v9.4.0-linux-x64/bin/node /usr/bin/node
    fi
}

create_directory_for_application() {
    # make a directory through which to clone the repo
    # directory is only created if non-existent
    if [[ ! -d "~/App" ]];then
        sudo mkdir -p ~/App
    else
        # remove directory in case it existed.
        sudo rm -rf ~/App
        sudo mkdir -p ~/App
    fi
}

clone_repository() {
    cd ~/App
    # clone the repo for the front-end
    # check if the clone was not yet present
    # clone branch that can be installed on gcp
    if [[ ! -d "FlaskAPIConsumer" ]];then
        sudo git clone -b google https://github.com/WinstonKamau/FlaskAPIConsumer.git
    fi
}

add_url(){
        cat <<EOF > ~/App/FlaskAPIConsumer/.env
REACT_APP_URL="$(get_var "apiURL")"
EOF
}

install_and_run_application() {
    # change directory into the folder FlaskAPIConsumer
    sudo su
    cd ~/App/FlaskAPIConsumer
    # install node modules as per the package.json file
    sudo npm install
    
    # run application
    sudo nohup npm start &
}

main() {
    update_and_upgrade_operating_system
    install_application_dependencies
    create_directory_for_application
    clone_repository
    add_url
    install_and_run_application
}

main "$@"
