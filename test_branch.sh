export BRANCH=$(echo $CODEBUILD_WEBHOOK_HEAD_REF | rev | cut -d '/' -f 1 | awk '{printf $1}' | rev)
echo $BRANCH

if [ $(echo $BRANCH) == 'master' ]
then
  echo 'Cool! In code, we trust!'
# Publish notification directly from the CLI. Use Branch name in the message.
   echo 'aws sns publish --topic-arn "arn:aws:sns:us-west-2:0123456789012:my-topic" --message <string>'
else
  echo 'Sorry, this code doesnt have what it takes. Fail Build.'
fi
