
import json
import os
import boto3

def lambda_handler(event, context):
    ec2 = boto3.client("ec2", region_name="ap-south-1")

    response = ec2.run_instances(
        ImageId=os.environ["EC2_AMI_ID"],
        InstanceType=os.environ["EC2_INSTANCE_TYPE"],
        KeyName=os.environ["EC2_KEY_NAME"],
        SubnetId=os.environ["EC2_SUBNET_ID"],
        SecurityGroupIds=[
            os.environ["EC2_SECURITY_GROUP_ID"]
        ],
        MinCount=1,
        MaxCount=1
    )

    instance_ids = [
        instance["InstanceId"]
        for instance in response["Instances"]
    ]

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "EC2 launch request submitted",
            "instance_ids": instance_ids
        })
    }
