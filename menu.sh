#!/bin/bash

#=====================================
#
# Homework "Docker"
# by Evgeniy Naryshkin (aurcame)
# 
#=====================================

# ----------------------------------
# Step #1: Define variables
# ----------------------------------

# colors for user-friendly output
RED='\033[0;41;30m'
GREEN='\033[0;32;32m'
BLUE='\033[0;34;34m'
YELLOW='\033[0;33;33m'
STD='\033[0;0;39m'

# variable for versioning docker images
ver=1.0.1

# ----------------------------------
# Step #2: User defined function
# ----------------------------------

pause(){
  read -p "Press [Enter] key to continue..." fackEnterKey
}

# task 1
one(){
    echo -e "${GREEN}$tasknum${STD}: make file docker and show sha256 shecksum"
    echo "sha256" > docker
    sha256sum docker
    pause
}

# task 2
two(){
    osfamily="ubuntu"
    echo -e "${GREEN}$tasknum${STD}: building ${GREEN}$osfamily image${STD}"
    docker build -f Dockerfile-$osfamily -t $osfamily.img:$ver .
    echo -e "\n${GREEN}running $osfamily container${STD}"
    docker run --rm --name="$osfamily.cont" $osfamily.img:$ver
    pause
}

# task 3
three(){
    osfamily="centos"
    echo -e "${GREEN}$tasknum${STD}: building ${GREEN}$osfamily image${STD}"
    docker build -f Dockerfile-$osfamily -t $osfamily.img:$ver .
    echo -e "\n${GREEN}running $osfamily container${STD}"
    docker run --rm --name="$osfamily.cont" $osfamily.img:$ver
    pause
}

# task 4
four(){
    osfamily="alpine"
    echo -e "${GREEN}$tasknum${STD}: building ${GREEN}$osfamily image${STD}"
    docker build -f Dockerfile-$osfamily -t $osfamily.img:$ver .
    echo -e "\n${GREEN}running $osfamily container${STD}"
    docker run --rm --name="$osfamily.cont" $osfamily.img:$ver
    echo -e "\n${GREEN}number of records (lines) in /etc/passwd file${STD}"
    docker run --rm --name="$osfamily.cont" $osfamily.img:$ver wc -l /etc/passwd
    pause
}

# task 5
five(){
    osfamily="busybox"
    echo -e "${GREEN}$tasknum${STD}: building ${GREEN}$osfamily image${STD}"
    docker build -f Dockerfile-$osfamily -t $osfamily.img:$ver .
    echo -e "\n${GREEN}running $osfamily container${STD}"
    docker run --rm --name="$osfamily.cont" $osfamily.img:$ver df /
    pause
}

# task 6
six(){
    osfamily="hello-world"
    echo -e "${GREEN}$tasknum${STD}: building ${GREEN}$osfamily image${STD}"
    docker build -f Dockerfile-$osfamily -t $osfamily.img:$ver .
    echo -e "\n${GREEN}running $osfamily container${STD}"
    docker run --name="$osfamily.cont" $osfamily.img:$ver
    echo -e "\n${GREEN}inspecting $osfamily container${STD} to find initial command"
    docker inspect $osfamily.cont | grep -A2 -n "Cmd"
    # copy executive hello file from container to calculate checksum 
    docker cp $osfamily.cont:/hello ./hello_$osfamily
    echo -e "\n${GREEN}Calculate checksum of hello binary:${STD} "
    sha256sum ./hello_$osfamily
    # remove hello binary locally
    rm ./hello_$osfamily
    echo -e "\n${BLUE}stop${STD}  container $(docker stop $osfamily.cont)"
    echo -e "${BLUE}removing${STD} container $(docker rm $osfamily.cont)"
    pause
}

# task 7
seven(){
    osfamily="apache"
    echo -e "${GREEN}$tasknum${STD}: apache website"
    echo -e "building ${GREEN}$osfamily image${STD}"
    docker build -f Dockerfile-apache -t apache-site.img:$ver .
    echo -e "\n${GREEN}running $osfamily container${STD}"
    docker run -d --rm -p 80:80 --name=apache-site.cont apache-site.img:$ver

    echo -e "\n${GREEN}OS version in $osfamily container:${STD}"
    docker exec apache-site.cont cat /etc/os-release | head -n 4
    echo -e "\n${GREEN}httpd process list in $osfamily container:${STD}"
    docker exec apache-site.cont apt-get install -y procps && ps aux | grep --color=always httpd
    echo -e "${BLUE}CHECK RUNNING WEBSITE ON ${GREEN}localhost:80${STD}"
    read -p $'\e[90mStop apache container (y|n):\e[0m ' key
    if [ $key == 'y' ]
    then
        docker stop apache-site.cont
    fi
    pause
}

# task 8
eight(){
    # task 8.1 gcc in centos
    echo -e "${GREEN}$tasknum${STD}: compile and start c application in centos"
    
    echo -e "building ${GREEN}Centos:8 image with .c file${STD}"
    docker build -f Dockerfile-gcc-centos -t gcc-centos.img:$ver .
    echo -e "\n${GREEN}running gcc-centos container${STD}"
    docker run -d --rm -it --name=gcc-centos.cont gcc-centos.img:$ver /bin/bash

    # task 8.2 gcc in ubuntu
    echo -e "\n${GREEN}$tasknum${STD}: compile and start c application in ubuntu"
    
    echo -e "building ${GREEN}Ubuntu:18.04 image with .c file${STD}"
    docker build -f Dockerfile-gcc-ubuntu -t gcc-ubuntu.img:$ver .
    echo -e "\n${GREEN}running gcc-ubuntu container${STD}"
    docker run -d --rm -it --name=gcc-ubuntu.cont gcc-ubuntu.img:$ver /bin/bash

    # show info about last 2 containers (include size)
    echo -e "\n${GREEN}last 2 containers:${STD}"
    docker ps -sn 2

    # docker copying hello files from 2 containers
    echo -e "\n${GREEN}copying hello files from containers${STD}"
    docker cp gcc-centos.cont:/hello ./hello_centos
    echo -e "\tcopied ${BLUE}hello_centos${STD} file from ${BLUE}centos${STD} container to local host"
    docker cp gcc-ubuntu.cont:/hello ./hello_ubuntu
    echo -e "\tcopied ${YELLOW}hello_ubuntu${STD} file from ${YELLOW}ubuntu${STD} container to local host"
    
    echo -e "\n${GREEN}copying hello files to containers${STD}"
    # docker copying hello files to 2 opposite containers
    docker cp ./hello_centos gcc-ubuntu.cont:/hello_centos
    echo -e "\tcopied ${BLUE}hello_centos${STD} file from local host to ${YELLOW}ubuntu${STD} container"
    docker cp ./hello_ubuntu gcc-centos.cont:/hello_ubuntu
    echo -e "\tcopied ${YELLOW}hello_ubuntu${STD} file from local host to ${BLUE}centos${STD} container"

    # run copied files
    echo -e "\n${GREEN}run copied hello files from containers${STD}"
    echo -e "\trun ${BLUE}hello_centos${STD} file from ${YELLOW}ubuntu${STD} container:"
    docker exec -i gcc-ubuntu.cont ./hello_centos

    echo -e "\trun ${YELLOW}hello_ubuntu${STD} file from ${BLUE}centos${STD} container:"
    docker exec -i gcc-centos.cont ./hello_ubuntu

    #  docker stop last 2 containers
    echo -e "\nstop ${BLUE}$( docker stop gcc-centos.cont )${STD} container"
    echo -e "stop ${YELLOW}$( docker stop gcc-ubuntu.cont )${STD} container"
    pause
}

# 9 clean up images
nine(){
    echo -e "${GREEN}$tasknum${STD}: ${RED}Clean up existing images${STD}"
    for curimg in gcc-ubuntu.img:$ver \
            gcc-centos.img:$ver \
            apache-site.img:$ver \
            hello-world.img:$ver \
            busybox.img:$ver \
            alpine.img:$ver \
            centos.img:$ver \
            ubuntu.img:$ver \
            hello-world \
            ubuntu:18.04 \
            busybox:uclibc \
            centos:8 \
            httpd:2.4 \
            alpine:3.12 
    do
        if [[ "$(docker images -q $curimg 2> /dev/null)" != "" ]]; then
            docker rmi $curimg
        fi
    done

    pause
}


# clear screen and print menu
show_menu() {
    clear
    echo "~~~~~~~~~~~~~~~~~~~~~"
    echo -e "${BLUE} M A I N - M E N U${STD}"
    echo "~~~~~~~~~~~~~~~~~~~~~"
    echo -e "${BLUE}1${STD}. Task 1. Create file docker, calculate checksum"
    echo -e "${BLUE}2${STD}. Task 2. Ubuntu:18.06 image. Get checksum of file /etc/lsb_release"
    echo -e "${BLUE}3${STD}. Task 3. Centos:8 image. Get checksum of file /etc/os_release"
    echo -e "${BLUE}4${STD}. Task 4. Alpine image. Print /etc/passwd and get number of lines"
    echo -e "${BLUE}5${STD}. Task 5. Busybox container. size of / filesystem"
    echo -e "${BLUE}6${STD}. Task 6. Hello-world container. Find out which binary executes. Get file checksum"
    echo -e "${BLUE}7${STD}. Task 7. Httpd container. Get base linux family. Run ps -aux | grep httpd"
    echo -e "${BLUE}8${STD}. Task 8. Compile and run .c app in centos container. Get app checksum.\n \
          Compile and run .c app in ubuntu container. Get app checksum.\n \
          Check last 2 container sizes\n \
          Copy /hello file from each container locally into hello_centos, hello_ubuntu\n \
          Copy hello_centos into ubuntu container. copy hello_ubuntu into centos container\n \
          Run both commands, to check if works"
    echo -e "${BLUE}9${STD}. Clean all images"
    echo -e "${BLUE}0${STD}. Exit"
}

# read input from the keyboard and take an action:
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option, etc
# Exit when user the user select 0 form the menu option.
read_options(){
    read -p "Enter choice [ 1 - 8 ], exit - 0: " tasknum
    case $tasknum in
        1) one ;;
        2) two ;;
        3) three ;;
        4) four ;;
        5) five ;;
        6) six ;;
        7) seven ;;
        8) eight ;;
        9) nine ;; 
        0) clear; exit 0 ;;
        *) echo -e "${RED}Error...${STD}" && sleep 2
    esac
}
 
# ----------------------------------------------
# Step #3: Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP
 
# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
while true
do
    show_menu
    read_options
done
