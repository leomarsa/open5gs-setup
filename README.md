# Open5GS 5G Core — Setup Automatizado

Instalação e configuração do [Open5GS](https://open5gs.org/) v2.7.7 em Ubuntu 24.04 LTS (Noble), incluindo MongoDB 8.0 e WebUI.

## Stack

| Componente | Versão |
|---|---|
| OS | Ubuntu 24.04 LTS (Noble) |
| Open5GS | 2.7.7~noble |
| MongoDB | 8.0 |
| Node.js / WebUI | 20.x |

## PLMN padrão

| Parâmetro | Valor |
|---|---|
| MCC | 999 |
| MNC | 70 |
| TAC | 1 |
| SST | 1 |

## Pré-requisitos

- Ubuntu 24.04 LTS limpo
- Acesso root ou sudo
- IP fixo ou conhecido do servidor

## Instalação rápida

```bash
git clone https://github.com/leomarsa/open5gs-setup.git
cd open5gs-setup
sudo bash scripts/install.sh <IP_DO_SERVIDOR>
```

Exemplo:
```bash
sudo bash scripts/install.sh 192.168.1.10
```

O script detecta automaticamente o IP principal da máquina se omitido.

## O que o script faz

1. Instala dependências do sistema
2. Configura repositório e instala MongoDB 8.0
3. Configura repositório PPA e instala Open5GS
4. Aplica os arquivos de configuração deste repositório substituindo o IP placeholder pelo IP real do servidor
5. Habilita IP forwarding (sysctl)
6. Configura NAT/iptables para tráfego das UEs (10.45.0.0/16)
7. Instala Node.js 20 e o WebUI do Open5GS
8. Reinicia todos os serviços

## Acesso ao WebUI

Após a instalação:

```
http://<IP_DO_SERVIDOR>:9999
Usuário: admin
Senha:   1423
```

## Estrutura do repositório

```
open5gs-setup/
├── configs/
│   ├── amf.yaml        # AMF — NGAP aponta para IP do servidor
│   ├── upf.yaml        # UPF — GTP-U aponta para IP do servidor
│   ├── smf.yaml
│   ├── nrf.yaml
│   ├── ... (demais componentes 5GC + EPC)
│   └── 99-open5gs.conf # sysctl: ip_forward
└── scripts/
    └── install.sh      # Script de instalação completo
```

## Verificar serviços após instalação

```bash
systemctl status open5gs-*.service
systemctl status mongod
```

## Customização

Para alterar PLMN (MCC/MNC), edite `configs/amf.yaml` e `configs/mme.yaml` antes de executar o script, ou edite `/etc/open5gs/amf.yaml` após a instalação e reinicie o serviço:

```bash
sudo systemctl restart open5gs-amfd
```

## Licença

MIT
