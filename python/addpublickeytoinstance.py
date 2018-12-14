#!/usr/bin/python

#############################################
# Created by Lewis Rodriguez.               #
# 2018-10-05                                #
# Last modification: 13/12/18               #
# Script to add your public key to server(s)#
#############################################
from os import environ, path, mkdir, chmod
from sys import argv
from Crypto.PublicKey import RSA
from paramiko import AuthenticationException, SSHClient, AutoAddPolicy
from socket import gaierror

#Variables to be used in the script.
try:
    user_home = environ['HOME']
    username = str(argv[1])
    password = str(argv[2])
    hosts = argv[3:]
except IndexError:
    print "One of more parameters are missing, please check..."
    user_help()
    
def user_help ():
    print """Help:  ./addpublickeytoinstance.py <username> <password> <host or hosts by spaces>"""
    exit(1)

def pretty_print(output):
    print len(output) * "="
    print output
    print len(output) * "="


def deploy_key(key, server, username, password):
    client = SSHClient()
    try:
        client.load_system_host_keys(user_home + '/.ssh/known_hosts')
        client.load_host_keys(user_home + '/.ssh/known_hosts')
        client.set_missing_host_key_policy(AutoAddPolicy())
        client.connect(server, username=username, password=password) #allow_agent=False
        client.exec_command('mkdir -p ~/.ssh/')
        client.exec_command('echo "%s" >> ~/.ssh/authorized_keys' % key)
        client.exec_command('chmod 644 ~/.ssh/authorized_keys')
        client.exec_command('chmod 700 ~/.ssh/')
        pretty_print("Public key successfully added.")
    except Exception as e:
        pretty_print("There is an error trying to add the public key to the server, pls check...")
        print e
        exit(1)
    finally:
        client.close()


def create_ssh_keys():
    if not path.exists(user_home + '/.ssh'):
        mkdir(user_home + '/.ssh', 0700)

    new_key = RSA.generate(2048, e=65537)
    with open(user_home + '/.ssh/id_rsa', 'w') as private_file:
        private_file.write(new_key.exportKey("PEM"))
        chmod(user_home + '/.ssh/id_rsa', 0700)

    with open(user_home + '/.ssh/id_rsa.pub', 'w') as public_file:
        public_file.write(new_key.publickey().exportKey("OpenSSH"))

    if not path.exists(user_home + '/.ssh/known_hosts'):
        open(user_home + '/.ssh/known_hosts', 'a+').close()

    pretty_print("Keys generated successfully.")
    return open(user_home + '/.ssh/id_rsa.pub').read()


def get_key():
    if path.exists(user_home + '/.ssh/id_rsa.pub'):
        pretty_print("Public key already exists in your local.")
        return open(user_home + '/.ssh/id_rsa.pub').read()
    else:
        pretty_print("Public key does not exist... Attempting to create it...")
        return create_ssh_keys()


def ssh_connection_test(host):
    pretty_print("Testing connection to the server " + host + " ...")
    client = SSHClient()
    try:
        client.load_host_keys(user_home + '/.ssh/known_hosts')
        client.set_missing_host_key_policy(AutoAddPolicy())
        client.connect(host, username=username, key_filename= user_home + "/.ssh/id_rsa", timeout=4)  #allow_agent=False
        pretty_print("Looks like you already have access with public key to this server " + host + "... Exiting.")
        return True
    except gaierror:
        pretty_print("Not able to connect to server: " + host + ", it's not reachable...")
        exit(1)
    except AuthenticationException:
        pretty_print("Connection to the server failed...")
        return False
    finally:
        client.close()


# Main Function
def main():
    if len(argv) < 4:
        user_help()
    
    
    key = get_key()
    for host in hosts:
        if not ssh_connection_test(host):
            pretty_print('Attempting to add your public key to the target server ' + host)
            deploy_key(key, host, username, password)


# Main Function Reference
if __name__ == "__main__":
    main()
