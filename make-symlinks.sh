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
