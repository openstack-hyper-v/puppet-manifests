node "certname1" {

vlan { "2":
	description => "Internet_Provider",
}

vlan { "3":
	description => "10.21.7.0/24-API",
}

vlan { "4":
	description => "10.99.99.0/24-IPMI",
}

vlan { "5":	
	description => "172.18.2.0/23-VM",
}


interface {"Vlan1":
}

interface {"Vlan2":
}

interface {"Vlan3":
		ipaddress => "10.21.7.230",
}

interface {"Vlan4":
		ipaddress => "10.99.99.230",
}
                           

  interface { "GigabitEthernet0/1":
    description  => "ASA-Inside-Interface",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/2":
    description  => "ASA IPMI Interface",
    mode                => access,
    native_vlan => 4
  }
  interface { "GigabitEthernet0/3":
    description  => "dell chassis mgmt 0",
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet0/4":
    description  => "dell chassis mgmt 1",
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet0/5":
    description  => "Cisco 2811 Lan Interface",
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet0/6":
    description  => "Unused Port",
    mode                => access,
    native_vlan => 3
  }

notify {"Skipping Ports 7 - 10 Used for LCAP Trunk to Cisco 3130g #1 in Dell M10000 Blade Chassis":}

#
# Ports 7 - 10 Used for LCAP Trunk to Cisco 3130g #1 in Dell M10000 Blade Chassis
#
###                                                                     
#  interface { "GigabitEthernet0/7":
#    description  => "Uplink c3130g 0 Port 2",
#    mode                => access,
#    native_vlan => 3
#  }
#                                                                     
#  interface { "GigabitEthernet0/8":
#    description  => "Uplink c3130g 0 Port 3",
#    mode                => access,
#    native_vlan => 3
#  }
#                                                                     
#  interface { "GigabitEthernet0/9":
#    description  => "Uplink c3130g 1 Port 0",
#    mode                => access,
#    native_vlan => 3
#  }
#                                                                     
#  interface { "GigabitEthernet0/10":
#    description  => "Uplink c3130g 1 Port 1",
#    mode                => access,
#    native_vlan => 3
#  }
#                                                                     

notify {"Skipping Ports 11 - 14 Used for LCAP Trunk to Cisco 3130g #2 in Dell M10000 Blade Chassis":}
#
# Ports 11 - 14 Used for LCAP Trunk to Cisco 3130g #2 in Dell M10000 Blade Chassis
#
###                                                                     
#  interface { "GigabitEthernet0/11":
#    description  => "Uplink c3130g 1 Port 3",
#    mode                => access,
#    native_vlan => 3
#  }
#
# Ports 11 - 14 Used for LCAP Trunk to Cisco 3130g #2 in Dell M10000 Blade Chassis
#
###                                                                     
#  interface { "GigabitEthernet0/12":
#    description  => "Uplink c3130g 1 Port 4",
#    mode                => access,
#    native_vlan => 3
#  }
#                                                                     
#  interface { "GigabitEthernet0/13":
#    mode                => access,
#    native_vlan => 3
#  }
#  interface { "GigabitEthernet0/14":
#    mode                => access,
#    native_vlan => 3
#  }

  interface { "GigabitEthernet0/15":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/16":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEther5et0/17":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/18":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/19":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/20":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/21":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/22":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/23":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/24":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/25":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/26":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/27":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet0/28":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet0/29":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/30":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/31":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/32":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/33":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/34":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/35":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/36":
    description  => "Host Interface ",
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet0/37":
    description  => "Host Interface ",
    description  => "IPMI HP Node 11",
    mode                => access,
    native_vlan => 4
  }
  interface { "GigabitEthernet0/38":
    description  => "IPMI HP Node 10",
    mode                => access,
    native_vlan => 4
  }
  interface { "GigabitEthernet0/39":
    description  => "IPMI HP Node 9",
    mode                => access,
    native_vlan => 4
  }
  interface { "GigabitEthernet0/40":
    description  => "IPMI HP Node 8",
    mode                => access,
    native_vlan => 4
  }
  interface { "GigabitEthernet0/41":
    description  => "IPMI HP Node 7",
    mode                => access,
    native_vlan => 4
  }
  interface { "GigabitEthernet0/42":
    description  => "IPMI HP Node 6",
    mode                => access,
    native_vlan => 4
  }
  interface { "GigabitEthernet0/43":
    description  => "IPMI HP Node 5",
    mode                => access,
    native_vlan => 4
  }
  interface { "GigabitEthernet0/44":
    description  => "IPMI HP Node 4",
    mode                => access,
    native_vlan => 4
  }
  interface { "GigabitEthernet0/45":
    description  => "IPMI HP Node 3",
    mode                => access,
    native_vlan => 4
  }
  interface { "GigabitEthernet0/46":
    description  => "IPMI HP Node 2",
    mode                => access,
    native_vlan => 4
  }
  interface { "GigabitEthernet0/47":
    description  => "IPMI HP Node 1",
    mode                => access,
    native_vlan => 4
  }
  interface { "GigabitEthernet0/48":
    description  => "IPMI HP Node 0",
    mode                => access,
    native_vlan => 4
  }
}
