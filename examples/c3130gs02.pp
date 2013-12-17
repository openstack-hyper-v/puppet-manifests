node "certname3" {

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
		ipaddress => "10.21.7.231",
}

interface {"Vlan4":
		ipaddress => "10.99.99.231",
}
                           
  interface { "FastEthernet0":
    	description  => "MGMT Brige through Dell Chassis",
	ipaddress => dhcp,
  }

  interface { "GigabitEthernet1/0/1":
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet1/0/2":
    mode                => access,
    native_vlan => 4
  }
  interface { "GigabitEthernet1/0/3":
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet1/0/4":
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet1/0/5":
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet1/0/6":
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet1/0/7":
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet1/0/8":
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet1/0/9":
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet1/0/10":
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet1/0/11":
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet1/0/12":
    mode                => access,
    native_vlan => 3
  }
                                                                     
  interface { "GigabitEthernet1/0/13":
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet1/0/14":
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet1/0/15":
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet1/0/16":
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet1/0/17":
    mode                => access,
    native_vlan => 3
  }
  interface { "GigabitEthernet1/0/18":
    mode                => access,
    native_vlan => 3
  }

notify {"Interface 1/0/19 - 1/0/4 used for LACP Trunk to c3560g":}
#
# Interface 1/0/19 - 1/0/4 used for LACP Trunk to c3560g
#
###
#  interface { "GigabitEthernet1/0/19":
#    description => "trunk to main switch"
#    mode                => access,
#    native_vlan => 3
#  }
#  interface { "GigabitEthernet1/0/20":
#    description => "trunk to main switch"
#    mode                => access,
#    native_vlan => 3
#  }
#  interface { "GigabitEthernet1/0/21":
#    description => "trunk to main switch"
#    mode                => access,
#    native_vlan => 3
#  }
#  interface { "GigabitEthernet1/0/22":
#    description => "trunk to main switch"
#    mode                => access,
#    native_vlan => 3
#  }
#  interface { "GigabitEthernet1/0/23":
#    mode                => access,
#    native_vlan => 3
#  }
#  interface { "GigabitEthernet1/0/24":
#    mode                => access,
#    native_vlan => 3
#  }
}
