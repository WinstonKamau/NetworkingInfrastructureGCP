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
    # install update for ubuntu machine
    sudo apt-get -y update
    # install upgrade for ubuntu machine
    sudo apt-get -y upgrade
}
install_application_dependencies() {
    # install virtual environment for the operation of the python
    sudo apt-get -y install python-virtualenv
    # install pip for installing the requirements of the application
    sudo apt-get -y install python-pip
    # install git to be used to clone the flask-api application
    sudo apt-get -y install git
}

create_virtual_environment() {
    # delete directory if it exists
    if [[ -d "flask-env" ]];then
        sudo rm -rf flask-env
    fi
    # create virtual environment folder
    virtualenv flask-env
    # declare the path for activating the virtual environment
    declare -r VENV_ROOT=flask-env/bin/activate
    # Activate the virtual environment
    source "${VENV_ROOT}"
}

clone_repository() {
    # Clone the repo into the virtual machine if the repo does not exist
    if [[ ! -d "FLASK_API" ]];then 
        git clone -b herokubranch https://github.com/WinstonKamau/FLASK_API.git
    else
        # If repo exists delete it and install another one
        sudo rm -rf FLASK_API
        git clone -b herokubranch https://github.com/WinstonKamau/FLASK_API.git
    fi
}

install_and_run_application() {
    # Install requirements for the application to be able to run on the machine
    pip install -r FLASK_API/requirements.txt

    # export environment variable for running the application
    export APP_SETTINGS="production"
    export FLASK_APP="run.py"
    export SECRET="$(openssl rand -hex 64)"
    # current database is an open database for testing
    # ensure the url is created and accurated
    export DATABASE_URL="$(get_var "databaseURI")"
    # Check if there were any migrations before
    if [[ ! -d "migrations" ]];then
        python FLASK_API/manage.py db init
    fi
    python FLASK_API/manage.py db migrate
    python FLASK_API/manage.py db upgrade

    # Install gunicorn for running the application
    pip install gunicorn

    # Change directory to the FLASK_API folder and run the application
    # By default the application will run on port 8000
    cd FLASK_API && nohup gunicorn run:app --bind 0.0.0.0 &
}

main() {
    update_and_upgrade_operating_system
    install_application_dependencies
    create_virtual_environment
    clone_repository
    install_and_run_application
}

main "$@"
