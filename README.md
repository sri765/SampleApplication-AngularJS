# SampleAngularApp

This project was generated with [Angular CLI](https://github.com/angular/angular-cli) version 8.3.10.

# Deployment
Containers, Kubernetes, ECS, EKS

## How to Deploy this Application to Amazok EKS?

---------------
CI/CD with EKS
---------------

We will create a pipeline for deploying a sample application from Github using CodePipeline.
We will use CodeBuild to build the application and create and push images to ECR.
We will then run the latest pushed image in the EKS cluster.


---------------
Pre-Requisites:
---------------
1. Kubectl [DOC to install]
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





