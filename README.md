# 🚀 HashiCorp Vault HA com Nginx Load Balancer via Vagrant + Libvirt

Este projeto automatiza a criação de um **cluster HashiCorp Vault em modo High Availability (HA)** utilizando **Vagrant** com o provider **libvirt**.  
Além do cluster Vault, o ambiente inclui uma VM dedicada com **Nginx** atuando como **Load Balancer TLS passthrough**, permitindo o acesso unificado e seguro ao Vault.

---

## 📖 Índice

1. [Visão Geral](#-visão-geral)
2. [Arquitetura](#-arquitetura)
3. [Requisitos](#requisitos)
4. [Script `init.sh` (para subir tudo)](#script-initsh-para-subir-tudo)  
---

## 📌 Visão Geral

O objetivo é fornecer um ambiente pronto para testes e estudos de **Vault em HA**, incluindo balanceamento de carga com Nginx.  
Isso facilita explorar:
- **Clusterização do Vault** (líder, seguidores).
- **Load Balancing com TLS passthrough**.
- **Provisionamento automatizado** via Ansible integrado ao Vagrant.

---

## 🏗️ Arquitetura

O ambiente cria 4 VMs:

- **vault-node1** → Nó principal do Vault (elegível a líder).
- **vault-node2** → Nó seguidor.
- **vault-node3** → Nó seguidor.
- **nginx** → Load Balancer TLS passthrough para os nós Vault.

---

## Requisitos

No **host** (sistema que roda Vagrant/libvirt):

- Vagrant (recomendado >= 2.2.x)  
- libvirt + qemu/KVM  
- Plugin: `vagrant-libvirt`
  ```bash
  vagrant plugin install vagrant-libvirt
  ```
- Ansible (>= 2.9) — usado para provisionar as VMs após `vagrant up`  
- `jq` (opcional, para manipular JSON durante init/unseal)

Verifique plugin libvirt:
```bash
vagrant plugin list | grep libvirt
```

---
## Script `init.sh` (para subir tudo)

Um script simples que sobe as máquinas. necessário `chmod +x init.sh`.

