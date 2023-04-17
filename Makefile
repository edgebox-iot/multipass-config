# A makefile to manage edgebox via multipass

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
	/usr/bin/ssh system@$(hostname).local

start:
	multipass start $(hostname)

stop:
	multipass stop $(hostname)

reset-ssh:
	ssh-keygen -R $(hostname).local

delete:
	multipass delete $(hostname)
	multipass purge
	ssh-keygen -R $(hostname).local
