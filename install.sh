#!/bin/sh

echo -n "Verificando bin de usuario..."
if [ -d ~/bin ]; then
    echo " ja existia."
else
    mkdir -p ~/bin
    echo " Ok."
fi

#echo -n "Verificando variavel PATH..."
#if ! grep -E "PATH=(.*:)?((~)|(\${HOME}))/bin(:.*)?$" ~/.bashrc 2>&1 > /dev/null ; then
#    echo PATH=\$\{PATH\}:~/bin >> ~/.bashrc
#    echo " Ok (nao estava no PATH)."
#else
#    echo " ja estava configurado."
#fi

echo -n "Verificando atalho..."
if [ -e ~/bin/dirtools.bash ]; then
    echo " ja existia."
else
    ln -s $(pwd)/dirtools.bash ~/bin
    echo " Ok."
fi

echo -n "Verificando inicializacao do script..."
if grep dirtools\\.bash ~/.bashrc 2>&1 > /dev/null
then
    echo " ja estava configurado."
else
    echo ". ~/bin/dirtools" >> ~/.bashrc
    echo " Ok."
fi
