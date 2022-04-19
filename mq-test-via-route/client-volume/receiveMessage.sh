#!/bin/bash

echo "TARGET_Q is: $TARGET_Q"
echo "TARGET_QMGR_GET is: $TARGET_QMGR_GET"

echo $MQSAMP_USER_ID | /opt/mqm/samp/bin/amqsgetc $TARGET_Q $TARGET_QMGR_GET > message.txt

echo "Message received is: ... "
cat message.txt

echo "The test message should be: $TEST_MESSAGE"


if grep -q "$TEST_MESSAGE" message.txt 
then
    echo "Message has been found on the queue."
else
    echo "Error: Message has not been retrieved from the queue."
    exit 78
fi
rm message.txt

