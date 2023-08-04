#!/bin/bash

FAILED="$(tput setaf 1) Failed!$(tput setaf 7)"
PASSED="$(tput setaf 2) Passed!$(tput setaf 7)"

TESTS=`find . -type f -perm +111 -path "./$1/**"`

I=1
FAILED_X=0

clear

for TEST in $TESTS ; do
    echo "TEST N$I: $TEST"

    $TEST
    if [ $? = 0 ]; then
        echo "Test N$I ${PASSED}";
    else
        echo "Test N$I ${FAILED}";
        FAILED_X=`expr ${FAILED_X} + 1`
    fi

    I=`expr ${I} + 1`
done

echo ""

if [ $FAILED_X = 0 ]; then
    echo "All Tests ${PASSED} :)"
else
    echo "$FAILED_X Test(s) Failed :("
fi

exit 0