# A makefile to manage edgebox via multipass

GREEN=\033[0;32m
NC=\033[0m

ifndef log
override log = v
endif

ifndef hostanme
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
	@echo "$(GREEN)System Successfully Installed!$(NC)Access it via 'http://$(hostname).local' (web) or by running 'make shell' (ssh)"


uninstall:
	multipass delete $(hostname)
	multipass purge
	ssh-keygen -R $(hostname).local

start:
	multipass start $(hostname)
	./scripts/expect.sh $(system-pw) /usr/bin/ssh -T -oStrictHostKeyChecking=no root@$(hostname).local "cd /home/system/components/ws; ./ws -b"
	@echo "$(GREEN)System Started!$(NC)Access it via 'http://$(hostname).local' (web) or by running 'make shell' (ssh)"

stop:
	multipass stop $(hostname)

restart: stop start

shell:
	./scripts/expect.sh $(system-pw) /usr/bin/ssh -oStrictHostKeyChecking=no root@$(hostname).local
