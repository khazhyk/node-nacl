class base (
    String $home_prefix = '/home',
    Array[String] $ssh_keys = [],
    ) {
    user { 'khazhy_user':
        ensure => present,
        name   => 'khazhy',
        home   => "${home_prefix}/khazhy",
        groups => ['sudo']
    }

    $ssh_keys.each |String $value| {
        $value_split = split($value, ' ')
        $key_type = $value_split[0]
        $key_key = $value_split[1]
        $key_name = $value_split[2]

        ssh_authorized_key { $key_name:
            ensure => present,
            user   => 'khazhy',
            type   => $key_type,
            key    => $key_key,
        }
    }
    class { 'hiera':
        hiera_version =>  '5',
        eyaml         => true,
        owner         => 'root',
        group         => 'root',
    }

    class { 'firewall': }
    firewall { '000 accept all icmp requests':
        proto  => 'icmp',
        action => 'accept',
    }

    firewall { '000 allow existing connections':
        state  => ['ESTABLISHED','RELATED'],
        action => 'accept'
    }

    firewall { '001 accept all ssh':
        dport  => 22,
        proto  => 'tcp',
        action => 'accept',
    }

    # Temp - allow VPN to access important ports
    firewall { '050 main access':
        dport  => ['8081-8100', 5432, 6379, 10050],
        source => '10.8.0.1',
        proto  => 'tcp',
        action => 'accept'
    }

    firewall { '999 drop all else':
        action => 'drop'
    }
}
