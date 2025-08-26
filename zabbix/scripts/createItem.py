from pyzabbix import ZabbixAPI

zabbix_url = 'http://localhost:8080'
zabbix_user = 'Admin'
zabbix_password = 'zabbix'
network_prefix = '10.100.73.'
group_name = '10.100.73.0/24 - ICMPping'

zapi = ZabbixAPI(zabbix_url)
zapi.login(zabbix_user, zabbix_password)

# Pegar template ID
template = zapi.template.get(filter={'name': 'ICMP Ping'})
template_id = template[0]['templateid']

# Pegar group ID
group = zapi.hostgroup.get(filter={'name': group_name})
if not group:
    group = zapi.hostgroup.create({'name': group_name})
    group_id = group['groupids'][0]
else:
    group_id = group[0]['groupid']


# Criar hosts
for i in range(1, 255):
    ip = f'{network_prefix}{i}'
    hostname = f'Host_{i}'
    zapi.host.create({
        'host': hostname,
        'interfaces': [{
            'type': 1,
            'main': 1,
            'useip': 1,
            'ip': ip,
            'dns': '',
            'port': '10050'
        }],
        'groups': [{'groupid': group_id}],
        'templates': [{'templateid': template_id}]
    })
    print(f'Host {hostname} com IP {ip} criado com sucesso!')
