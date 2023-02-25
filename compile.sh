#!/bin/bash

echo "Creating output folder..."
if [ -d "build" ]; then
    rm -rf "build"
fi
mkdir "build"
sleep 2

echo "Download ISCC..."
git clone "https://github.com/Jakiboy/ISCC.git/" "./temp"
mv "./temp/bin" "./compiler"
rm -rf "./temp"
sleep 2

clear
echo "Compile setup..."
"$(pwd)/compiler/ISCC.exe" "$(pwd)/redis.iss" # Abs. path
sleep 2
clear

echo "--------------------"
read -p "Press enter to exit"
