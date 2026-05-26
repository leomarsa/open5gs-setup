# Open5GS Setup — Instruções para Claude Code

Este repositório contém a instalação automatizada e customizada do Open5GS 2.7.7
em Ubuntu 24.04 LTS. **Leia este arquivo inteiro antes de executar qualquer comando.**

---

## Contexto

O usuário quer instalar o Open5GS com uma configuração específica de rede móvel
(PLMN MCC=999/MNC=70) num servidor Ubuntu 24.04. Todo o processo é automatizado
por este repositório — não improvise nem instale por outro método.

---

## Passo a passo completo

### 0. Verificar pré-requisitos

Confirme que está no servidor correto e que o OS é Ubuntu 24.04:

```bash
lsb_release -rs
# Esperado: 24.04
```

Confirme que tem acesso root:

```bash
sudo whoami
# Esperado: root
```

### 1. Clonar o repositório (se ainda não estiver clonado)

```bash
cd ~
git clone https://github.com/leomarsa/open5gs-setup.git
cd open5gs-setup
```

Se o diretório já existir, apenas atualize:

```bash
cd ~/open5gs-setup
git pull
```

### 2. Detectar o IP do servidor

```bash
hostname -I | awk '{print $1}'
```

Anote o IP retornado — ele será usado pelo script automaticamente.

### 3. Executar o script de instalação

**Execute como root a partir do diretório do repositório:**

```bash
cd ~/open5gs-setup
sudo bash scripts/install.sh
```

O script detecta o IP automaticamente. Se precisar forçar um IP específico:

```bash
sudo bash scripts/install.sh 192.168.1.10
```

A instalação leva entre 5 e 15 minutos dependendo da conexão. Aguarde até
aparecer a mensagem `=== Installation complete ===`.

### 4. Verificar os serviços

Todos os serviços devem estar `active`:

```bash
systemctl is-active open5gs-nrfd open5gs-scpd open5gs-amfd open5gs-smfd \
  open5gs-upfd open5gs-ausfd open5gs-udmd open5gs-udrd open5gs-pcfd \
  open5gs-bsfd open5gs-nssfd open5gs-mmed open5gs-sgwcd open5gs-sgwud \
  open5gs-hssd open5gs-pcrfd open5gs-seppd open5gs-webui mongod
```

### 5. Verificar o WebUI

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:9999
# Esperado: 200
```

Acesse pelo navegador: `http://<IP_DO_SERVIDOR>:9999`
- Usuário: `admin`
- Senha: `1423`

### 6. Confirmar a configuração aplicada

```bash
grep -E "mcc|mnc|tac" /etc/open5gs/amf.yaml | head -10
```

Esperado: `mcc: 999`, `mnc: 70`, `tac: 1`

---

## O que é instalado

| Componente | Versão |
|---|---|
| Open5GS | 2.7.7 |
| MongoDB | 8.0 |
| Node.js | 20 (para WebUI) |

**Componentes 5GC:** AMF, SMF, UPF, NRF, SCP, AUSF, UDM, UDR, PCF, BSF, NSSF, SEPP

**Componentes EPC:** MME, SGW-C, SGW-U, HSS, PCRF

---

## Configuração de rede aplicada

| Parâmetro | Valor |
|---|---|
| PLMN | MCC=999, MNC=70 |
| TAC | 1 |
| SST | 1 |
| NGAP (AMF) | IP do servidor (detectado automaticamente) |
| GTP-U (UPF) | IP do servidor (detectado automaticamente) |
| UE subnet | 10.45.0.0/16 |
| IP forwarding | Habilitado via sysctl |
| NAT | iptables MASQUERADE para 10.45.0.0/16 |

---

## Estrutura do repositório

```
open5gs-setup/
├── scripts/
│   └── install.sh              # Script principal de instalação
├── configs/
│   ├── amf.yaml                # Access and Mobility Function
│   ├── smf.yaml                # Session Management Function
│   ├── upf.yaml                # User Plane Function
│   ├── nrf.yaml                # NF Repository Function
│   ├── scp.yaml                # Service Communication Proxy
│   ├── ausf.yaml               # Authentication Server Function
│   ├── udm.yaml                # Unified Data Management
│   ├── udr.yaml                # Unified Data Repository
│   ├── pcf.yaml                # Policy Control Function
│   ├── bsf.yaml                # Binding Support Function
│   ├── nssf.yaml               # Network Slice Selection Function
│   ├── sepp1.yaml / sepp2.yaml # Security Edge Protection Proxy
│   ├── mme.yaml                # Mobility Management Entity (EPC)
│   ├── sgwc.yaml               # Serving GW Control (EPC)
│   ├── sgwu.yaml               # Serving GW User (EPC)
│   ├── hss.yaml                # Home Subscriber Server (EPC)
│   ├── pcrf.yaml               # Policy and Charging Rules (EPC)
│   ├── 99-open5gs.conf         # sysctl — IP forwarding
│   └── freeDiameter/           # Configs Diameter (EPC)
│       ├── mme.conf
│       ├── hss.conf
│       ├── smf.conf
│       └── pcrf.conf
└── CLAUDE.md                   # Este arquivo
```

---

## Diagnóstico de falhas

**Serviço não iniciou:**
```bash
journalctl -u open5gs-amfd -n 50 --no-pager
# Substitua "amfd" pelo nome do serviço com problema
```

**Reiniciar um serviço específico:**
```bash
sudo systemctl restart open5gs-amfd
```

**MongoDB não iniciou:**
```bash
systemctl status mongod
journalctl -u mongod -n 30 --no-pager
```

**WebUI não responde:**
```bash
systemctl status open5gs-webui
journalctl -u open5gs-webui -n 30 --no-pager
```

**IP não foi substituído corretamente nas configs:**
```bash
grep -r "10\.5\.100\.95" /etc/open5gs/
# Se retornar algo, o sed não funcionou — rode manualmente:
sudo sed -i "s/10\.5\.100\.95/<IP_CORRETO>/g" /etc/open5gs/*.yaml
sudo systemctl restart open5gs-amfd open5gs-smfd open5gs-upfd
```
