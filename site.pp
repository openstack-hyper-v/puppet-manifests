

node /^(norman|mother|ns[0-9\.]+)/ {
  class { 'ipam': }
}

node /quartermaster.*/ {
  class {'quartermaster':}
}

node /^(kvm-compute-[0-9]|neutron-controller|openstack-controller+)/ {
  notify {"OpenStack Node: ${hostname}":}
  class {'basenode':}
  class {'basenode::dhcp2static':}
  class {'dell_openmanage':}
  class {'dell_openmanage::firmware::update':}
  class {'packstack::yumrepo':}
}
