# Helm Microservices

Helm charts for deploying the **frontend** and **backend** as separate microservices on the EKS cluster provisioned by Terraform.

## Charts

| Chart | Namespace | Service | Port | Node tier | Load balancer |
|-------|-----------|---------|------|-----------|---------------|
| `frontend` | `web` | `web-app` | 80 | `web` | Public ALB |
| `backend` | `app` | `app-api` | 8080 | `app` | Internal ALB |
| `microservices` | both | umbrella chart | — | — | deploys both |

## Prerequisites

1. EKS cluster deployed via Terraform
2. `kubectl` configured
3. Container images pushed to ECR
4. AWS Load Balancer Controller installed (for `TargetGroupBinding` resources)

## Quick start

### 1. Get Terraform outputs

```bash
cd terraform/environments/dev
terraform output -json > /tmp/tf-outputs.json

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo us-east-1)
export PUBLIC_TG_ARN=$(terraform output -raw public_alb_target_group_arn)
export INTERNAL_TG_ARN=$(terraform output -raw internal_alb_target_group_arn)
export APP_ROLE_ARN=$(terraform output -raw app_service_account_role_arn)
```

### 2. Deploy individually

**Backend (deploy first):**

```bash
helm upgrade --install app-api ./helm/backend \
  --namespace app \
  --create-namespace \
  --set image.repository="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/app-api" \
  --set image.tag=latest \
  --set targetGroupBinding.targetGroupARN="${INTERNAL_TG_ARN}" \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="${APP_ROLE_ARN}"
```

**Frontend:**

```bash
helm upgrade --install web-app ./helm/frontend \
  --namespace web \
  --create-namespace \
  --set image.repository="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/web-app" \
  --set image.tag=latest \
  --set targetGroupBinding.targetGroupARN="${PUBLIC_TG_ARN}" \
  --set env[0].name=BACKEND_API_URL \
  --set env[0].value="http://api.internal.local"
```

### 3. Deploy both with the umbrella chart

```bash
cd helm/microservices
helm dependency update

helm upgrade --install microservices . \
  --set frontend.image.repository="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/web-app" \
  --set frontend.targetGroupBinding.targetGroupARN="${PUBLIC_TG_ARN}" \
  --set backend.image.repository="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/app-api" \
  --set backend.targetGroupBinding.targetGroupARN="${INTERNAL_TG_ARN}" \
  --set backend.serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="${APP_ROLE_ARN}"
```

## Configuration

Each chart supports common Kubernetes settings via `values.yaml`:

- `replicaCount` / `autoscaling`
- `resources` and health probes
- `nodeSelector` (`tier: web` or `tier: app`)
- `targetGroupBinding` to register pods with Terraform-created ALB target groups
- `serviceAccount.annotations` for IRSA on the backend

### Backend database credentials

Create a Kubernetes secret from Secrets Manager, or enable the chart secret:

```bash
helm upgrade --install app-api ./helm/backend \
  --namespace app \
  --set secrets.create=true \
  --set-string secrets.data.DATABASE_URL="postgres://..."
```

For production, prefer [External Secrets Operator](https://external-secrets.io/) synced from AWS Secrets Manager.

## Verify

```bash
kubectl get pods -n web
kubectl get pods -n app
kubectl get targetgroupbinding -A
```

## Uninstall

```bash
helm uninstall web-app -n web
helm uninstall app-api -n app
```
