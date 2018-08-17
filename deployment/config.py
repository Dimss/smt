import configparser
import os

config = configparser.ConfigParser()
config.read(os.path.dirname(__file__) + '/dp.ini')

AWS_REGION = config.get('aws', 'region')

ECS_CLUSTER_NAME = config.get('ecs', 'ecs_cluster_name')
SD_SERVICE_ARN = config.get('ecs', 'sd_service_arn')
SUBNETS = config.get('ecs', 'subnets').split(",")
SECURITY_GROUPS = config.get('ecs', 'security_groups').split(",")
