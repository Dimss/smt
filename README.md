# Smava technical task

## Components  
I've created 3 decoupled component which allowing to run hellowrold.war service in hight available fully automated environment. 
In the git repo, you'll find 3 folders, for each component 


#### tf  

Terraform code, which is manage infra part as infrastructure as a code pattern on top of AWS platform. Terraform creates the following components 
   - Custom VPC
   - Private subnet
   - Public subnet
   - Nat Gateway 
   - Internet Gateway 
   - Routes tables for each subnet 
   - Security group 
   - Launch configuration and ASG for Nginx reverse proxy servers in private subnet
   - ELB for Nginx reverse proxy ASG
   - Bastion EC2 instance in public subnet 
   - ECS cluster
   - Service discovery private DNS namespace 
   - Service discovery service

#### helloworld-app 

   - Dockerfile: Alpine Docker image with glibc, include Oracle Java 8 and helloworld.war

#### deployment 

   - Boto3 (Python3.6) script `dp.py` for deployment docker image into ECS cluster
   

## Usage 
1. Start with infrastructure setup
     - `cd tf`
     - `terraform init`
     - `terraform plan`
     - `terraform apply`
    
     The `terraform apply` cmd provide following output. 
     
     - The Nginx reveres proxy ELB A record `helloworld_elb = rproxy-elb-1586395083.eu-west-1.elb.amazonaws.com`  
     - Private subnets `private_subnest = [subnet-04a99523f8ca1c1fc,subnet-0e6eb6f54c32177cd]`  
     - Security group ID `security_group = sg-070a3d3a4f483abb1`
     - Service discovery ARN `sd_service_arn = arn:aws:servicediscovery:eu-west-1:776404332921:service/srv-t264ff5f52edgl3w`
    
     The above terraform outputs are required for deployment script. 
     Deployment scripts implementing Boto3 ECS API for creating ECS `tasks` and `service`

2. Build docker image 
    - `cd hellowrold-app`
    - `docker build -t image_name:tag`
    - `docker push image_name:tag`

3. Configured deployment script
    - To manage Python3.6 dependencies, I'm using pipenv (https://github.com/pypa/pipenv) tool. To be able to run the script do the following
      - `pip install pipenv (or use any other installation method https://pypi.org/project/pipenv/)`
      - `cd deployment`
      - `pipenv install` 
      - `pipenv run dp` if everything configured correctly you'll see the help output 
     
    - When you've executed `terrafrom apply` you've got 4 outputs parameters, use them in `dp.ini` file
      - `cd deployment && vim dp.ini` 
      - `sd_service_arn` value should be set to the terraform output of `sd_service_arn`
      - `subnets` value should be set to the terraform output of `private_subnest`
      - `security_groups` value should be set to the terraform output of `security_group`
    
        Full example of the dp.ini file
        ```
        [aws]
        region = eu-west-1
        [ecs]
        task_name=hw_task
        service_name=hw_svc
        ecs_cluster_name = SMTCluster
        sd_service_arn = arn:aws:servicediscovery:eu-west-1:776404332921:service/srv-t264ff5f52edgl3w
        subnets =  subnet-04a99523f8ca1c1fc,subnet-0e6eb6f54c32177cd
        security_groups = sg-070a3d3a4f483abb1
        ```

 4. HelloWorld deployment.
  
     Once the dp.ini file is configured correctly you are ready to start to deploy the helloworld service
       - Create a ECS task and revisions for different versions of helloworld.war
         - Create task example cmd `pipenv run dp create-task dimssss/hw:0.2` 
       - Create a ECS service
         - First, list available tasks by `pipenv run dp list-tasks`
         - Chose the task ARN from the previous command and pass it to create-service cmd `pipenv run dp create-service arn:aws:ecs:eu-west-1:776404332921:task-definition/hw_task:4`
       - Update a ECS service ( change the replica count or helloworld.war version)
         - Update replicas count `pipenv run dp update-service arn:aws:ecs:eu-west-1:776404332921:task-definition/hw_task:4 --replicas 2`
       - List all tasks
         - Example cmd `pipenv run dp list-tasks`
       - Delete service
         - Example cmd `pipenv run dp delete-service`
       - Delete all tasks
         - Example cmd `pipenv run dp delete-tasks` 

5. Test the deployment.
     
     Get the terraform value of `helloworld_elb` output. In our case `helloworld_elb = rproxy-elb-1586395083.eu-west-1.elb.amazonaws.com`
     Open a web browser and try to access to helloworld app
      - http://rproxy-elb-1586395083.eu-west-1.elb.amazonaws.com
      - https://rproxy-elb-1586395083.eu-west-1.elb.amazonaws.com

## Cleanup 
There are two steps in cleanup process 
1. Delete ECS service and tasks
   1. `cd deployment` 
   2. `pipenv run dp delete-service`
   3. `pipenv run dp delete-tasks`
2. Execute terraform destroy
   1. `cd tf`
   2. `terraform destroy`  
   