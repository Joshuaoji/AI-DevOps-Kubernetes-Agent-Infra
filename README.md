# AI DevOps Kubernetes Agent Infrastructure

Terraform implementation of the **Tech Tutorials With Piyush** multi-tier Azure architecture, replicated on AWS with **Amazon EKS** replacing the Docker VMSS compute tiers.

## AWS architecture

![AWS infrastructure architecture](./docs/images/aws-architecture.png)

### Request flow

```mermaid
flowchart LR
    Users([Users]) --> WAF[AWS WAF]
    WAF --> PublicALB[Internet-facing ALB]
    PublicALB --> WebPods[web-app pods<br/>EKS web node group]
    WebPods --> InternalALB[Internal ALB]
    InternalALB --> AppPods[app-api pods<br/>EKS app node group]
    AppPods --> RDSPrimary[(RDS PostgreSQL<br/>Primary)]
    AppPods --> RDSReplica[(RDS PostgreSQL<br/>Read Replica)]
    AppPods --> PrivateDNS[Route 53<br/>api.internal.local]
    AppPods --> ECR[Amazon ECR]
    AppPods --> S3[S3 Artifacts]
    AppPods --> Secrets[Secrets Manager<br/>+ KMS]
    AppPods --> NAT[NAT Gateway]
    NAT --> Outbound([Outbound Internet])
    Admin([Administrators]) --> Bastion[Session Manager<br/>Bastion Host]
```

### VPC topology (2 availability zones)

```mermaid
flowchart TB
    subgraph Internet["Internet"]
        Users([Users])
        Outbound([Outbound])
    end

    subgraph AWS["AWS Cloud"]
        WAF[AWS WAF]

        subgraph VPC["VPC 10.0.0.0/16"]
            IGW[Internet Gateway]
            NAT[NAT Gateway]

            subgraph AZ1["Availability Zone 1"]
                AG1["App Gateway Subnet<br/>10.0.0.0/24"]
                WEB1["Web Subnet (public)<br/>10.0.10.0/24"]
                APP1["App Subnet (private)<br/>10.0.20.0/24"]
                DB1["Database Subnet<br/>10.0.30.0/24"]
            end

            subgraph AZ2["Availability Zone 2"]
                AG2["App Gateway Subnet<br/>10.0.1.0/24"]
                WEB2["Web Subnet (public)<br/>10.0.11.0/24"]
                APP2["App Subnet (private)<br/>10.0.21.0/24"]
                DB2["Database Subnet<br/>10.0.31.0/24"]
            end

            BASTION["Bastion Subnet<br/>10.0.40.0/24"]

            PublicALB[Internet-facing ALB]
            InternalALB[Internal ALB]
            EKSWeb[EKS Web Node Group<br/>Helm: web-app]
            EKSApp[EKS App Node Group<br/>Helm: app-api]
            RDSPrimary[(RDS Primary)]
            RDSReplica[(RDS Read Replica)]
            BastionHost[Session Manager Host]
            SSM[SSM VPC Endpoints]
            PrivateDNS[Route 53 Private Zone<br/>internal.local]
        end

        EKSControl[EKS Control Plane]
        ECR[Amazon ECR]
        S3[S3 Buckets]
        KMS[KMS + Secrets Manager]
    end

    Users --> WAF
    WAF --> PublicALB
    PublicALB --> AG1
    PublicALB --> AG2
    PublicALB --> EKSWeb
    EKSWeb --> WEB1
    EKSWeb --> WEB2
    EKSWeb --> InternalALB
    InternalALB --> APP1
    InternalALB --> APP2
    InternalALB --> EKSApp
    EKSApp --> RDSPrimary
    EKSApp --> RDSReplica
    RDSPrimary --> DB1
    RDSReplica --> DB2
    EKSApp --> PrivateDNS
    EKSApp --> NAT
    NAT --> IGW
    IGW --> Outbound
    EKSWeb --> ECR
    EKSApp --> ECR
    EKSApp --> S3
    EKSApp --> KMS
    Admin([Administrators]) --> BastionHost
    BastionHost --> BASTION
    BastionHost --> SSM
    EKSControl -.-> EKSWeb
    EKSControl -.-> EKSApp
```

### Microservices deployment

```mermaid
flowchart LR
    subgraph Helm["Helm Charts"]
        FrontendChart[helm/frontend]
        BackendChart[helm/backend]
    end

    subgraph WebNS["Namespace: web"]
        WebDeploy[Deployment: web-app]
        WebSvc[Service :80]
        WebTGB[TargetGroupBinding]
    end

    subgraph AppNS["Namespace: app"]
        AppDeploy[Deployment: app-api]
        AppSvc[Service :8080]
        AppTGB[TargetGroupBinding]
        AppSA[ServiceAccount + IRSA]
    end

    FrontendChart --> WebDeploy
    BackendChart --> AppDeploy
    WebTGB --> PublicALB[Public ALB Target Group]
    AppTGB --> InternalALB[Internal ALB Target Group]
    WebDeploy --> WebSvc
    AppDeploy --> AppSvc
    AppDeploy --> AppSA
```

## Azure → AWS mapping

| Azure (diagram) | AWS (this repo) |
|-----------------|-----------------|
| Resource Group | Tagged project resources |
| Virtual Network | VPC (`10.0.0.0/16`) |
| App Gateway Subnet + App Gateway + WAF + Public IP | Dedicated appgateway subnets + internet-facing ALB + **AWS WAF** |
| Web Tier NSG + Public Subnets + VMSS (Docker) | Security groups + public web subnets + **EKS web node group** |
| Internal Load Balancers | **Internal ALB** in private app subnets |
| App Tier NSG + Private Subnets + VMSS (Docker) | Security groups + private app subnets + **EKS app node group** |
| Private DNS Zone | **Route 53 private hosted zone** (`internal.local`) |
| DB Tier + PostgreSQL Primary / Read Replica | Database subnets + **RDS PostgreSQL** primary + read replica |
| Bastion Subnet + Azure Bastion | Bastion subnet + **Session Manager bastion** + SSM VPC endpoints |
| Key Vault | **KMS** + **Secrets Manager** |
| Container Registry | **Amazon ECR** |
| NAT Gateway + Public IP | **NAT Gateway** for private subnet egress |

## Repository layout

```
terraform/
  modules/
    vpc/           # Tiered subnets: appgateway, web, app, db, bastion
    eks/           # EKS with separate web and app node groups
    alb/           # Public and internal load balancers
    waf/           # AWS WAF on the public ALB
    rds/           # PostgreSQL primary + read replica
    ecr/           # Container registry
    s3/            # Artifacts and logs buckets
    kms/           # Encryption key (Key Vault equivalent)
    bastion/       # Session Manager host + SSM endpoints
    private-dns/   # Internal service discovery
  environments/
    dev/           # Ready-to-deploy root module
helm/
  frontend/        # Frontend microservice chart (web tier)
  backend/         # Backend API microservice chart (app tier)
  microservices/   # Umbrella chart to deploy both
karpenter/         # Optional Karpenter autoscaling (not enabled by default)
kubernetes/
  aws-load-balancer-controller-values.yaml
  web-target-group-binding.yaml
  app-target-group-binding.yaml
```

## Prerequisites

- Terraform >= 1.5
- AWS CLI with permissions for VPC, EKS, RDS, ALB, WAF, IAM, Route 53, KMS, and S3
- `kubectl` and `helm` for post-deploy Kubernetes setup

## Deploy

```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Post-deploy

1. Configure `kubectl`:

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

2. Deploy the frontend and backend microservices with Helm:

```bash
# See helm/README.md for full commands
helm upgrade --install app-api ./helm/backend --namespace app --create-namespace ...
helm upgrade --install web-app ./helm/frontend --namespace web --create-namespace ...
```

3. Access the bastion host via Session Manager:

```bash
aws ssm start-session --target <bastion-instance-id>
```

## Key outputs

- `public_alb_dns_name` — public entry point (App Gateway equivalent)
- `internal_api_fqdn` — private DNS name for the app API (`api.internal.local`)
- `eks_cluster_name` / `configure_kubectl`
- `ecr_repository_urls`
- `rds_primary_endpoint` / `rds_replica_endpoint`
- `bastion_instance_id`

## Customization

Edit `terraform/environments/dev/terraform.tfvars`:

- `domain_name` + `acm_certificate_arn` for HTTPS and custom public DNS
- `web_*` and `app_*` sizing for each EKS node group
- `create_read_replica = false` to disable the read replica
- `single_nat_gateway = false` for HA NAT in production

## Cost notes

This stack creates billable resources including NAT Gateway, EKS control plane, EC2 nodes, RDS, ALB, and WAF. Use `terraform destroy` in non-production environments when finished.

## License

See [LICENSE](LICENSE).
