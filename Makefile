# A makefile to manage edgebox via multipass

ifndef log
override log = v
endif

ifndef hostname
override hostname = edgebox
endif

ifndef cpus
override cpus = 2
endif

ifndef memory
override memory = 4G
endif

ifndef storage
override storage = 50G
endif

ifndef system-pw
override system-pw = pw
endif

install:
	multipass launch 22.04 -n $(hostname) -c $(cpus) -m $(memory) -d $(storage) -$(log)
	multipass transfer ./scripts/setup.sh $(hostname):/home/ubuntu/setup.sh
	multipass exec $(hostname) -- sudo bash /home/ubuntu/setup.sh $(system-pw)
	@echo "System Successfully Installed. Access it via 'http://$(hostname).local' (web) or by running 'make shell' (ssh)"

install-cloud:
	./scripts/cluster_availability_check.sh $(hostname) $(cluster) $(cluster_ip) $(cluster_ssh_port)
	multipass launch 22.04 -n $(hostname) -c $(cpus) -m $(memory) -d $(storage) -$(log)
	multipass transfer ./scripts/setup.sh $(hostname):/home/ubuntu/setup.sh
	./scripts/setup_cloud_env.sh $(hostname) $(cluster) $(cluster_ip) $(cluster_ssh_port)
	multipass exec $(hostname) -- sudo bash /home/ubuntu/setup.sh $(system-pw) $(hostname).$(cluster)
	rm ./scripts/cloud.env
	python3 ./scripts/rebuild_proxies.py
	@echo "System Successfully Installed. Access it via 'http://$(hostname).$(cluster)' (web) or by running 'make shell' (ssh)"

uninstall:
	multipass delete $(hostname)
	multipass purge
	ssh-keygen -R $(hostname).local

start:
	multipass start $(hostname)
	@echo "System Started. Access it via 'http://$(hostname).local' (web) or by running 'make shell' (ssh)"

stop:
	multipass stop $(hostname)

restart: stop start

shell:
	ssh -oStrictHostKeyChecking=no root@$(hostname).local
