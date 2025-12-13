apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${certificate_authority_data}
    server: ${server}
  name: ${cluster}
contexts:
- context:
    cluster: ${cluster}
    user: ${user}
  name: ${context}
current-context: ${context}
kind: Config
preferences: {}
users:
- name: ${user}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - --region
      - ${aws_region}
      - eks
      - get-token
      - --cluster-name
      - ${aws_cluster_name}
      - --output
      - json
      command: aws