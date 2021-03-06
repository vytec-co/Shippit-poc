# infra-assignment

Hello,

Thank you very much for your interest in Shippit. As part of the interview process, we would like you to deploy the attached Ruby Sinatra Application to AWS/GCP or any other cloud provider.

## How to run locally
```
bundle install
bundle exec rackup -p 3000
```

To access the application, navigate to your browser to http://localhost:3000/hello-world

## Requirements

As part of the evaluation process we expect the following:
  - Infrastructure as code (eg: terraform, cloudformation, pulumi, aws cdk);
  - Solution to be scalable, highly available, secure and repeatable;
  - A README 
    - Explain your approach, considirations and assumptions you had to make
    - Your other options
    - How can we run the code and recreate the environment
    - What would you add to make this solution production ready?
    - If you had more time, what would you improve?
  - Last but not least being able to access the /hello-world endpoint and see hello world being return

You should expect about 2 days worth of effort to complete this. You will be given 5 days as we understand you have personal and work commitment, feel free to let us know if you've finished early or if you need some more time.

Please send us any materials that you created and we will have a walkthrough of what you have done afterward.

Thank you very much for your time and let us know if you have any questions.

cheers,
Team Shippit



#############################################
Environments to setup for CI-CD:

1. AWS 
2. Github/BitBucket
3. Jenkins 
4. Kubernetes
5. ECS
6. EC2
 

1st approach Using K8S:
1. Write Dockerfile and build an image
2. Upload an image to Private registry/ECR
3. deploy an application into k8s:
    1. write deployment manifest object with replicas
    2. add Horizontal Pod Autoscaler based on the cpu load
    3. write service manifest object
    4. write ingress object wioth application Load balancer.
        ingress ==> service ==> deployment ==> pod

2nd approach Using ECS-Fargate:
  1. Write Dockerfile anmd build an image
  2. Upload an image to Private registry/ECR
  3. deploy an application into ECS:
      1. write task-definitions
      2. create or update task-definitions
      3. deploy service with  desired number of tasks.
      4. scale in and scale out configuation using cloud watch for service
      4. attach loadbalancer.

3rd approach Using EC2 using Terraform and Ansible:
 1. write terraform script to create ec2 instance
 2. write ansible playbook to install bundle and run budle exec command.
 3. create loadbalancer with terraform
 4. attach loadbalancer to ec2 instance as part of playbook.
 5. increase no of host based on cpu load using ASG,Cloudwatch

CI-CD:
  0. create aws account for dev, test, stage, prod environments.
  1. Create Jenkins mutlibranch pipeline to run the jobs with repetitive build, provision and deployment
    1. dev environment going to deploy if gitbranch 'develop' updated.
    2. promote test deployment based on dev testing execution success.
    2. stage environment going to upgrade if gitbranch 'release' updated.
    3. prod environment going to upgrade if gitbranch 'main/master' updated.
    

sourcecode:
 1. Jenkinsfile
 2. terraform scripts, ansible playbooks.
