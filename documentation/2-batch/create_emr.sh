#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r ".Account")
export AWS_ACCOUNT_ID

aws emr create-cluster \
 --name "big_crime_emr" \
 --log-uri "s3://aws-logs-$AWS_ACCOUNT_ID-us-east-1/elasticmapreduce" \
 --release-label "emr-6.15.0" \
 --service-role "arn:aws:iam::$AWS_ACCOUNT_ID:role/EMR_DefaultRole" \
 --unhealthy-node-replacement \
 --ec2-attributes '{"InstanceProfile":"EMR_EC2_DefaultRole","EmrManagedMasterSecurityGroup":"sg-07e8aa15e18b2c21a","EmrManagedSlaveSecurityGroup":"sg-036c5e68a4fb2bd23","KeyName":"vockey","AdditionalMasterSecurityGroups":[],"AdditionalSlaveSecurityGroups":[],"SubnetId":"subnet-001a0cfdded8ad0f0"}' \
 --applications Name=Hadoop Name=Hive Name=JupyterEnterpriseGateway Name=Livy Name=Spark \
 --instance-groups '[{"InstanceCount":1,"InstanceGroupType":"MASTER","Name":"Primary","InstanceType":"m4.large","EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"VolumeType":"gp2","SizeInGB":32},"VolumesPerInstance":1}]}},{"InstanceCount":1,"InstanceGroupType":"TASK","Name":"Task - 1","InstanceType":"m4.large","EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"VolumeType":"gp2","SizeInGB":32},"VolumesPerInstance":1}]}},{"InstanceCount":1,"InstanceGroupType":"CORE","Name":"Core","InstanceType":"m4.large","EbsConfiguration":{"EbsBlockDeviceConfigs":[{"VolumeSpecification":{"VolumeType":"gp2","SizeInGB":32},"VolumesPerInstance":1}]}}]' \
 --scale-down-behavior "TERMINATE_AT_TASK_COMPLETION" \
 --auto-termination-policy '{"IdleTimeout":3600}' \
 --region "us-east-1"