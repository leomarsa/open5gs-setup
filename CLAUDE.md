# Open5GS Setup — Instruções para Claude

Este repositório contém a instalação automatizada do Open5GS 2.7.7 em Ubuntu 24.04 LTS.

## O que fazer quando o usuário pedir para instalar

1. Descobrir o IP do servidor:
```bash
hostname -I | awk '{print $1}'
```

2. Executar o script de instalação como root:
```bash
sudo bash scripts/install.sh <IP_DO_SERVIDOR>
```

3. Verificar se todos os serviços subiram corretamente:
```bash
systemctl is-active open5gs-*.service mongod.service
```

4. Confirmar que o WebUI está acessível:
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:9999
```

## O que é instalado

- **Open5GS 2.7.7** — todos os componentes 5GC (AMF, SMF, UPF, NRF, SCP, AUSF, UDM, UDR, PCF, BSF, NSSF, SEPP) + EPC (MME, SGW-C, SGW-U, HSS, PCRF)
- **MongoDB 8.0**
- **Open5GS WebUI** (Node.js 20)

## Configuração padrão

| Parâmetro | Valor |
|---|---|
| PLMN | MCC=999, MNC=70 |
| TAC | 1 |
| SST | 1 |
| UE subnet | 10.45.0.0/16 |
| WebUI | http://<IP>:9999 — admin / 1423 |

## Arquivos de configuração

- `configs/*.yaml` — configs dos componentes Open5GS (o script substitui o IP automaticamente)
- `configs/freeDiameter/*.conf` — configs do freeDiameter (EPC)
- `configs/99-open5gs.conf` — sysctl (IP forwarding)

## Se algo falhar

- Verificar logs: `journalctl -u open5gs-amfd -n 50`
- Reiniciar serviço individual: `sudo systemctl restart open5gs-<nome>d`
- Verificar MongoDB: `systemctl status mongod`
