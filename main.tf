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
