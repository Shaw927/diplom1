all:
  children:
    bastion:
      hosts:
        bastion_host:
          ansible_host: ${bastion_ip}
          ansible_user: ubuntu

    web:
      hosts:
%{ for k, ip in web_ips ~}
        web-${k}:
          ansible_host: ${ip}
          ansible_user: ubuntu
%{ endfor ~}
      vars:
        ansible_ssh_common_args: >-
          -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p ubuntu@${bastion_ip}"

    prometheus:
      hosts:
        prometheus_host:
          ansible_host: ${prometheus_ip}
          ansible_user: ubuntu
      vars:
        ansible_ssh_common_args: >-
          -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p ubuntu@${bastion_ip}"

    grafana:
      hosts:
        grafana_host:
          ansible_host: ${grafana_ip}
          ansible_user: ubuntu
      vars:
        ansible_ssh_common_args: >-
          -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p ubuntu@${bastion_ip}"

    elasticsearch:
      hosts:
        elasticsearch_host:
          ansible_host: ${elasticsearch_ip}
          ansible_user: ubuntu
      vars:
        ansible_ssh_common_args: >-
          -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p ubuntu@${bastion_ip}"

    kibana:
      hosts:
        kibana_host:
          ansible_host: ${kibana_ip}
          ansible_user: ubuntu
      vars:
        ansible_ssh_common_args: >-
          -o ProxyCommand="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -W %h:%p ubuntu@${bastion_ip}"

