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
