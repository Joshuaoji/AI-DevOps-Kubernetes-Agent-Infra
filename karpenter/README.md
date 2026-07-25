# Karpenter (Optional)

Optional [Karpenter](https://karpenter.sh/) autoscaling for the EKS cluster provisioned by the main Terraform stack.

**This folder is opt-in.** The default architecture continues to use EKS managed node groups and the Cluster Autoscaler. Nothing in `terraform/environments/dev` or the Helm charts is changed when you add Karpenter.

## When to use Karpenter

Use Karpenter if you want:

- Faster, workload-driven node provisioning
- Bin-packing and consolidation of underutilized nodes
- Flexible instance type selection per tier (`web` / `app`)

Keep the default managed node groups if you prefer the simpler, fully Terraform-managed baseline.

## Coexistence

Karpenter can run **alongside** the existing managed node groups:

| Component | Default stack | With Karpenter (optional) |
|-----------|---------------|---------------------------|
| Web tier nodes | EKS managed node group (`tier: web`) | Optional `NodePool: web` |
| App tier nodes | EKS managed node group (`tier: app`) | Optional `NodePool: app` |
| Scale-out | Cluster Autoscaler | Karpenter provisioner |
| Baseline capacity | Managed node groups (unchanged) | Can remain as fallback |

To migrate a tier to Karpenter later, scale the matching managed node group to `0` and ensure workloads keep their `nodeSelector: tier: web|app` labels.

## Folder layout

```
karpenter/
  README.md
  terraform/          # Optional IAM, SQS, subnet discovery tags
  helm/               # Karpenter controller Helm values
  manifests/          # EC2NodeClass + NodePool per tier
```

## Prerequisites

1. Main infrastructure deployed (`terraform/environments/dev`)
2. `kubectl` configured for the cluster
3. `helm` 3.x

## 1. Apply optional Karpenter Terraform

```bash
cd karpenter/terraform
cp terraform.tfvars.example terraform.tfvars
```

Populate `terraform.tfvars` from the main stack:

```bash
cd ../../terraform/environments/dev

export CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
export WEB_SUBNETS=$(terraform console <<< 'join(",", module.vpc.web_subnet_ids)' | tr -d '"')
export APP_SUBNETS=$(terraform console <<< 'join(",", module.vpc.app_subnet_ids)' | tr -d '"')
```

Edit `karpenter/terraform/terraform.tfvars` with those values, then:

```bash
cd ../../karpenter/terraform
terraform init
terraform plan
terraform apply
```

## 2. Install the Karpenter controller

```bash
export KARPENTER_VERSION=1.0.6
export CLUSTER_NAME=$(terraform output -raw cluster_name)
export KARPENTER_CONTROLLER_ROLE_ARN=$(terraform output -raw karpenter_controller_role_arn)
export INTERRUPTION_QUEUE=$(terraform output -raw karpenter_interruption_queue_name)

helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version "${KARPENTER_VERSION}" \
  --namespace kube-system \
  --create-namespace \
  --values ../helm/values.yaml \
  --set settings.clusterName="${CLUSTER_NAME}" \
  --set settings.interruptionQueue="${INTERRUPTION_QUEUE}" \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="${KARPENTER_CONTROLLER_ROLE_ARN}"
```

## 3. Apply NodePools and EC2NodeClasses

Replace placeholders in the manifests, then apply:

```bash
export CLUSTER_NAME=$(terraform -chdir=../terraform output -raw cluster_name)
export NODE_ROLE=$(terraform -chdir=../terraform output -raw karpenter_node_role_name)

sed "s/REPLACE_CLUSTER_NAME/${CLUSTER_NAME}/g; s/REPLACE_NODE_ROLE/${NODE_ROLE}/g" \
  ../manifests/ec2nodeclass-web.yaml | kubectl apply -f -

sed "s/REPLACE_CLUSTER_NAME/${CLUSTER_NAME}/g; s/REPLACE_NODE_ROLE/${NODE_ROLE}/g" \
  ../manifests/ec2nodeclass-app.yaml | kubectl apply -f -

kubectl apply -f ../manifests/nodepool-web.yaml
kubectl apply -f ../manifests/nodepool-app.yaml
```

## 4. Verify

```bash
kubectl get nodepools
kubectl get ec2nodeclasses
kubectl get nodes -L tier,karpenter.sh/nodepool
```

## Uninstall (optional)

```bash
kubectl delete -f ../manifests/nodepool-web.yaml
kubectl delete -f ../manifests/nodepool-app.yaml
helm uninstall karpenter -n kube-system
terraform destroy
```

## Notes

- NodePools use the same `tier: web` and `tier: app` labels as the Helm microservice charts.
- Web nodes launch in **web subnets**; app nodes launch in **app subnets**, matching the existing tiered network design.
- Review [Karpenter disruption budgets](https://karpenter.sh/docs/concepts/disruption/) before production cutover.
