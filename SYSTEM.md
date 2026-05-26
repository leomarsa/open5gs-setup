# Open5GS — Informações do Sistema e do Projeto

## Sobre o Open5GS

**Open5GS** é uma implementação open-source em linguagem C do 5G Core (5GC) e do
EPC (Evolved Packet Core), cobrindo o núcleo de redes NR/LTE conforme a
especificação **3GPP Release-17**.

Serve para construir e gerenciar redes móveis privadas para fins de testes,
pesquisa e produção.

Site oficial: https://open5gs.org  
Repositório: https://github.com/open5gs/open5gs  
Documentação: https://open5gs.org/open5gs/docs/

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

### Infraestrutura de suporte

| Componente | Versão | Função |
|---|---|---|
| MongoDB | 8.0.21 | Banco de dados de assinantes |
| Open5GS WebUI | — | Interface web de gerenciamento |
| Node.js | 20.20.2 | Runtime do WebUI |

---

## Servidor de referência (server-open5gs)

Este é o servidor onde a instalação foi feita e validada. Use como referência
para confirmar uma instalação bem-sucedida.

| Item | Valor |
|---|---|
| Hostname | server-open5gs |
| OS | Ubuntu 24.04.4 LTS (Noble) |
| Kernel | 6.8.0-117-generic x86_64 |
| CPUs | 4 |
| RAM total | 7.6 GiB |
| Disco (/) | 98 GB (11 GB usados) |
| IP principal | 10.5.100.95 (eno1) |
| Interface UE | ogstun — 10.45.0.1/16 |

### Versões instaladas

| Pacote | Versão |
|---|---|
| open5gs | 2.7.7~noble |
| mongodb-org | 8.0.21 |
| nodejs | 20.20.2 |

### Status dos serviços (referência)

Todos os serviços abaixo devem estar `active (running)` após instalação:

```
mongod.service            active running
open5gs-nrfd.service      active running
open5gs-scpd.service      active running
open5gs-amfd.service      active running
open5gs-smfd.service      active running
open5gs-upfd.service      active running
open5gs-ausfd.service     active running
open5gs-udmd.service      active running
open5gs-udrd.service      active running
open5gs-pcfd.service      active running
open5gs-bsfd.service      active running
open5gs-nssfd.service     active running
open5gs-seppd.service     active running
open5gs-mmed.service      active running
open5gs-sgwcd.service     active running
open5gs-sgwud.service     active running
open5gs-hssd.service      active running
open5gs-pcrfd.service     active running
open5gs-webui.service     active running
```

---

## Configuração de rede aplicada

| Parâmetro | Valor |
|---|---|
| PLMN | MCC=999, MNC=70 |
| TAC | 1 |
| SST | 1 (eMBB) |
| NGAP bind (AMF) | IP do servidor |
| GTP-U bind (UPF) | IP do servidor |
| UE subnet (IPv4) | 10.45.0.0/16 |
| UE subnet (IPv6) | 2001:db8:cafe::/48 |
| IP forwarding | Habilitado via `/etc/sysctl.d/99-open5gs.conf` |
| NAT | iptables MASQUERADE saindo pela interface principal |
| WebUI | http://\<IP\>:9999 — `admin` / `1423` |

---

## Plataformas suportadas pelo Open5GS

O Open5GS pode ser instalado em:

- Ubuntu / Debian
- CentOS / Fedora
- macOS (Intel e Apple Silicon)
- FreeBSD
- Alpine Linux

Este repositório é otimizado para **Ubuntu 24.04 LTS**.
