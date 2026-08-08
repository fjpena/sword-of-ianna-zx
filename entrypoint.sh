#!/bin/bash
# Crear el symlink para ./gentap si no existe aún en el directorio de trabajo
if [ -d "/src/src" ] && [ ! -f "/src/src/gentap" ]; then
    ln -s /usr/local/bin/gentap /src/src/gentap
fi

exec "$@"
