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
	./scripts/expect.sh $(system-pw) /usr/bin/ssh -oStrictHostKeyChecking=no root@$(hostname).local

uninstall:
	multipass delete $(hostname)
	multipass purge
	ssh-keygen -R $(hostname).local

start:
	multipass start $(hostname)
	./scripts/expect.sh $(system-pw) /usr/bin/ssh -T -oStrictHostKeyChecking=no root@$(hostname).local "cd /home/system/components/ws; ./ws -b"
	./scripts/expect.sh $(system-pw) /usr/bin/ssh -oStrictHostKeyChecking=no root@$(hostname).local

stop:
	multipass stop $(hostname)

shell:
	./scripts/expect.sh $(system-pw) /usr/bin/ssh -oStrictHostKeyChecking=no root@$(hostname).local
