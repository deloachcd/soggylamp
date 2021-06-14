#!/bin/bash -e

# VERSION CONSTANTS
# Set these to desired versions before running!

# Note that special keyword 'latest' can be used for
# COMMIT_SHA variables, and does exactly what you'd
# expect it to
GLM_RELEASE=0.9.9.8
GLFW_RELEASE=3.3.3
GL3W_COMMIT_SHA=latest


# ---- actual provisioning logic below this line ----
if [[ -z "$1" ]]; then
    echo "Usage: ./provisioner.sh <project_path>"
    exit -1 
else
    PROJECT_PATH="$1"
fi

# Install system-wide dependencies for pulling down
# and building our project's dependencies
USER_DISTRO="$(cat /etc/os-release | egrep '^NAME' | awk -F '"' '{ print $2 }')"
if [[ "$USER_DISTRO" == *"openSUSE"* ]]; then
    PKG_CMD="sudo zypper in"
    PKG_LIST="wget unzip cmake xorg-x11-devel python3 ctags"
elif [[ "$USER_DISTRO" == *"Ubuntu"* || "$USER_DISTRO" == *"Debian"* ]]; then
    PKG_CMD="sudo apt install"
    PKG_LIST="wget unzip cmake exuberant-ctags xorg-dev"  # TODO: figure out ubuntu dependencies
else
    echo "Unfortunately, this provisioner does not yet support \`$USER_DISTRO\`"
    exit -1
fi

if [[ ! -z "$PKG_CMD" ]]; then
    $PKG_CMD $PKG_LIST
fi

# We're done with argument parsing and system wide stuff by now
if [[ ! -d $PROJECT_PATH ]]; then
    mkdir $PROJECT_PATH
fi

cd $PROJECT_PATH

if [[ ! -d deps ]]; then
    mkdir deps
fi

cd deps

# Pull down dependency archives from GitHub
if [[ ! -e "glm-${GLM_RELEASE}.zip" && ! -d glm ]]; then
    wget https://github.com/g-truc/glm/releases/download/${GLM_RELEASE}/glm-${GLM_RELEASE}.zip
fi
if [[ ! -d gl3w ]]; then
    git clone https://github.com/skaslev/gl3w
    if [[ ! $GL3W_COMMIT_SHA == "latest" ]]; then
        cd gl3w
        git checkout $GL3W_COMMIT_SHA
    fi
fi
if [[ ! -d glfw && ! -e "glfw-$GLFW_RELEASE.zip" ]]; then
    wget https://github.com/glfw/glfw/releases/download/$GLFW_RELEASE/glfw-$GLFW_RELEASE.zip
fi

# Unpack zipped dependency archives
if [[ ! -d glfw ]]; then
    unzip glfw-$GLFW_RELEASE.zip
    mv glfw-$GLFW_RELEASE glfw
    rm glfw-$GLFW_RELEASE.zip
fi
if [[ ! -d glm ]]; then
    unzip glm-$GLM_RELEASE.zip
    rm glm-$GLM_RELEASE.zip
fi

# Use script to generate gl3w.c and gl3w.h
cd gl3w
python3 gl3w_gen.py
cd ..

# Back to project root to generate tags for vim to use
cd ..
ctags -Rf tags

# Ensure syntastic can see our headers (for vim)
SYNTASTIC_HEADERS_DIR="$HOME/.local/include/syntastic-headers"
if [[ ! -d $SYNTASTIC_HEADERS_DIR ]]; then
    mkdir $SYNTASTIC_HEADERS_DIR
fi

if [[ ! -e $SYNTASTIC_HEADERS_DIR/GL ]]; then
    ln -s $PROJECT_PATH/deps/gl3w/include/GL $SYNTASTIC_HEADERS_DIR/GL
fi

if [[ ! -e $SYNTASTIC_HEADERS_DIR/GLFW ]]; then
    ln -s $PROJECT_PATH/deps/glfw/include/GLFW  $SYNTASTIC_HEADERS_DIR/GLFW
fi

if [[ ! -e $SYNTASTIC_HEADERS_DIR/glm ]]; then
    ln -s $PROJECT_PATH/deps/glm/glm $SYNTASTIC_HEADERS_DIR/glm
fi
