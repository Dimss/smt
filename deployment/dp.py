import boto3
import click
from termcolor import cprint
from pyfiglet import figlet_format
import config

session = boto3.session.Session(profile_name="default", region_name=config.AWS_REGION)

@click.group()
def cli():
	pass


class Depl(object):
	def __init__(self):
		self.ecs = session.client('ecs')
		self.sd = boto3.client('servicediscovery')

	def create_new_task(self, task_name: str, c_name: str, c_image: str, c_ports: [], cpu='256', mem='512'):
		"""
		:param task_name: Task name
		:param c_name: container image name
		:param c_image: container image
		:param c_ports: dict of container ports (container port, host port and protocol)
		:param cpu: see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
		:param mem: see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
		:return:
		"""
		self.ecs.register_task_definition(
				family=task_name,
				networkMode='awsvpc',
				containerDefinitions=[
					{
						'name':         c_name,
						'image':        c_image,
						'portMappings': c_ports,
					},
				],
				requiresCompatibilities=['FARGATE'],
				cpu=cpu,
				memory=mem
		)

	def delete_service(self, service_name):
		print(f"Gonna delete service name: {service_name}")
		response = self.ecs.delete_service(
				cluster=config.ECS_CLUSTER_NAME,
				service=service_name,
				force=True
		)
		print(response)

	def delete_task(self, task_name):
		print("Gonna delete all task definitions")
		tasks_definitions = self.ecs.list_task_definitions(familyPrefix=task_name)
		for task_def_arn in tasks_definitions['taskDefinitionArns']:
			response = self.ecs.deregister_task_definition(taskDefinition=task_def_arn)
			print(response)


@click.command('create-task')
def create_task():
	Depl().create_new_task(
			'web-app-task',
			'istio-tester',
			'dimssss/hw:0.1',
			[{
				'containerPort': 8080,
				'hostPort':      8080,
				'protocol':      'tcp'
			}]
	)


@click.command('create-service')
def create_service():
	print("Gonna create new service. . .")
	ecs = session.client('ecs')
	ecs.create_service(
			cluster=config.ECS_CLUSTER_NAME,
			serviceName='web-app',
			taskDefinition='web-app-task:2',
			serviceRegistries=[
				{
					'registryArn': config.SD_SERVICE_ARN
				},
			],
			desiredCount=1,
			launchType='FARGATE',

			networkConfiguration={
				'awsvpcConfiguration': {
					'subnets':        config.SUBNETS,
					'securityGroups': config.SECURITY_GROUPS,
					'assignPublicIp': 'DISABLED'
				}
			},
			schedulingStrategy='REPLICA'
	)


@click.command('delete-service')
@click.argument('service-name')
def delete_service(service_name):
	Depl().delete_service(service_name)


@click.command('delete-task')
@click.argument('task-name')
def delete_task(task_name):
	Depl().delete_task(task_name)


cli.add_command(create_task)
cli.add_command(create_service)
cli.add_command(delete_service)
cli.add_command(delete_task)

if __name__ == '__main__':
	cprint(figlet_format('Depl', font='big'), 'green')
	# logging.log("Test log message",logging.INFO)
	cli()
