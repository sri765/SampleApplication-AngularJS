# SampleAngularApp

This project was generated with [Angular CLI](https://github.com/angular/angular-cli) version 8.3.10.

# Deployment
Containers, Kubernetes, ECS, EKS

## How to Deploy a sample Application to Amazok EKS and configure CI/CD with it?

This section contains steps to create cluster in two ways:
 - Using EKSCTL
 - Using Console

---------------
CI/CD with EKS : USING EKSCTL
---------------

We will create a pipeline for deploying a sample application from Github using CodePipeline.
We will use CodeBuild to build the application and create and push images to ECR.
We will then run the latest pushed image in the EKS cluster.


---------------
Pre-Requisites:
---------------
1. Kubectl [https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html]
2. EKSCTL [https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html]

--------
Install
--------
Commands:

   curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/darwin/amd64/kubectl
   
   chmod +x ./kubectl
   
   ./kubectl

Verify: kubectl version


------------------
Create EKS Cluster
------------------

Note: 
    - You have less than 5 VPCs or the stack will fail.
    - Please note down the NodeInstanceRoleARN obtained by the worker nodes.

Commands:
	- eksctl create cluster --name <cluster_name> --version 1.14 --region <region> --nodegroup-name standard-workers 		--node-type t2.micro --nodes 3 --nodes-min 1 --nodes-max 4 --node-ami auto

	 aws eks update-kubeconfig --name <cluster_name> --region us-east-2


Result:
	- Creates an EKS cluster with 3 worker nodes.
	- Adds the cluster creator to kubeconfig.


-------------------
Create the pipeline
-------------------

--------------
Pre-requisites
--------------

Repository:

	- https://github.com/ashwanijha04/SampleApplication-AngularJS
	- Branch: 
		- master

Commands [To be run in machine with kubectl before creating the pipeline]:

    git clone https://github.com/ashwanijha04/SampleApplication-AngularJS.git
    cd SampleApplication-AngularJS.git

TODO:
    - MapRoles in the aws-auth.yaml file from the downloaded github repository. Update the file and save. Use the NodeInstanceRoleARN of the worker nodes noted from above.
    - Apply ( kubectl apply - f aws-auth.yaml )

-------------
Steps
--------------

1. CodePipeline Console: https://console.aws.amazon.com/codesuite/codepipeline/pipelines?region=us-east-1

    - Create pipeline
    	- Source: Github (Choose the above repository or fork it in your own repo.)
    			- Connect to Github
    			- Repository: ashwanijha04/SampleApplication-AngularJS
    			- Branch: Master
    			- Detection mode: AWS Codepipeline
    			- Next: Choose Build provider.

    	- Build:
    		The buildspec file is already included in the repository.
    		Create a new build project. Type a project name.


		- Environment:

			- Managed Image: Ubuntu [aws/codebuild/standard:1.0]

			- ENV Variables:[Please note that you need an existing ECR repository to push images to]
 
 				- EKS_KUBECTL_ROLE_ARN: [Service role used by CodeBuild to assume the role to ask master node to schedule pods on the worker nodes.]
 				- AWS_ACCOUNT_ID
 				- IMAGE_REPO_NAME
 				- IMAGE_TAG
 				- EKS_CLUSTER_NAME

 			[You can either use ECR images or change the 'CONTAINER_NAME' (in hello-k8s.yaml) to 'nginx' if you do not wish to use ECR]


 		Note: 
 			- Do not specify buildspec. It is already included in the repository.
 			- No deploy stage. We are done. We will deploy to the cluster directly from buildspec.



------------------
Run the Application
------------------

Verify the pod: kubectl get pods
Get the LB URL: kubectl get svc

The load balancer should start showing up the application. Please wait for atleast one minute after the build finishes to see the changes.


---------------
CI/CD with EKS : USING CONSOLE
---------------

----------------------------
Creating an EKS cluster
----------------------------

1. Creating the Master Node

     - Go to the EKS console and choose create cluster and fill in the details like VPC, Subnets and Security Group. [Save the VPC, Subnets configuration since that will be used with the worker nodes also]

2. Creating the Worker Nodes

     - The worker nodes are created using a CloudFormation template which is mentioned in the documentation.
     - Please note the NodeInstanceRole ARN because we will need to add this to configMap so that the pods can be placed on this. 
     - Please use the VPC, Subnets and Security Group which you have used earlier to create your master.
     - Your master node and the worker nodes need to have the same network configuration.
     - Please record your NodeInstanceRole ARN(s) returned by the stack because we will need this later.

Please click on the below link to create the worker nodes:
    https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?templateURL=https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-10-08/amazon-eks-nodegroup.yaml&param_NodeImageIdSSMParam=/aws/service/eks/optimized-ami/1.14/amazon-linux-2/recommended/image_id

For more information on creating the cluster, please refer to the given documentation:
    https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html

------------------------
Setting things up
------------------------

 1. Clone the following sample repository: [https://github.com/ashwanijha04/SampleApplication-AngularJS] and cd into the directory.
---------
	git clone https://github.com/ashwanijha04/SampleApplication-AngularJS
	cd SampleApplication-AngularJS/
	
---------

 2. Install kubectl in your local machine/EC2 instance: We will use kubectl to talk to the master node.
--------
   curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/darwin/amd64/kubectl
   chmod +x ./kubectl
   ./kubectl
Verify: kubectl version

--------

3. Update the kubeconfig file with the correct cluster name.
--------
	aws eks update-kubeconfig --name $EKS_CLUSTER_NAME
	
--------


4. Creating the role 'EKS_KUBECTL_ROLE'.
------
Create a role and give it the required permissions you need. You can select AdministratorAccess for test.
Note its ARN.

------

5. Edit the file aws-auth.yaml to add the required roles(add EKS_KUBECTL_ROLE_ARN and NodeInstanceRoleARNs for the worker nodes as noted above) and apply it in your local machine. In your local machine where kubectl was installed and update-kubeconfig was run, we need to run the following command:
-------
	kubectl apply -f aws-auth.yaml
	
------

6. Now, we are done with the EKS part.

----------------------------
Creating the pipeline
----------------------------

1. Go to the CodePipeline Console and create a pipeline.
2. We will only select the source and build provider.
3. We do not need the deploy stage because the last command in CodeBuild: [kubectl apply -f hello-k8s.yml] will help us to launch this pod in the EKS worker nodes.
4. Source: Github, Build: CodeBuild
5. CodeBuild Environment: Ubuntu [aws/codebuild/standard:1.0]

Environment Variables: [Please note that you need an existing ECR repository to push images to]
--------------------
 - EKS_KUBECTL_ROLE_ARN: Used by CodeBuild to assume the role to ask master node to schedule pods on the worker nodes.
 - AWS_ACCOUNT_ID: Used for ECR Repository.
 - IMAGE_REPO_NAME: Already created ECR Repository name.
 - IMAGE_TAG: The image tag 
 - EKS_CLUSTER_NAME: The name of the EKS cluster.

6. Leave everything default and select the CodeBuild Role with permissions for ECR and STS_ASSUME_ROLE.
7. I have already written the Dockerfile and the pod file[hello-k8s] for you. Please use them at your own discretion and test it before use in production.
