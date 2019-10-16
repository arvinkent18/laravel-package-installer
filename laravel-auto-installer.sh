#!/bin/bash
# Laravel Automated Installer Version 1.0 by Arvin Kent Sahid Lazaga
echo "****** AUTOMATED LARAVEL PACKAGES & DEPENDENCIES INSTALLER BY ARVIN KENT SAHID LAZAGA ******"

# Response Receiver
chosen() {
    echo -e "You have chosen $1, please enter application name: "
    read name
}

# Permission for Folders and Files of the Application
permit() {
    if chmod -R 777 $1
    then
        echo "Appended read/write/execute permissions for all users/groups/others to $1 directory"
    fi
    if chmod -R o+w $1/storage
    then
        echo "Permitted others with write permissions to path $1/storage"
    fi
}

# Artisan Commands
artisan() {
    app=$1
    command=$2
    method="$command:$3"
    case "$command" in 
    "key" )
        if php artisan $method
        then
            echo "Generated key for $app"
        fi;;
    esac
}

# Configuring Application based on Package Downloader
configure() {
    app=$1
    downloader=$2
    if cd $app 
    then
        echo "Moved to directory of $app"            
        mv .env.example .env 
        echo "Renamed .env.example to .env"
    fi
    case $downloader in 
        "composer") 
            artisan $app "key" "generate";;
        "git")
            echo "Cleaning Files First"
            if composer dump-autoload
            then
                echo "Downloading dependencies"
                if composer install 
                then
                    artisan $app "key" "generate"
                fi
            fi;;
    esac
}

# Reading Response from the User
composer_query() {
    optional=$1
    if [ "$optional" == "re-init" ]
    then
        read -r -p "Search for packages again [Yes/No]?" response
        composer_config ${response,,}
    else
        read -r -p "Do you want to search for packages [Yes/No]?" response
        composer_config ${response,,}
    fi
}

# Configuring and Searching for Packages
composer_config(){
    response=$1
    if [[ "$response" =~ ^(yes|y)$ ]]
    then
        read -r -p "Search package name: " package
        composer search $package
        if echo `ls | wc -l`
        then
            echo -n "Searched completed. Please select from one of the packages above to install in your application:"
            read installpackage
        fi
        if composer require $installpackage 
        then
            echo "Downloaded $installpackage package"
            composer_query "re-init"
        else
            echo "There's no such thing as $installpackage"
            composer_query "re-init"
        fi
    else
        echo "Thank you for using Arvin's Automated Laravel Package Installer"
    fi
}

# Application Program Starts Here
echo "Choose your Package Downloader"
choices=("Composer" "Git")
echo -e "[1] Composer [2] Git:"
app=${name,,} 
app=${app// /-}
read choice
case $choice in
    1) 
    chosen ${choices[$choice - 1]}
    echo "Downloading Laravel package installer from composer"
    if composer create-project --prefer-dist laravel/laravel $app
    then 
        echo "Download Complete"
        permit $app
        configure $app "composer"
        composer_query "default"
    fi;;
    2) 
    chosen ${choices[$choice -1]}
    echo "Cloning Laravel from Github"
    if git clone https://github.com/laravel/laravel.git
    then
        mv laravel $app
        echo "Renamed laravel to $app"
        permit $app
        configure $app "git"
        composer_query "default"
    fi;;
    *) 
    echo "Invalid Choice"
    exit 0;;
esac 
