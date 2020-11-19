#!/usr/bin/env bash

# A bash script to set up temporary credentials for use
# with the aws cli 
#
# Prerequisites:  1. an AWS account
#                 2. a user created with a virtual mfa device enabled
#                 3. programatic access enabled for the user

# first - unset any sensitive AWS environment variables that we
# don't want to use by accident in case this script fails
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

#
# Get the temporary credentials and store in a file for parsing
# 

# 1. build the aws sts command to get temporary credentials
#    and the first one we need should be set in the environment
#    and should look something like this
#    arn:aws:iam::12DIGITACCNTNUMBER:mfa/USERNAME
if [ -z "$AWS_SERIAL_NUMBER" ]
then
    echo "AWS_SERIAL_NUMBER should be set as an environment variable before running this script..."
    exit 0
else
    echo "your AWS_SERIAL_NUMBER is: $AWS_SERIAL_NUMBER ..."
fi

# 2. ask user for the mfa token which should be 6 digits
echo "Please enter your 6-digit MFA code: "
read mfa_token

# 3. call aws sts and write the output to a file for parsing 
# aws sts get-session-token --serial-number arn:aws:iam::410593103261:mfa/samf --token-code 508628
echo "aws get-session-token --serial-number $AWS_SERIAL_NUMBER --token-code $mfa_token > temp.json"
aws sts get-session-token --serial-number $AWS_SERIAL_NUMBER --token-code $mfa_token > temp.json

# for debugging uncomment
#cat temp.json

# 4. parse the temp.json file and pull out the info we need to use
export AWS_ACCESS_KEY_ID=`jq -r '.Credentials.AccessKeyId' temp.json`
export AWS_SECRET_ACCESS_KEY=`jq -r '.Credentials.SecretAccessKey' temp.json`
export AWS_SESSION_TOKEN=`jq -r '.Credentials.SessionToken' temp.json`

# for debugging print all the AWS env vars that are now set
#env | grep AWS_

# start an interactive shell with our new temporary AWS credentials available 
exec $SHELL -i
