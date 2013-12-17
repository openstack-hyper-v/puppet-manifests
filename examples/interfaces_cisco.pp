node /^(c3560g04).*/ {
# Access Mode Port
#  interface { "GigabitEthernet0/13":
#    description => "Dell chassis mgmt 0",
#    mode  => access,
#    native_vlan => 3
#  }
# SDN Port Trunk Mode Vlan 500-1000
  interface { "GigabitEthernet0/1-22":
    description => "Dell chassis mgmt 0",
    mode  => trunk,
    allowed_trunk_vlans => "500,1000"
 }
}
