#!/bin/bash
if [ $(echo $CODEBUILD_WEBHOOK_HEAD_REF) == 'refs/heads/test' ]
then
  echo 'OK'
else
  echo 'NO NO NO please dont break the code'
fi


