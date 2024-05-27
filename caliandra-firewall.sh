#!/bin/bash

# Ativar o encaminhamento de IP
echo 1 > /proc/sys/net/ipv4/ip_forward

# Limpar todas as regras existentes
iptables -F
iptables -t nat -F

# Configuração padrão das políticas de firewall
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitir todo o tráfego de saída para a Internet
iptables -A OUTPUT -o eth0 -j ACCEPT

# Permitir todo o tráfego de entrada que seja resposta a solicitações iniciadas internamente
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Regras Específicas:
# Permitir conexões HTTP e HTTPS de entrada
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Permitir conexões DNS de entrada e saída
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT

# Permitir tráfego SMTP e IMAP de entrada para e-mail
iptables -A INPUT -p tcp -m multiport --dports 465,587,995,143,993 -j ACCEPT

# Restringir o acesso ao banco de dados apenas para o servidor de Aplicações
iptables -A FORWARD -p tcp --dport 5432 -d 192.168.2.8 -j ACCEPT
iptables -A FORWARD -p tcp --dport 5432 -j DROP

# Restringir o acesso ao Servidor de Aplicações apenas à SubredeLocal
iptables -A FORWARD -p tcp -s 192.168.3.0/24 -d 192.168.2.8 -j ACCEPT
iptables -A FORWARD -p tcp -d 192.168.2.8 -j DROP

# Logging
iptables -A INPUT -j LOG --log-prefix "Firewall Input Drop: "
iptables -A FORWARD -j LOG --log-prefix "Firewall Forward Drop: "

# Assegurar que nada mais seja aceito
iptables -A INPUT -j DROP
iptables -A FORWARD -j DROP

