#!/bin/bash
# git branch -a --contains HEAD| sed -n 2p | awk '{printf $1}' | rev | cut -d '/' -f 1 | rev

echo $CODEBUILD_WEBHOOK_HEAD_REF | sed -n 2p | awk '{printf $1}' | rev | cut -d '/' -f 1 | rev

# if [ $(echo $CODEBUILD_WEBHOOK_HEAD_REF) == 'refs/heads/master' ]
# then
#   echo 'Cool! In code, we trust!'
#   aws sns publish --topic-arn "arn:aws:sns:us-west-2:0123456789012:my-topic" --message <string>
# else
#   echo 'Sorry, this code doesn't have what it takes. Fail Build.'
# fi

