# SSlack
crypto in [Slack](https://slack.com)

`$ ./sslack /Applications/Slack.app/Contents/MacOS/Slack`

![SSlack](https://cloud.githubusercontent.com/assets/1027187/14769924/a9b6868a-0a5b-11e6-9090-b15dac0d6d08.png)


## Why
[Slack](https://slack.com) is great tool, but people at Slack (and your team admin [at some point](http://www.theverge.com/2014/11/24/7255199/slack-alters-privacy-policy-to-let-bosses-read-your-messages)) can read your private messages?

## How to generate key pair
`$ openssl genrsa -out private_sslack.pem 4096 && openssl rsa -pubout -in private_sslack.pem -out public_key.pem`