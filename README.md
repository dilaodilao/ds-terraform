# DroneSense Tofu

## Folder Structure Snippet

```shell
ds-tofu/
├── env/
│   ├── build/
│   │   ├── backend/
│   │   │   ├── backend-bootstrap/
│   │   │   │   ├── backend.tfvars
│   │   │   │   ├── main.tf
│   │   │   │   ├── terraform.tfstate
│   │   │   │   └── variables.tf
│   │   │   └── backend.tf
│   │   ├── cloudwatch/
│   │   │   └── photon/
│   │   ├── compute/
│   │   │   ├── us-east-1/
│   │   │   │   ├── dronesense/
│   │   │   │   └── photon/
│   │   │   │       └── ecs/
│   │   │   │           └── main.tf
│   │   │   └── us-west-2/
│   │   ├── network/
│   │   │   ├── us-east-1/
│   │   │   │   ├── dronesense_vpc/
│   │   │   │   ├── photon_vpc/
│   │   │   │   │   ├── build.tfvars
│   │   │   │   │   ├── main.tf
│   │   │   │   │   └── variables.tf
│   │   │   │   └── product_vpc/
│   │   │   └── us-west-2/
│   │   └── storage/
│   ├── dev/ # dev account 
│   └── nucleus/ # nucleus account
│       └── iam/
│           ├── iam_idc/
│           │   ├── idc_user/
│           │   │   ├── main.tf
│           │   │   └── variables.tf
│           │   └── permission_set/
│           │       ├── dronesense_read_policy.json
│           │       ├── main.tf
│           │       ├── photon_read_policy.json
│           │       └── variables.tf
│           └── idc/
│               ├── main.tf
│               ├── terraform.tfvars
│               └── variables.tf
└── modules/ # reusuable modules folder
    ├── backend/
    │   ├── dynamodb.tf
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    ├── cloudwatch/
    ├── compute/
    │   ├── ec2/
    │   │   ├── ami-builder/
    │   │   └── asg/
    │   └── ecs/
    │       ├── ecs.tf
    │       └── variables.tf
    └── network/
        ├── security-groups/
        │   ├── ec2-dind-gitlab-runner/
        │   └── ecs-gitlab-runner/
        ├── vpc/
        │   ├── flow_logs.tf
        │   ├── nacl.tf
        │   ├── variables.tf
        │   └── vpc.tf
        └── waf/

```

## Running Terraform Manually

When GitLab is online

```shell
cd modules/vpc
tofu init
tofu plan -var-file=../../envs/dev/build-vpc.tfvars
tofu apply -auto-approve
```

If GitLab is down, test locally run the `-backend=false`

```shell
cd modules/vpc
tofu init -backend=false  # Disable remote state
tofu plan -var-file=../../envs/dev/build-vpc.tfvars
tofu apply -auto-approve
```

Once GitLab is back, re-enable remote state with:

```shell
tofo init
```

## Terraform State Isolation

State files are stored separately per environment:

```text
- tofu/build/terraform.tfstate
- tofu/dev/terraform.tfstate
- tofu/qa/terraform.tfstate # <-- example --<
- tofu/ea/terraform.tfstate # <-- example --<
```

Each tfvars file has its own isolated state key (defined in backend.tf).

## Running OpenTofu Locally & in GitLab CI/CD

| Task | Command |
|------|---------|
| **Plan Backend Locally** | `cd modules/backend && tofu plan -var-file=../../env/build/build.tfvars` |
| **Apply Backend Locally** | `cd modules/backend && tofu apply -var-file=../../env/build/build.tfvars -auto-approve` |
| **Destroy Backend Locally** | `cd modules/backend && tofu destroy -var-file=../../env/build/build.tfvars -auto-approve` |
| **Run Terraform in Build Env** | `cd env/build && tofu init && tofu apply -var-file=network.tfvars -auto-approve` |
| **Run Terraform in Dev Env** | `cd env/dev && tofu init && tofu apply -var-file=network.tfvars -auto-approve` |

## 🔥 GitLab CI/CD Pipeline Stages

| Stage | Purpose |
|-------|---------|
| **`validate`** | Ensures Terraform code is formatted and valid. |
| **`plan`** | Generates an execution plan for review. |
| **`apply`** | Deploys the planned changes (requires manual approval). |
| **`rollback`** | If `apply` fails, reverts to the last successful state. |
| **`destroy`** | Destroys the infrastructure (manual approval required). |
| **`import`** | Imports existing AWS resources into Terraform state. |

### 🤸🏻‍♂️ Module & Environment Flexibility

| Stage | Purpose |
|-------|---------|
| **`validate`** | Ensures Terraform code is formatted and valid. |
| **`plan`** | Generates an execution plan for review. |
| **`apply`** | Deploys the planned changes (requires manual approval). |
| **`rollback`** | If `apply` fails, reverts to the last successful state. |
| **`destroy`** | Destroys the infrastructure (manual approval required). |
| **`import`** | Imports existing AWS resources into Terraform state. |

✔ Consistency → Using env/ ensures all environments use the same reusable module structure. *USED IN PIPELINE*

✔ Flexibility → Backend can be created manually first in modules/, then apply infrastructure using env/.

Step 1: Navigate to the env/build/ Directory

```shell
cd env/build
```

Step 2: Initialize OpenTofu with the Correct Backend 

```shell
tofu init -backend-config="bucket=build-tofu-state-bucket" \
          -backend-config="key=tofu/build/backend.tfstate" \
          -backend-config="region=us-east-1" \
          -backend-config="dynamodb_table=build-tofu-lock-table"
```


tofu plan -var-file=build.tfvars

tofu init -reconfigure -backend-config="bucket=build-tofu-state-bucket" \
          -backend-config="key=tofu/build/build-vpc.tfstate" \
          -backend-config="region=us-east-1" \
          -backend-config="dynamodb_table=build-tofu-lock-table"


tofu plan -var-file=vpc-build.tfvars