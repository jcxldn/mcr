#!/bin/bash

# Usage: ./test.sh (tag) "<search pattern>"
#    eg: ./test.sh jcxldn/minecraft-runner:waterfall-alpine "Listening on"

echo "Found tag: '$1'"
echo "Found search pattern: '$2'"


echo "::group::Starting container"

# Create empty test.log.txt
# WSL refuses to create this if the extension is .log, so we're using log.txt instead
echo > test.log.txt

screen -L -Logfile test.log.txt -d -m -S container-test docker run -it --rm $1

# Set flush time to 0secs
screen -r container-test -X colon "logfile flush 0^M"

tail -f -n0 test.log.txt &
PID=$!

# tail from coreutils 8.28+ required!
# otherwise grep will never terminate
# src: (patch) https://git.savannah.gnu.org/cgit/coreutils.git/commit/?id=v8.27-42-gce0415f
# src: (forum) https://superuser.com/a/1405010
tail -f -n0 test.log.txt | grep -qe "$2"

if [ $? == 0 ]; then
    echo -e "::endgroup::"
    echo -e "::group::Stopping container"
    screen -S container-test -X stuff "end\n"

    # Wait for the server to stop
    while screen -list | grep -q container-test
    do
        sleep 1
    done
    echo -e "::endgroup::"

    echo "All finished!"
    
    echo "Killing leftover tail process $PID"
    kill $PID

fi