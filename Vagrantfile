vault_nodes = [
    {
        ip: "192.168.122.11",
        name: "vault-node1",
        hostname: "vault-node1.local"
    },
    {
        ip: "192.168.122.12",
        name: "vault-node2",
        hostname: "vault-node2.local"
    },
    {
        ip: "192.168.122.13",
        name: "vault-node3",
        hostname: "vault-node3.local"
    },
]
nginx_node = {
  ip: "192.168.122.20",
  name: "nginx",
  hostname: "nginx.local"
}

vault_node_leader = vault_nodes[0]

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2204"
  config.vm.synced_folder "./ansible/vault_unseal_playbook/leader/keys", "/opt/vault/keys", create: true,  type: "rsync", rsync__auto: true
  config.vm.provider :libvirt do |driver|
    driver.memory = 1024 * 2
    driver.cpus = 2
  end

  vault_nodes.each_with_index do |vault_node, index|
    config.vm.define vault_node[:name] do |node|
      node.vm.hostname = vault_node[:hostname]
      node.vm.network "private_network", ip: vault_node[:ip]
      node.vm.provision "#{vault_node[:name]}_prv", type: :ansible do |vault_prv|
          vault_prv.limit = vault_node[:name]
          vault_prv.playbook = "./ansible/vault_playbook/playbook.yml"
          vault_prv.extra_vars = {
            vault_ip: vault_node[:ip],
            vault_domain: vault_node[:hostname],
            vault_node_id: vault_node[:name],
            vault_leader_ip: vault_node_leader[:ip]
          }
      end
    if vault_node[:name] == vault_node_leader[:name]
      node.vm.provision "vault_unseal_leader", type: :ansible, after: "#{vault_node_leader[:name]}_prv" do |vault_unseal_leader_prv|
        vault_unseal_leader_prv.playbook = "./ansible/vault_unseal_playbook/leader/playbook.yml"
        vault_unseal_leader_prv.limit = vault_node_leader[:name]
        vault_unseal_leader_prv.extra_vars = {
          vault_ip: vault_node[:ip]
        }
      end
    end
    if vault_node[:name] != vault_node_leader[:name]
        node.vm.provision "vault_unseal_follower", type: :ansible do |vault_unseal_follower_prv|
              vault_unseal_follower_prv.playbook = "./ansible/vault_unseal_playbook/followers/playbook.yml"
              vault_unseal_follower_prv.extra_vars = {
                vault_ip: vault_node[:ip],
                vault_leader_ip: vault_node_leader[:ip]
              }
             end
        end

    end
  end

  config.vm.define nginx_node[:name] do |nginx|
    nginx.vm.hostname = nginx_node[:hostname]
    nginx.vm.network "private_network", ip: nginx_node[:ip]
    nginx.vm.provision :ansible do |nginx_prv|
      nginx_prv.playbook = "./ansible/nginx_playbook/playbook.yml"
      nginx_prv.limit = nginx_node[:name]
      nginx_prv.extra_vars = {
        host: nginx_node[:name]
      }
    end
  end
  config.trigger.after :up do |t|
      t.info = "Rodando vagrant rsync após subir a VM..."
      t.run = { inline: "vagrant rsync #{vault_nodes.select{|node|  node[:name] != vault_node_leader[:name]}.map { |e|  e[:name]}.join(" ")}" }
    end
end