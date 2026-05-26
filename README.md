# Open5GS 5G Core — Setup Automatizado

Instalação e configuração automatizada do [Open5GS](https://open5gs.org/) em Ubuntu 24.04 LTS,
incluindo MongoDB 8.0, WebUI e todos os componentes 5GC e EPC.

**Open5GS** é uma implementação open-source em C do 5G Core e EPC, cobrindo o núcleo
de redes NR/LTE conforme a especificação **3GPP Release-17**.

---

## Instalação rápida

```bash
git clone https://github.com/leomarsa/open5gs-setup.git
cd open5gs-setup
sudo bash scripts/install.sh
```

O script detecta o IP do servidor automaticamente. Para forçar um IP específico:

```bash
sudo bash scripts/install.sh 192.168.1.10
```

**Pré-requisitos:** Ubuntu 24.04 LTS limpo · acesso root · IP fixo ou conhecido

---

## Stack

| Componente | Versão |
|---|---|
| OS | Ubuntu 24.04 LTS (Noble) |
| Open5GS | 2.7.7~noble |
| MongoDB | 8.0.21 |
| Node.js / WebUI | 20.20.2 |

---

## Componentes instalados

### 5G Core (5GC)

| Sigla | Nome completo | Função |
|---|---|---|
| NRF | NF Repository Function | Registro e descoberta de funções de rede |
| SCP | Service Communication Proxy | Proxy de comunicação entre NFs |
| AMF | Access and Mobility Management Function | Gerenciamento de acesso e mobilidade dos UEs |
| SMF | Session Management Function | Gerenciamento de sessões PDU |
| UPF | User Plane Function | Roteamento de dados do plano de usuário |
| AUSF | Authentication Server Function | Autenticação de UEs |
| UDM | Unified Data Management | Gestão unificada de dados de assinantes |
| UDR | Unified Data Repository | Repositório de dados de assinantes |
| PCF | Policy Control Function | Controle de políticas de rede |
| BSF | Binding Support Function | Suporte a vinculação de sessões |
| NSSF | Network Slice Selection Function | Seleção de network slice |
| SEPP | Security Edge Protection Proxy | Proteção de borda entre PLMNs |

### EPC (LTE Core)

| Sigla | Nome completo | Função |
|---|---|---|
| MME | Mobility Management Entity | Gerenciamento de mobilidade LTE |
| SGW-C | Serving GW Control Plane | Plano de controle do Serving Gateway |
| SGW-U | Serving GW User Plane | Plano de usuário do Serving Gateway |
| HSS | Home Subscriber Server | Servidor de assinantes LTE |
| PCRF | Policy and Charging Rules Function | Políticas e regras de cobrança LTE |

---

## Configuração de rede padrão

| Parâmetro | Valor |
|---|---|
| MCC | 999 |
| MNC | 70 |
| TAC | 1 |
| SST | 1 (eMBB) |
| UE subnet (IPv4) | 10.45.0.0/16 |
| UE subnet (IPv6) | 2001:db8:cafe::/48 |
| IP forwarding | Habilitado via sysctl |
| NAT | iptables MASQUERADE para tráfego das UEs |

---

## Acesso ao WebUI

Após a instalação:

```
http://<IP_DO_SERVIDOR>:9999
Usuário: admin
Senha:   1423
```

---

## O que o script faz

1. Instala dependências do sistema
2. Configura repositório e instala MongoDB 8.0
3. Configura PPA e instala Open5GS 2.7.7
4. Aplica os arquivos de configuração substituindo o IP automaticamente
5. Habilita IP forwarding via sysctl
6. Configura NAT/iptables para tráfego das UEs
7. Instala Node.js 20 e o WebUI
8. Reinicia todos os serviços

---

## Verificar serviços após instalação

Todos os serviços abaixo devem estar `active`:

```bash
systemctl is-active \
  mongod open5gs-nrfd open5gs-scpd open5gs-amfd open5gs-smfd open5gs-upfd \
  open5gs-ausfd open5gs-udmd open5gs-udrd open5gs-pcfd open5gs-bsfd \
  open5gs-nssfd open5gs-seppd open5gs-mmed open5gs-sgwcd open5gs-sgwud \
  open5gs-hssd open5gs-pcrfd open5gs-webui
```

---

## Estrutura do repositório

```
open5gs-setup/
├── scripts/
│   └── install.sh              # Script principal de instalação
├── configs/
│   ├── amf.yaml                # AMF — NGAP aponta para IP do servidor
│   ├── smf.yaml                # SMF — sessões PDU
│   ├── upf.yaml                # UPF — GTP-U aponta para IP do servidor
│   ├── nrf.yaml / scp.yaml
│   ├── ausf.yaml / udm.yaml / udr.yaml
│   ├── pcf.yaml / bsf.yaml / nssf.yaml
│   ├── sepp1.yaml / sepp2.yaml
│   ├── mme.yaml / sgwc.yaml / sgwu.yaml
│   ├── hss.yaml / pcrf.yaml
│   ├── 99-open5gs.conf         # sysctl: ip_forward
│   └── freeDiameter/           # Configs Diameter (EPC)
│       ├── mme.conf
│       ├── hss.conf
│       ├── smf.conf
│       └── pcrf.conf
├── CLAUDE.md                   # Instruções para instalação via Claude Code
└── SYSTEM.md                   # Referência técnica detalhada
```

---

## Customização

Para alterar PLMN (MCC/MNC), edite `configs/amf.yaml` e `configs/mme.yaml`
antes de executar o script, ou após a instalação:

```bash
sudo nano /etc/open5gs/amf.yaml
sudo systemctl restart open5gs-amfd
```

---

## Diagnóstico

```bash
# Logs de um serviço específico
journalctl -u open5gs-amfd -n 50 --no-pager

# Status do MongoDB
systemctl status mongod

# Status do WebUI
systemctl status open5gs-webui
```

---

## Referências

- Site oficial: https://open5gs.org
- Documentação: https://open5gs.org/open5gs/docs/
- Repositório upstream: https://github.com/open5gs/open5gs

---

## Licença

MIT
