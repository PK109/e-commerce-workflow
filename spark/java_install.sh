#! /bin/bash

wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz
echo "Unzipping java files"
tar xzf openjdk-11.0.2_linux-x64_bin.tar.gz
echo "Unzipping finished."
rm openjdk-11.0.2_linux-x64_bin.tar.gz
JAVA_HOME="$(pwd)/jdk-11.0.2"
# Check if it's already in PATH
if [[ ":$PATH:" != *":$JAVA_HOME:"* ]]; then
  echo "export JAVA_HOME=\"${JAVA_HOME}\"" >> ~/.bashrc
  echo "export PATH=\"$JAVA_HOME/bin:\$PATH\"" >> ~/.bashrc
  source ~/.bashrc
  echo "Path updated!"
else
  echo "Path already exists in ~/.bashrc"
fi