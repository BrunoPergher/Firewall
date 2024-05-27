#!/bin/bash
echo 1 > /proc/sys/net/ipv4/ip_forward

# Limpar todas as regras existentes
iptables -F
iptables -t nat -F

# Configuração padrão das políticas de firewall
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Regras Básicas:
# Permitir todo o tráfego entre a rede local e a DMZ
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT

# Bloquear qualquer acesso direto da Internet para a estação de trabalho
iptables -A FORWARD -i eth0 -d 192.168.3.0/24 -j DROP

# Regras Específicas:
# Permitir conexões de saída da estação de trabalho para a Internet para HTTP, HTTPS
iptables -A FORWARD -s 192.168.3.0/24 -p tcp -m multiport --dports 80,443 -j ACCEPT

# Permitir tráfego de saída para serviços de e-mail (SMTP, IMAP, POP)
iptables -A FORWARD -s 192.168.3.0/24 -p tcp -m multiport --dports 465,587,995,143,993 -j ACCEPT

# Restringir o acesso ao banco de dados. Somente o servidor de Aplicações pode acessar
iptables -A FORWARD -s 192.168.3.0/24 -d 192.168.2.8 -p tcp --dport 5432 -j ACCEPT
iptables -A FORWARD -p tcp --dport 5432 -j DROP

# Restringir o acesso às portas 80 e 443 da SubredeLocal
iptables -A FORWARD -s 192.168.3.0/24 -p tcp -m multiport --dports 80,443 -j DROP

# Restringir o acesso ao Servidor de Aplicações à SubredeLocal
iptables -A FORWARD -s 192.168.3.0/24 -d 192.168.2.8 -j ACCEPT
iptables -A FORWARD -d 192.168.2.8 -j DROP

# Redirecionamento e Encaminhamento:
# Configurar encaminhamento de pacotes entre as interfaces de rede
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Assegurar que nada mais seja aceito que não esteja explicitamente permitido
iptables -A FORWARD -j DROP


