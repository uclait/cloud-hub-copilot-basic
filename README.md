# cloud-hub-copilot-basic
This is a basic copilot deployment repository with a static website. The pre-reqs and steps for deployment are below. The site being hosted is a static dashboard sample from the internet. The base image referenced is Alpine Linux with nginx installed. There are no customizations to the OS or the webserver in question. The dockerfile reflects the simples point A to point B deployment.

## Prerequisites for repository
Download\install the latest aws cli:
https://aws.amazon.com/cli/

* Setup your aws credentials by running `aws configure` command. This will prompt you for your key and secret.

Download\install the latest aws co-pilot cli for your operating system:
https://aws.github.io/copilot-cli/docs/getting-started/install/

## Setting up your initial application
In the co-pilot world, the base workstream is called an application. Applications are made up of environments which contain scheduled tasks, services, and other units of work within container(s). An example could be that you're the workstream "Finance" so your app might be named finance with an environment like `qa` and full of services that are actualy developed applications within the workstram (journal, eft, etc.) To begin, we must define our application.

### Creating the application and service
The following command tells copilot we want to initialize an app and we have an existing domain setup within our organization and route 53 service. This setup will be a separate topic or added here at a later date.

copilot app init --domain some_domain_provided_by_operations.dev.r53.aws.it.ucla.edu

If you do not have a domain, you can alternatively run

copilot app init 

*This command will generate a root domain entry in route 53 for you that will tie to aws, not UCLA on completion of the steps after the command. 

The command should then ask you to name your application. After naming your application, you should be prompted to select a service type. For this particular repository, we're creating a load balanced web service. After selecting the service type, you'll be prompted to name your service. You can name it according to your team naming conventions or if you're simply doing this guide as tutorial, you could use your name or any name for that matter. Next, it will ask you to specify where the image or dockerFile resides. In this case we can just select ./dockerfile, however; if you had an image that already exists in ECR, you could specificy the ECR address as well. Next, it will ask you what port to expost on the container it generates. For our guide, we'll be exposing port 80 although some web servers use port 8080 or other configurations. Note, this is not the port exposed out to the world/ucla/your audience. This is the port internal to the container. Finally, you'll be prompted to deploy a test environment. In our case, we want to customize our environment a bit, so we select No (type N and press return).

At this point copilot will execute a series of standard cloud formation templates with some of our options inserted to generate a base within our account to work from. Much of this work is generating IAM roles, Parameter Store parameters, and ECR repositories.

### Creating the environment
Once our application is created, we'll want to create our environment within the application. The following command initializes and environment configuration creation locally (not on aws) unless you specify to deploy as part of the questions at the end. In this first example, we're telling copilot we want to initialize an environment called `test` which will house any services, scheduled tasks, or other units of work we want to deploy. We're also telling copilot which utilizes the `aws cli` we downladed earlier (or you already have installed) that we want to use our default profile (this may vary by user, but generally its default). Next, we're telling copilot that we already have a vpc we want to use. It should be noted at this point that all landing zone accounts from UCLA contain a single vpc, 2 public subnets, and 2 private subnets, which is what we'll use here. You can find the values for these various ID(s) within the aws console under the EC2 section, usually under navigation on the left. So back to the command. We've told it the name of the environment, the vpc we want to use, the public subnets we want to use and the private subnets we want to use. Each of these attributes are technically optional, but we do use them significantly.

copilot env init --name test --profile default --import-vpc-id vpc-Id --import-public-subnets subnet-id-1,subnet-id-2 --import-private-subnets subnet-id-3,subnet-id-4

Alternatively, if this isn't UCLA specific, you can simply run the following command which will create the vpc and subnets upon deployment:

copilot env init --name test --profile default

This command will generate the necessary CloudFormation stacks for the environment which will include the provisioning of the ECS cluster (empty) and any roles or policies needed to add services to that cluster and run them. Once created, we will have an empty cluster waiting for our use.

### Deploying the service
Getting our defined service into aws is a single command away! With this command we're telling copilot we want to deploy the service with the name we specify to the environment we specify.

copilot svc deploy --name name-of-service-we-used-previously --env name-of-envirnment-we-created

Upon running this command, copilot will generate and run CloudFormation(CFN) Templates modifying the infrastructure and deploying the application to our specifications. After a few short minutes, the command should complete (it will list the tasks its trying to accomplish) and finally spit out an active url you can copy and view.

### Assuming you want a pipeline
Oh boy, here we go... pipelines are the real bread and butter of migrating to the cloud. You can deploy all the apps in the world into your cloud account, but if you can't properly maintain or update them, you're going to be in a world of hurt. That's where AWS CodePipeline and CodeBuild come into play. 