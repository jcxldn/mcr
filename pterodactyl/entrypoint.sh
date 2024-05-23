#!/bin/sh

# https://pterodactyl.io/community/config/eggs/creating_a_custom_image.html

cd /home/container

echo "ptero-entrypoint > Welcome! In Directory: '$(pwd)'"

# Output Current Java Version
java -version ## only really needed to show what version is being used. Should be changed for different applications

# Output current glibc version (jcxldn/openjdk-alpine based images)
echo "glibc version $(ls /usr/glibc-compat/lib | grep ld-.*\.so$ | cut -d- -f2 | awk -F '[.so]' '{print $1"."$2}')"

echo "ptero-entrypoint > Replacing startup variables..."

# Replace Startup Variables
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`

if [ ${SERVER_MEMORY} -eq 0 ]; then
    # Server has no memory limit set!
    echo "ptero-entrypoint > Found zeroed SERVER_MEMORY var! Will not attempt to dynamically create -Xms and -Xmx flags."
    MODIFIED_STARTUP="$MODIFIED_STARTUP -Drunner.automatic.mem=false -Xms128M"
else
    # Server has a memory limit set, we can generate dynamic -Xmx and -Xms

    # Generate -Xmx and -Xms values based on pterodactyl SERVER_MEMORY env
    # Then append to MODIFIED_STARTUP
    echo "ptero-entrypoint > Found SERVER_MEMORY var with value '$SERVER_MEMORY'"

    # Leave 256M of allocated memory unused
    # Start with 1/4th of allocated memory
    MODIFIED_STARTUP="$MODIFIED_STARTUP -Drunner.automatic.mem=true -Xmx$(expr $SERVER_MEMORY - 256)M -Xms$(expr $SERVER_MEMORY / 4)M"
fi

echo ":/home/container$ ${MODIFIED_STARTUP}"

echo "ptero-entrypoint > Starting server with: '$MODIFIED_STARTUP'"

# Run the Server
${MODIFIED_STARTUP}
