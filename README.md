# nulll-provider-remove-and-fail-test
Attempt to fail infra with only null provider in a same way as in Galser/tfe-fail-after-infra-change

# Reproducing

### 1. Create code : 

Create a code that looks like : 

```terraform
resource "random_pet" "pet" {
}

resource "null_resource" "non-timed-hello" {
  triggers = {
    pet_name = random_pet.pet.id
  }

  provisioner "local-exec" {
    command = "echo ${random_pet.pet.id}"
  }
}
```

### 2. Plan & Execute in TFE or TFC

Create resources by queuing the run in TFE or TFC
```bash
Terraform will perform the following actions:

  # null_resource.non-timed-hello will be created
  + resource "null_resource" "non-timed-hello" {
      + id       = (known after apply)
      + triggers = (known after apply)
    }

  # random_pet.pet will be created
  + resource "random_pet" "pet" {
      + id        = (known after apply)
      + length    = 2
      + separator = "-"
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Terraform v0.13.5
Initializing plugins and modules...
random_pet.pet: Creating...
random_pet.pet: Creation complete after 0s [id=climbing-manatee]
null_resource.non-timed-hello: Creating...
null_resource.non-timed-hello: Provisioning with 'local-exec'...
null_resource.non-timed-hello (local-exec): Executing: ["/bin/sh" "-c" "echo climbing-manatee"]
null_resource.non-timed-hello (local-exec): climbing-manatee
null_resource.non-timed-hello: Creation complete after 0s [id=2340455927336106694]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

### 3. Remove `null_resource`

Change code so it looks like : 

```terraform
resource "random_pet" "pet" {
}
```

### 4. `Plan` it in TFE or TFC

```bash
Terraform v0.13.5
Configuring remote state backend...
Initializing Terraform configuration...
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

random_pet.pet: Refreshing state... [id=climbing-manatee]
null_resource.non-timed-hello: Refreshing state... [id=2340455927336106694]

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # null_resource.non-timed-hello will be destroyed
  - resource "null_resource" "non-timed-hello" {
      - id       = "2340455927336106694" -> null
      - triggers = {
          - "pet_name" = "climbing-manatee"
        } -> null
    }

Plan: 0 to add, 0 to change, 1 to destroy.
```

Okay all looks good - 1 `null_resource.non-timed-hello will be destroyed`

### 5. Try to `apply` it in TFE/TFC

```bash
Terraform v0.13.5
Initializing plugins and modules...

Error: Could not load plugin


Plugin reinitialization required. Please run "terraform init".

Plugins are external binaries that Terraform uses to access and manipulate
resources. The configuration provided requires plugins which can't be located,
don't satisfy the version constraints, or are otherwise incompatible.

Terraform automatically discovers provider requirements from your
configuration, including providers used in child modules. To see the
requirements and constraints, run "terraform providers".

Failed to instantiate provider "registry.terraform.io/hashicorp/null" to
obtain schema: unknown provider "registry.terraform.io/hashicorp/null"
```

Boom. It had failed. With both TF versions 0.13.15 and 0.12.29 specified on workspace.

## How about TF OSS ?

The very same sequence of changes - not failign in TF OSS or with `local` runs in TF CLI initiated workspaces - well, probably because we have provides schemas and providers locally in `.terraform` folder.



# TODO

- [x] initial code
- [x] test removal
- [x] update readme
