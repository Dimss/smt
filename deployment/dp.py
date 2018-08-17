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
		response = self.ecs.register_task_definition(
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
		print(response)

	def list_tasks(self):
		tasks_definitions = self.ecs.list_task_definitions(familyPrefix=config.TASK_NAME)
		for task_def_arn in tasks_definitions['taskDefinitionArns']:
			print(task_def_arn)

	def create_new_service(self, task_def, desired_count=1):
		response = self.ecs.create_service(
				cluster=config.ECS_CLUSTER_NAME,
				serviceName=config.SERVICE_NAME,
				taskDefinition=task_def,
				serviceRegistries=[
					{
						'registryArn': config.SD_SERVICE_ARN
					},
				],
				desiredCount=desired_count,
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
		print(response)

	def update_service(self, task_def, replicas=1):
		response = self.ecs.update_service(
				cluster=config.ECS_CLUSTER_NAME,
				service=config.SERVICE_NAME,
				desiredCount=replicas,
				taskDefinition=task_def)
		print(response)

	def delete_service(self, service_name):
		print(f"Gonna delete service name: {service_name}")
		response = self.ecs.delete_service(
				cluster=config.ECS_CLUSTER_NAME,
				service=service_name,
				force=True
		)
		print(response)

	def delete_task(self):
		print("Gonna delete all task definitions")
		tasks_definitions = self.ecs.list_task_definitions(familyPrefix=config.TASK_NAME)
		for task_def_arn in tasks_definitions['taskDefinitionArns']:
			response = self.ecs.deregister_task_definition(taskDefinition=task_def_arn)
			print(response)


@click.command('create-task')
@click.argument('image')
def create_task(image):
	print("Gonna create new task")
	Depl().create_new_task(
			config.TASK_NAME, 'helloworld', image, [{'containerPort': 8080, 'hostPort': 8080, 'protocol': 'tcp'}]
	)


@click.command('create-service')
@click.argument('task-arn')
@click.option('--replicas', default=1, help='Task arn')
def create_service(task_arn, replicas):
	print("Gonna create new service. . .")
	Depl().create_new_service(task_arn, replicas)


@click.command('update-service')
@click.argument('task-arn')
@click.option('--replicas', default=1, help='Replicas, default 1')
def update_service(task_arn, replicas=1):
	print("Gonna update a service")
	Depl().update_service(task_arn, replicas)


@click.command('list-tasks')
def list_tasks():
	Depl().list_tasks()


@click.command('delete-service')
def delete_service():
	Depl().delete_service(config.SERVICE_NAME)


@click.command('delete-tasks')
def delete_tasks():
	Depl().delete_task()


cli.add_command(create_task)
cli.add_command(create_service)
cli.add_command(update_service)
cli.add_command(list_tasks)
cli.add_command(delete_service)
cli.add_command(delete_tasks)

if __name__ == '__main__':
	cprint(figlet_format('Depl', font='big'), 'green')
	cli()
