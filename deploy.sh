#!/bin/bash
echo "Your PATH is $PATH"
echo "You are on branch $TRAVIS_BRANCH"
echo "The TRAVIS_PULL_REQUEST_BRANCH is $TRAVIS_PULL_REQUEST_BRANCH"
if [[ "$TRAVIS_PULL_REQUEST_BRANCH" = "" ]]
then
	zip -r r-ladies.zip public/
	curl -X POST -H "Content-Type: application/zip" -H "Authorization: Bearer $NETLIFYKEY" --data-binary "@r-ladies.zip" https://api.netlify.com/api/v1/sites/728e663f-18fb-432c-80d6-840c043ce50a/deploys
else
    echo "You are not on master, deploying preview."
fi