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
	@echo
	@echo "🚀 You're about to install Edgebox VM '$(hostname)' with $(cpus) vCPUs, $(memory) Memory, $(storage) Storage"
	@echo "⌛ Installation starting in 10 seconds. Press Ctrl+C to cancel."
	@echo
	@sleep 10
	@echo "This installation will take a few minutes. Please be patient 🙏"
	@echo
	@echo "-> 👇 Downloading installation script..."
	mkdir -p ./tmp
	@rm -f ./tmp/install_edgebox.sh || true
	@curl -L install.edgebox.io -o ./tmp/install_edgebox.sh
	@echo "-> 🆕 Launching new virtual machine..."
	@multipass launch 22.04 -n $(hostname) -c $(cpus) -m $(memory) -d $(storage) -$(log)
	@multipass transfer ./tmp/install_edgebox.sh $(hostname):/home/ubuntu/install_edgebox.sh
	@multipass exec $(hostname) -- sudo bash /home/ubuntu/install_edgebox.sh --system-password $(system-pw) --skip-prompt
	@rm ./tmp/install_edgebox.sh || true
	@echo "System Successfully Installed. Access it via 'http://$(hostname).local' (web) or by running 'make shell $(hostname)' (ssh)"

install-cloud:
	@echo "-> ✅ Checking cluster availability..."
	./scripts/cluster_availability_check.sh $(hostname) $(cluster) $(cluster_ip) $(cluster_ssh_port)
	@echo "-> 👇 Downloading installation script..."
	@curl -L install.edgebox.io -o ./scripts/install_edgebox.sh
	@echo "-> 🆕 Launching new virtual machine..."
	@multipass launch 22.04 -n $(hostname) -c $(cpus) -m $(memory) -d $(storage) -$(log)
	@multipass transfer ./scripts/install_edgebox.sh $(hostname):/home/ubuntu/install_edgebox.sh
	@echo "-> ☁️ Setting up cloud environment..."
	./scripts/setup_cloud_env.sh $(hostname) $(cluster) $(cluster_ip) $(cluster_ssh_port)
	@multipass exec $(hostname) -- sudo bash /home/ubuntu/install_edgebox.sh --system-password $(system-pw) --cluster-host $(hostname).$(cluster) --skip-prompt
	rm ./scripts/cloud.env || true
	@echo "-> 🛠️ Rebuilding proxy configuration..."
	python3 ./scripts/rebuild_proxies.py
	@echo "System Successfully Installed. Access it via 'http://$(hostname).$(cluster)' (web) or by running 'make shell $(hostname)' (ssh)"

uninstall:
	@echo "🚨 You're about to uninstall Edgebox VM '$(hostname)'. This will delete all data."
	@echo "⌛ Uninstallation starting in 5 seconds. Press Ctrl+C to cancel."
	@echo
	@sleep 5
	@echo "-> 🗑️ Deleting Edgebox VM '$(hostname)'..."
	@multipass delete $(hostname)
	@multipass purge
	@echo "-> 🗑️ Deleting VM from known_hosts '$(hostname)'..."
	ssh-keygen -R $(hostname).local || echo "-> 🗑️ No known_hosts entry for '$(hostname).local' found. Skipping..."
	@echo "Edgebox VM '$(hostname)' successfully uninstalled."

start:
	@multipass start $(hostname)
	@echo "System Started. Access it via 'http://$(hostname).local' (web) or by running 'make shell' (ssh)"

stop:
	@multipass stop $(hostname)

restart: stop start

shell:
	ssh -oStrictHostKeyChecking=no root@$(hostname).local
