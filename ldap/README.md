# LDAP Service Server Appliance

## To create a password (Ubuntu Example): 

### Update packet manager and install dependencies: 

```sh
sudo apt-get update && sudo apt install slapd -y 
```

### Generate password: 
```bash
cadore@cadore:~/infra-appliances/$ slappasswd -s testearthur
{SSHA}qA8LKHHZ2nwAlo2p7d9EKkJZbczAUO1P
```

### Added a new entry in `./conf/config.ldif` file:

```bash
# User Arthur
dn: cn=arthur,ou=Users,dc=pedremp,dc=local
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
cn: arthur
sn: Usuario
uid: arthur
userPassword: {SSHA}qA8LKHHZ2nwAlo2p7d9EKkJZbczAUO1P
```