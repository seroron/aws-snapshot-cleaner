# aws-snapshot-cleaner

Delete AWS EC2 EBS Snapshot for deregistered AMI.

## Motivation

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/deregister-ami.html

> When you deregister an Amazon EBS-backed AMI, it doesn't affect the snapshot that was created for the root volume of the instance during the AMI creation process. You'll continue to incur storage costs for this snapshot. Therefore, if you are finished with the snapshot, you should delete it. 

## Installation

```
bundle install --path modules
export AWS_DEFAULT_REGION=<your region>
export AWS_ACCESS_KEY_ID=<your key id>
export AWS_SECRET_ACCESS_KEY=<your access key>
```

## Usage

Dry-Run
```
bundle exec ruby aws-snapshot-cleaner.rb
```

Remove Snapshot
```
bundle exec ruby aws-snapshot-cleaner.rb -r
```

## Licence
MIT

## Author
[Kenichi HIROSE](https://github.com/seroron)

