output "keypair_name" {
  value = aws_key_pair.deployer.key_name
}
output "public_key" {
  value = tls_private_key.pk.public_key_openssh
}