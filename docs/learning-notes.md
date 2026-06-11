# Terraform Learning Notes

A plain-language explanation of every concept used in this project.

---

## The Core Mental Model

Terraform reads your `.tf` files and computes the difference between:
- **what exists right now** (stored in `terraform.tfstate`)
- **what you declared** (your `.tf` files)

Then it makes exactly the changes needed to close that gap.
This is called *declarative infrastructure* — you say WHAT you want, not HOW to get there.

---

## Key Concepts

### `terraform init`
Downloads the AWS provider plugin (the code that actually talks to AWS/LocalStack).
Run this once per environment folder, or whenever you add a new provider/module.

### `terraform plan`
A dry run. Shows you a diff of what WILL happen — no changes are made.
Green `+` = will create. Orange `~` = will modify. Red `-` = will destroy.
**Always run plan before apply!**

### `terraform apply`
Executes the plan. Creates/modifies/destroys resources.
Saves the result to `terraform.tfstate`.

### `terraform destroy`
Destroys everything this Terraform config created.
Useful for cleaning up a dev environment to save costs.

---

## File Types

| File                | Purpose                                              |
|---------------------|------------------------------------------------------|
| `main.tf`           | Resource definitions (what to build)                 |
| `variables.tf`      | Variable declarations (what inputs are accepted)     |
| `terraform.tfvars`  | Variable values (the actual input data)              |
| `outputs.tf`        | Values to print after apply                          |
| `versions.tf`       | Lock provider/terraform versions                     |
| `providers.tf`      | Configure providers (auth, region, endpoints)        |
| `terraform.tfstate` | Current state — NEVER edit by hand, commit to git    |

---

## Modules

A module is just a **folder with `.tf` files**. You call it like a function:

```hcl
module "networking" {
  source       = "../../modules/networking"  # path to the folder
  project_name = "myapp"                     # input variables
  environment  = "dev"
}
```

Why use modules?
- **Reusability**: the same networking code serves dev, staging, prod
- **Separation**: each module has a single responsibility
- **Testability**: you can test a module in isolation

---

## Variables vs Locals vs Outputs

```
Variables  = inputs (data comes IN from tfvars or CLI)
Locals     = computed values (calculated inside the module)
Outputs    = exports (data goes OUT to other modules or the terminal)
```

Example:
```hcl
variable "environment" { type = string }           # input

locals {
  name_prefix = "${var.project_name}-${var.environment}"  # computed
}

output "vpc_id" { value = aws_vpc.main.id }        # export
```

---

## Resource References

Reference another resource's attribute:

```hcl
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id   # ← "resource_type.resource_name.attribute"
}
```

Terraform sees this reference and automatically:
1. Creates `aws_vpc.main` first
2. Passes its `.id` to `aws_subnet.public`

This is called an **implicit dependency** — you don't need to declare it manually.

---

## `count` — looping resources

```hcl
resource "aws_subnet" "public" {
  count      = 2                                    # create 2 copies
  cidr_block = var.public_subnet_cidrs[count.index] # index 0, then 1
}

# Access them later:
# aws_subnet.public[0].id  → first subnet
# aws_subnet.public[*].id  → all subnet IDs as a list
```

---

## `merge()` for tags

All resources should be tagged. `merge()` combines two maps:

```hcl
tags = merge(var.tags, {
  Name = "my-specific-resource-name"
})
# Result: all tags from var.tags PLUS the Name tag
```

---

## Security Groups — Ingress vs Egress

```
ingress = traffic coming IN  to the resource
egress  = traffic going  OUT of the resource
```

Security groups are **stateful**: if you allow port 80 in,
the response traffic (port 80 out) is automatically allowed.
You only need egress rules for NEW outbound connections.

---

## The `lifecycle` Block

```hcl
lifecycle {
  create_before_destroy = true
}
```

Normally Terraform destroys the old resource, then creates the new one.
`create_before_destroy = true` reverses this — creates the new one first,
then destroys the old. Essential for zero-downtime deployments.

---

## State File (`terraform.tfstate`)

- JSON file that records every resource Terraform manages
- Must be shared across your team (use S3 + DynamoDB for remote state in production)
- Never commit secrets in tfvars — they end up in state
- Never manually edit — use `terraform state` commands if needed

---

## Recommended Workflow

```bash
# 1. Start LocalStack
docker run --rm -d -p 4566:4566 localstack/localstack

# 2. Go to an environment
cd environments/dev

# 3. Download providers
terraform init

# 4. Preview changes
terraform plan

# 5. Apply
terraform apply

# 6. Check outputs
terraform output

# 7. Tear down when done
terraform destroy
```
