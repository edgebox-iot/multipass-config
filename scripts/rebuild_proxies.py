# Read the output from 'multipass list --output json' and parse it to an object
# that can be used to rebuild the proxies in the traefik and haproxy config files.

import json
import os
import sys

# Read the output from running 'multipass list --output json' command and parse it to an object
def read_multipass_list():
    multipass_list = os.popen('multipass list --format json').read()
    multipass_list = json.loads(multipass_list)
    return multipass_list

# Go through the multipass list and build a list of the proxies

def build_proxy_list(multipass_list):
    proxy_list = []
    for instance in multipass_list['list']:
        instance_hostname = instance['name']
        if instance_hostname and instance['ipv4']:
            instance_ip = instance['ipv4'][0]
            proxy_list.append({
                'name': instance_hostname,
                'ip': instance_ip,
                # 'port': instance_ip.split('.')[3]
            })

    return proxy_list

# Write the proxy list to the files

def write_proxy_list(proxy_list):
    traefik_config_file = open('./edgebox.toml', 'w')
    traefik_generated_config = ""
    # haproxy_config_file = open('/etc/haproxy/haproxy.cfg', 'w')
    # haproxy_generated_config = ""
    server_count = 0
    for proxy in proxy_list:

        server_count += 1

        # Prepare traefik entries
        # They should look like this:
        # [http.routers.adm-edgebox-wildcard]
        #     rule = "HostRegexp(`adm-{subdomain:[a-z0-9]+}.edgebox.io`)"
        #     service = "adm-edgebox-service"
        #     priority = 1

        # [http.routers.adm-edgebox]
        #     rule = "Host(`adm.edgebox.io`)"
        #     service = "adm-edgebox-service"
        #     priority = 2

        # [http.services.adm-edgebox-service.loadBalancer]
        #     [[http.services.adm-edgebox-service.loadBalancer.servers]]
        #         url = "http://10.139.121.36:80"

        traefik_generated_config += "[http.routers." + proxy['name'] + "-edgebox-wildcard]\n"
        traefik_generated_config += "    rule = \"HostRegexp(`" + proxy['name'] + "-{subdomain:[a-z0-9]+}.edgebox.io`)\"\n"
        traefik_generated_config += "    service = \"" + proxy['name'] + "-edgebox-service\"\n"
        traefik_generated_config += "    priority = 1\n\n"
        traefik_generated_config += "[http.routers." + proxy['name'] + "-edgebox]\n"
        traefik_generated_config += "    rule = \"Host(`" + proxy['name'] + ".edgebox.io`)\"\n"
        traefik_generated_config += "    service = \"" + proxy['name'] + "-edgebox-service\"\n"
        traefik_generated_config += "    priority = 2\n\n"
        traefik_generated_config += "[http.services." + proxy['name'] + "-edgebox-service.loadBalancer]\n"
        traefik_generated_config += "    [[http.services." + proxy['name'] + "-edgebox-service.loadBalancer.servers]]\n"
        traefik_generated_config += "        url = \"http://" + proxy['ip'] + ":80\"\n\n"

        # Prepare haproxy entries
        # They should look like this:
        # frontend ssh_front_jpt
        #     bind *:2222
        #     mode tcp
        #     default_backend ssh_back_jpt

        # backend ssh_back_jpt
        #     mode tcp
        #     balance roundrobin
        #     server server1 10.139.121.58:22 check

        # haproxy_generated_config += "frontend " + proxy['name'] + "_front\n"
        # haproxy_generated_config += "    bind *:" + proxy['port'] + "\n"
        # haproxy_generated_config += "    mode tcp\n"
        # haproxy_generated_config += "    default_backend " + proxy['name'] + "_back\n\n"
        # haproxy_generated_config += "backend " + proxy['name'] + "_back\n"
        # haproxy_generated_config += "    mode tcp\n"
        # haproxy_generated_config += "    balance roundrobin\n"
        # haproxy_generated_config += "    server server" + server_count + " " proxy['ip'] + ":22 check\n\n"
        
    traefik_config_file.write(traefik_generated_config)


# Main function
mutlipass_list = read_multipass_list()
proxy_list = build_proxy_list(mutlipass_list)
write_proxy_list(proxy_list)

# Move resulting file to /root/traefik/dynamic/config folder with the name edgebox.toml
os.system('mv ./edgebox.toml /root/traefik/config/dynamic/edgebox.toml')
