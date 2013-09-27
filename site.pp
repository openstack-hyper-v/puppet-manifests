

node /^(norman|mother|ns[0-9\.]+)/ {
  class { 'ipam': }
}

node /quartermaster.*/ {
  class {'quartermaster':}
}
