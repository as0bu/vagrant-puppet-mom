###############################################################################
#
# This custom fact looks at all of the available IPs on a node to determine if
# they match any of the networks defined.
#
# This will match any length of the network, i.e. 10.176.0, 10.250, etc.
#
###############################################################################

# Define all networks. The "192.167.58.102" and "192.167.58.10" IPs are for
# the vagrant environment

networks = {}

networks['vagrant_dc01_networks'] = [
  '192.168.58.101/32',
  '192.168.58.11/32',
]

networks['vagrant_dc02_networks'] = [
  '192.168.58.102/32',
  '192.168.58.10/32',
]

def in_network(ip,dc_networks)

  # Search for the ip in the network against all neworks if there is a
  # match then output true
  dc_networks.each do |network|
    ipaddr_net = IPAddr.new(network)
    ipaddr_ip = IPAddr.new(ip)
    return true if ipaddr_net.include?(ipaddr_ip)
  end

  return false

end

def get_dc(networks)
  # Get all of the current IPs from facter on the node and create an
  # array called "node_ips"
  node_ips = Facter.value(:networking)['interfaces'].map { |k,iface| iface['ip'] }

  node_ips.each do |ip|
    if in_network(ip, networks['vagrant_dc01_networks'])
      return 'vagrant-dc01'
    elsif in_network(ip, networks['vagrant_dc02_networks'])
      return 'vagrant-dc02'
    end
  end

  return 'error'

end

Facter.add(:datacenter) do
  setcode do
    get_dc(networks)
  end
end
