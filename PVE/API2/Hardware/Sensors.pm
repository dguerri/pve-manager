package PVE::API2::Hardware::Sensors;

use strict;
use warnings;

use PVE::JSONSchema qw(get_standard_option);
use PVE::RESTHandler;
use PVE::SensorInfo;

use base qw(PVE::RESTHandler);

__PACKAGE__->register_method({
    name => 'sensor_index',
    path => '',
    method => 'GET',
    description => "Index of available sensor methods.",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            node => get_standard_option('pve-node'),
        },
    },
    returns => {
        type => 'array',
        items => {
            type => "object",
            properties => { subdir => { type => 'string' } },
        },
        links => [{ rel => 'child', href => "{subdir}" }],
    },
    code => sub {
        my ($param) = @_;

        return [
            { subdir => 'temperature' },
            { subdir => 'fan' },
        ];
    },
});

__PACKAGE__->register_method({
    name => 'temperature_index',
    path => 'temperature',
    method => 'GET',
    description => "Index of temperature sensor types.",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            node => get_standard_option('pve-node'),
        },
    },
    returns => {
        type => 'array',
        items => {
            type => "object",
            properties => { subdir => { type => 'string' } },
        },
        links => [{ rel => 'child', href => "{subdir}" }],
    },
    code => sub {
        my ($param) = @_;

        return [
            { subdir => 'cpu' },
            { subdir => 'disk' },
            { subdir => 'other' },
        ];
    },
});

__PACKAGE__->register_method({
    name => 'cpu_index',
    path => 'temperature/cpu',
    method => 'GET',
    description => "Index of CPU temperature sensor methods.",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            node => get_standard_option('pve-node'),
        },
    },
    returns => {
        type => 'array',
        items => {
            type => "object",
            properties => { subdir => { type => 'string' } },
        },
        links => [{ rel => 'child', href => "{subdir}" }],
    },
    code => sub {
        my ($param) = @_;

        return [
            { subdir => 'values' },
        ];
    },
});

__PACKAGE__->register_method({
    name => 'disk_index',
    path => 'temperature/disk',
    method => 'GET',
    description => "Index of disk temperature sensor methods.",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            node => get_standard_option('pve-node'),
        },
    },
    returns => {
        type => 'array',
        items => {
            type => "object",
            properties => { subdir => { type => 'string' } },
        },
        links => [{ rel => 'child', href => "{subdir}" }],
    },
    code => sub {
        my ($param) = @_;

        return [
            { subdir => 'values' },
        ];
    },
});

__PACKAGE__->register_method({
    name => 'other_index',
    path => 'temperature/other',
    method => 'GET',
    description => "Index of other temperature sensor methods.",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            node => get_standard_option('pve-node'),
        },
    },
    returns => {
        type => 'array',
        items => {
            type => "object",
            properties => { subdir => { type => 'string' } },
        },
        links => [{ rel => 'child', href => "{subdir}" }],
    },
    code => sub {
        my ($param) = @_;

        return [
            { subdir => 'values' },
        ];
    },
});

__PACKAGE__->register_method({
    name => 'fan_index',
    path => 'fan',
    method => 'GET',
    description => "Index of fan-related methods.",
    permissions => {
        user => 'all',
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            node => get_standard_option('pve-node'),
        },
    },
    returns => {
        type => 'array',
        items => {
            type => "object",
            properties => { subdir => { type => 'string' } },
        },
        links => [{ rel => 'child', href => "{subdir}" }],
    },
    code => sub {
        my ($param) = @_;

        return [
            { subdir => 'speeds' },
        ];
    },
});

__PACKAGE__->register_method({
    name => 'read_cpu_temperature_values',
    path => 'temperature/cpu/values',
    method => 'GET',
    description => "Read current CPU temperature values.",
    protected => 1,
    proxyto => "node",
    permissions => {
        check => ['perm', '/', ['Sys.Audit'], any => 1],
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            node => get_standard_option('pve-node'),
        },
    },
    returns => {
        type => 'array',
        items => {
            type => "object",
            properties => {
                sensor => {
                    type => 'string',
                    description => 'Sensor identifier (e.g., coretemp/Core 0).',
                },
                temperature => {
                    type => 'number',
                    description => 'Current temperature in degrees Celsius.',
                },
                unit => {
                    type => 'string',
                    description => 'Temperature unit (always celsius).',
                },
                driver => {
                    type => 'string',
                    description => 'Human-readable driver description.',
                },
                max => {
                    type => 'number',
                    optional => 1,
                    description => 'Maximum operating temperature before throttling.',
                },
                critical => {
                    type => 'number',
                    optional => 1,
                    description => 'Critical temperature threshold.',
                },
                logical_core => {
                    type => 'integer',
                    optional => 1,
                    description => 'Logical core number.',
                },
                physical_core => {
                    type => 'string',
                    optional => 1,
                    description => 'Physical core ID.',
                },
                package => {
                    type => 'integer',
                    optional => 1,
                    description => 'CPU package/socket number.',
                },
            },
        },
    },
    code => sub {
        my ($param) = @_;

        my $temps = PVE::SensorInfo::read_temperatures('cpu');

        my $result = [];
        foreach my $sensor (sort keys %$temps) {
            my $info = $temps->{$sensor};

            my $entry = {
                sensor      => $sensor,
                temperature => $info->{temperature},
                unit        => $info->{unit},
                driver      => $info->{driver},
            };

            $entry->{max} = $info->{max} if exists $info->{max};
            $entry->{critical} = $info->{critical} if exists $info->{critical};
            $entry->{logical_core} = $info->{logical_core} if exists $info->{logical_core};
            $entry->{physical_core} = $info->{physical_core} if exists $info->{physical_core};
            $entry->{package} = $info->{package} if exists $info->{package};

            push @$result, $entry;
        }

        return $result;
    },
});

__PACKAGE__->register_method({
    name => 'read_disk_temperature_values',
    path => 'temperature/disk/values',
    method => 'GET',
    description => "Read current disk temperature values.",
    protected => 1,
    proxyto => "node",
    permissions => {
        check => ['perm', '/', ['Sys.Audit'], any => 1],
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            node => get_standard_option('pve-node'),
        },
    },
    returns => {
        type => 'array',
        items => {
            type => "object",
            properties => {
                sensor => {
                    type => 'string',
                    description => 'Sensor identifier (e.g., hwmon1/Composite).',
                },
                device => {
                    type => 'string',
                    optional => 1,
                    description => 'Block device name (e.g., nvme0n1, sda).',
                },
                temperature => {
                    type => 'number',
                    description => 'Current temperature in degrees Celsius.',
                },
                unit => {
                    type => 'string',
                    description => 'Temperature unit (always celsius).',
                },
                driver => {
                    type => 'string',
                    description => 'Human-readable driver description.',
                },
                max => {
                    type => 'number',
                    optional => 1,
                    description => 'Maximum operating temperature.',
                },
                critical => {
                    type => 'number',
                    optional => 1,
                    description => 'Critical temperature threshold.',
                },
            },
        },
    },
    code => sub {
        my ($param) = @_;

        my $temps = PVE::SensorInfo::read_temperatures('disk');

        my $result = [];
        foreach my $sensor (sort keys %$temps) {
            my $info = $temps->{$sensor};

            my $entry = {
                sensor      => $sensor,
                temperature => $info->{temperature},
                unit        => $info->{unit},
                driver      => $info->{driver},
            };

            $entry->{device} = $info->{device} if exists $info->{device};
            $entry->{max} = $info->{max} if exists $info->{max};
            $entry->{critical} = $info->{critical} if exists $info->{critical};

            push @$result, $entry;
        }

        return $result;
    },
});

__PACKAGE__->register_method({
    name => 'read_other_temperature_values',
    path => 'temperature/other/values',
    method => 'GET',
    description => "Read current temperature values from other sensors.",
    protected => 1,
    proxyto => "node",
    permissions => {
        check => ['perm', '/', ['Sys.Audit'], any => 1],
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            node => get_standard_option('pve-node'),
        },
    },
    returns => {
        type => 'array',
        items => {
            type => "object",
            properties => {
                sensor => {
                    type => 'string',
                    description => 'Sensor identifier.',
                },
                temperature => {
                    type => 'number',
                    description => 'Current temperature in degrees Celsius.',
                },
                unit => {
                    type => 'string',
                    description => 'Temperature unit (always celsius).',
                },
                driver => {
                    type => 'string',
                    description => 'Human-readable driver description.',
                },
                max => {
                    type => 'number',
                    optional => 1,
                    description => 'Maximum operating temperature.',
                },
                critical => {
                    type => 'number',
                    optional => 1,
                    description => 'Critical temperature threshold.',
                },
            },
        },
    },
    code => sub {
        my ($param) = @_;

        my $temps = PVE::SensorInfo::read_temperatures('other');

        my $result = [];
        foreach my $sensor (sort keys %$temps) {
            my $info = $temps->{$sensor};

            my $entry = {
                sensor      => $sensor,
                temperature => $info->{temperature},
                unit        => $info->{unit},
                driver      => $info->{driver},
            };

            $entry->{max} = $info->{max} if exists $info->{max};
            $entry->{critical} = $info->{critical} if exists $info->{critical};

            push @$result, $entry;
        }

        return $result;
    },
});

__PACKAGE__->register_method({
    name => 'read_fan_speeds',
    path => 'fan/speeds',
    method => 'GET',
    description => "Read current fan speed values.",
    protected => 1,
    proxyto => "node",
    permissions => {
        check => ['perm', '/', ['Sys.Audit'], any => 1],
    },
    parameters => {
        additionalProperties => 0,
        properties => {
            node => get_standard_option('pve-node'),
        },
    },
    returns => {
        type => 'array',
        items => {
            type => "object",
            properties => {
                fan => {
                    type => 'string',
                    description => 'Fan identifier (e.g., nct6775/CPU Fan).',
                },
                speed => {
                    type => 'integer',
                    description => 'Current fan speed in RPM.',
                },
                unit => {
                    type => 'string',
                    description => 'Speed unit (always rpm).',
                },
                driver => {
                    type => 'string',
                    description => 'Human-readable driver description.',
                },
                min => {
                    type => 'integer',
                    optional => 1,
                    description => 'Minimum fan speed in RPM.',
                },
                max => {
                    type => 'integer',
                    optional => 1,
                    description => 'Maximum fan speed in RPM.',
                },
                target => {
                    type => 'integer',
                    optional => 1,
                    description => 'Target fan speed in RPM.',
                },
                alarm => {
                    type => 'integer',
                    optional => 1,
                    description => 'Fan alarm status (0=OK, 1=Alarm).',
                },
            },
        },
    },
    code => sub {
        my ($param) = @_;

        my $speeds = PVE::SensorInfo::read_fan_speeds();

        my $result = [];
        foreach my $fan (sort keys %$speeds) {
            my $info = $speeds->{$fan};
            
            my $entry = {
                fan    => $fan,
                speed  => $info->{speed},
                unit   => $info->{unit},
                driver => $info->{driver},
            };

            $entry->{min} = $info->{min} if exists $info->{min};
            $entry->{max} = $info->{max} if exists $info->{max};
            $entry->{target} = $info->{target} if exists $info->{target};
            $entry->{alarm} = $info->{alarm} if exists $info->{alarm};

            push @$result, $entry;
        }

        return $result;
    },
});

1;