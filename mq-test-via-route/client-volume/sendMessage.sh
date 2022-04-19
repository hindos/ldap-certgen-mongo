#!/bin/bash


printf '%s\n%s\n' $MQSAMP_USER_ID $TEST_MESSAGE  |  /opt/mqm/samp/bin/amqsputc $TARGET_Q $TARGET_QMGR_PUT 

