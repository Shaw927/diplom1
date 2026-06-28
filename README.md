
# Дипломный проект — Отказоустойчивая инфраструктура в Yandex Cloud

Инфраструктура разворачивается автоматически с помощью Terraform и настраивается через Ansible.

---

## Что включено

| Компонент | Роль |
|---|---|
| 2× Web-сервера (nginx) | Обслуживают HTTP-трафик, расположены в разных зонах доступности |
| Application Load Balancer | Распределяет трафик между веб-серверами |
| Bastion host | Единственная точка SSH-доступа ко всей инфраструктуре |
| Prometheus | Сбор метрик с серверов (node_exporter, nginx exporter) |
| Grafana | Визуализация метрик |
| Elasticsearch | Хранение логов |
| Kibana | Просмотр и поиск по логам |

---

## Сетевая архитектура

- **Публичная подсеть** — Bastion, Grafana, Kibana
- **Приватные подсети** (ru-central1-a, ru-central1-b) — веб-серверы, Elasticsearch
- Веб-серверы и Elasticsearch не имеют публичных IP, выходят в интернет через NAT-шлюз
- Доступ к сервисам мониторинга и логирования — только через SSH-туннель с Bastion

### Security Groups

- Интернет → Ip bastion :22
- Bastion  → Web :22, Prometheus :22, Grafana :22, Kibana :22, Elasticsearch :22
- ALB      → Web :80
- Prometheus → Web :9100, :4040 (метрики)
- Web      → Elasticsearch :9200 (Filebeat)
- Kibana   → Elasticsearch :9200
- Grafana  → доступна только через bastion :3000
- Kibana   → доступна только через bastion :5601

## Быстрый старт

### 1. Terraform

```bash
cd terraform

export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)

terraform init
terraform plan
terraform apply
```
### 2. Ansible

Тут достачно одного плейбука для запуска всех плейбуков в правильном порядке
```bash
cd ansible
ansible-playbook playbooks/deploy-all.yml
```

## Доступ к интерфейсам
```bash
# Grafana
ssh -L 3000:<grafana_private_ip>:3000 ubuntu@<bastion_public_ip>
# → http://localhost:3000

# Kibana
ssh -L 5601:<kibana_private_ip>:5601 ubuntu@<bastion_public_ip>
# → http://localhost:5601

# Prometheus
ssh -L 9090:<prometheus_private_ip>:9090 ubuntu@<bastion_public_ip>
# → http://localhost:9090
```
ip можено посмотреть в вебке или по команде:
terraform output

## Требования
•	Terraform >= 1.5

•	Ansible >= 2.14

•	Yandex Cloud CLI ( yc ) настроен и авторизован

•	SSH-ключ в яндексе настроен
