package Slic3r::Config;
use strict;
use warnings;
use utf8;

use constant PI => 4 * atan2(1, 1);

# cemetery of old config settings
our @Ignore = qw(duplicate_x duplicate_y multiply_x multiply_y support_material_tool);

our $Options = {

    # miscellaneous options
    'notes' => {
        label   => 'Configuration notes',
        cli     => 'notes=s',
        type    => 's',
        multiline => 1,
        width   => 400,
        height  => 100,
        serialize   => sub { join '\n', split /\R/, $_[0] },
        deserialize => sub { join "\n", split /\\n/, $_[0] },
    },
    'threads' => {
        label   => 'Threads (more speed, more memory usage)',
        cli     => 'threads|j=i',
        type    => 'i',
    },

    # output options
    'output_filename_format' => {
        label   => 'Output filename format',
        cli     => 'output-filename-format=s',
        type    => 's',
    },

    # printer options
    'print_center' => {
        label   => 'Print center (mm)',
        cli     => 'print-center=s',
        type    => 'point',
        serialize   => sub { join ',', @{$_[0]} },
        deserialize => sub { [ split /,/, $_[0] ] },
    },
    'gcode_flavor' => {
        label   => 'G-code flavor',
        cli     => 'gcode-flavor=s',
        type    => 'select',
        values  => [qw(reprap teacup makerbot mach3 no-extrusion)],
        labels  => ['RepRap (Marlin/Sprinter)', 'Teacup', 'MakerBot', 'Mach3/EMC', 'No extrusion'],
    },
    'use_relative_e_distances' => {
        label   => 'Use relative E distances',
        cli     => 'use-relative-e-distances!',
        type    => 'bool',
    },
    'extrusion_axis' => {
        label   => 'Extrusion axis',
        cli     => 'extrusion-axis=s',
        type    => 's',
    },
    'z_offset' => {
        label   => 'Z offset (mm)',
        cli     => 'z-offset=f',
        type    => 'f',
    },
    'gcode_arcs' => {
        label   => 'Use native G-code arcs',
        cli     => 'gcode-arcs!',
        type    => 'bool',
    },
    'g0' => {
        label   => 'Use G0 for travel moves',
        cli     => 'g0!',
        type    => 'bool',
    },
    'gcode_comments' => {
        label   => 'Verbose G-code',
        cli     => 'gcode-comments!',
        type    => 'bool',
    },
    
    # extruders options
    'nozzle_diameter' => {
        label   => 'Nozzle diameter (mm)',
        cli     => 'nozzle-diameter=f@',
        type    => 'f',
        important => 1,
        serialize   => sub { join ',', @{$_[0]} },
        deserialize => sub { [ split /,/, $_[0] ] },
    },
    'filament_diameter' => {
        label   => 'Diameter (mm)',
        cli     => 'filament-diameter=f@',
        type    => 'f',
        important => 1,
        serialize   => sub { join ',', @{$_[0]} },
        deserialize => sub { [ split /,/, $_[0] ] },
    },
    'extrusion_multiplier' => {
        label   => 'Extrusion multiplier',
        cli     => 'extrusion-multiplier=f@',
        type    => 'f',
        aliases => [qw(filament_packing_density)],
        serialize   => sub { join ',', @{$_[0]} },
        deserialize => sub { [ split /,/, $_[0] ] },
    },
    'temperature' => {
        label   => 'Temperature (°C)',
        cli     => 'temperature=i@',
        type    => 'i',
        important => 1,
        serialize   => sub { join ',', @{$_[0]} },
        deserialize => sub { [ split /,/, $_[0] ] },
    },
    'first_layer_temperature' => {
        label   => 'First layer temperature (°C)',
        cli     => 'first-layer-temperature=i@',
        type    => 'i',
        serialize   => sub { join ',', @{$_[0]} },
        deserialize => sub { [ split /,/, $_[0] ] },
    },
    
    # extruder mapping
    'perimeter_extruder' => {
        label   => 'Perimeter extruder',
        cli     => 'perimeter-extruder=i',
        type    => 'i',
        aliases => [qw(perimeters_extruder)],
    },
    'infill_extruder' => {
        label   => 'Infill extruder',
        cli     => 'infill-extruder=i',
        type    => 'i',
    },
    'support_material_extruder' => {
        label   => 'Extruder',
        cli     => 'support-material-extruder=i',
        type    => 'i',
    },
    
    # filament options
    'first_layer_bed_temperature' => {
        label   => 'First layer bed temperature (°C)',
        cli     => 'first-layer-bed-temperature=i',
        type    => 'i',
    },
    'bed_temperature' => {
        label   => 'Bed Temperature (°C)',
        cli     => 'bed-temperature=i',
        type    => 'i',
    },
    
    # speed options
    'travel_speed' => {
        label   => 'Travel (mm/s)',
        cli     => 'travel-speed=f',
        type    => 'f',
        aliases => [qw(travel_feed_rate)],
    },
    'perimeter_speed' => {
        label   => 'Perimeters (mm/s)',
        cli     => 'perimeter-speed=f',
        type    => 'f',
        aliases => [qw(perimeter_feed_rate)],
    },
    'small_perimeter_speed' => {
        label   => 'Small perimeters (mm/s or %)',
        cli     => 'small-perimeter-speed=s',
        type    => 'f',
        ratio_over => 'perimeter_speed',
    },
    'external_perimeter_speed' => {
        label   => 'External perimeters (mm/s or %)',
        cli     => 'external-perimeter-speed=s',
        type    => 'f',
        ratio_over => 'perimeter_speed',
    },
    'infill_speed' => {
        label   => 'Infill (mm/s)',
        cli     => 'infill-speed=f',
        type    => 'f',
        aliases => [qw(print_feed_rate infill_feed_rate)],
    },
    'solid_infill_speed' => {
        label   => 'Solid infill (mm/s or %)',
        cli     => 'solid-infill-speed=s',
        type    => 'f',
        ratio_over => 'infill_speed',
        aliases => [qw(solid_infill_feed_rate)],
    },
    'top_solid_infill_speed' => {
        label   => 'Top solid infill (mm/s or %)',
        cli     => 'top-solid-infill-speed=s',
        type    => 'f',
        ratio_over => 'solid_infill_speed',
    },
    'bridge_speed' => {
        label   => 'Bridges (mm/s)',
        cli     => 'bridge-speed=f',
        type    => 'f',
        aliases => [qw(bridge_feed_rate)],
    },
    'first_layer_speed' => {
        label   => 'First layer speed (mm/s or %)',
        cli     => 'first-layer-speed=s',
        type    => 'f',
    },
    
    # acceleration options
    'acceleration' => {
        label   => 'Enable acceleration control',
        cli     => 'acceleration!',
        type    => 'bool',
    },
    'perimeter_acceleration' => {
        label   => 'Perimeters (mm/s²)',
        cli     => 'perimeter-acceleration',
        type    => 'f',
    },
    'infill_acceleration' => {
        label   => 'Infill (mm/s²)',
        cli     => 'infill-acceleration',
        type    => 'f',
    },
    
    # accuracy options
    'layer_height' => {
        label   => 'Layer height (mm)',
        cli     => 'layer-height=f',
        type    => 'f',
    },
    'first_layer_height' => {
        label   => 'First layer height (mm or %)',
        cli     => 'first-layer-height=s',
        type    => 'f',
        ratio_over => 'layer_height',
    },
    'infill_every_layers' => {
        label   => 'Infill every N layers',
        cli     => 'infill-every-layers=i',
        type    => 'i',
    },
    
    # flow options
    'extrusion_width' => {
        label   => 'Extrusion width (mm or %; leave zero to calculate automatically)',
        cli     => 'extrusion-width=s',
        type    => 'f',
    },
    'first_layer_extrusion_width' => {
        label   => 'First layer extrusion width (mm or % or 0 for default)',
        cli     => 'first-layer-extrusion-width=s',
        type    => 'f',
    },
    'perimeter_extrusion_width' => {
        label   => 'Perimeter extrusion width (mm or % or 0 for default)',
        cli     => 'perimeter-extrusion-width=s',
        type    => 'f',
        aliases => [qw(perimeters_extrusion_width)],
    },
    'infill_extrusion_width' => {
        label   => 'Infill extrusion width (mm or % or 0 for default)',
        cli     => 'infill-extrusion-width=s',
        type    => 'f',
    },
    'support_material_extrusion_width' => {
        label   => 'Support material extrusion width (mm or % or 0 for default)',
        cli     => 'support-material-extrusion-width=s',
        type    => 'f',
    },
    'bridge_flow_ratio' => {
        label   => 'Bridge flow ratio',
        cli     => 'bridge-flow-ratio=f',
        type    => 'f',
    },
    
    # print options
    'perimeters' => {
        label   => 'Perimeters',
        cli     => 'perimeters=i',
        type    => 'i',
        aliases => [qw(perimeter_offsets)],
    },
    'solid_layers' => {
        label   => 'Solid layers',
        cli     => 'solid-layers=i',
        type    => 'i',
    },
    'fill_pattern' => {
        label   => 'Fill pattern',
        cli     => 'fill-pattern=s',
        type    => 'select',
        values  => [qw(rectilinear line concentric honeycomb hilbertcurve archimedeanchords octagramspiral)],
        labels  => [qw(rectilinear line concentric honeycomb), 'hilbertcurve (slow)', 'archimedeanchords (slow)', 'octagramspiral (slow)'],
    },
    'solid_fill_pattern' => {
        label   => 'Solid fill pattern',
        cli     => 'solid-fill-pattern=s',
        type    => 'select',
        values  => [qw(rectilinear concentric hilbertcurve archimedeanchords octagramspiral)],
        labels  => [qw(rectilinear concentric), 'hilbertcurve (slow)', 'archimedeanchords (slow)', 'octagramspiral (slow)'],
    },
    'fill_density' => {
        label   => 'Fill density',
        cli     => 'fill-density=f',
        type    => 'f',
    },
    'fill_angle' => {
        label   => 'Fill angle (°)',
        cli     => 'fill-angle=i',
        type    => 'i',
    },
    'extra_perimeters' => {
        label   => 'Generate extra perimeters when needed',
        cli     => 'extra-perimeters!',
        type    => 'bool',
    },
    'randomize_start' => {
        label   => 'Randomize starting points',
        cli     => 'randomize-start!',
        type    => 'bool',
    },
    'support_material' => {
        label   => 'Generate support material',
        cli     => 'support-material!',
        type    => 'bool',
    },
    'support_material_threshold' => {
        label   => 'Overhang threshold (°)',
        cli     => 'support-material-threshold=i',
        type    => 'i',
    },
    'support_material_pattern' => {
        label   => 'Pattern',
        cli     => 'support-material-pattern=s',
        type    => 'select',
        values  => [qw(rectilinear honeycomb)],
        labels  => [qw(rectilinear honeycomb)],
    },
    'support_material_spacing' => {
        label   => 'Pattern spacing (mm)',
        cli     => 'support-material-spacing=f',
        type    => 'f',
    },
    'support_material_angle' => {
        label   => 'Pattern angle (°)',
        cli     => 'support-material-angle=i',
        type    => 'i',
    },
    'start_gcode' => {
        label   => 'Start G-code',
        cli     => 'start-gcode=s',
        type    => 's',
        multiline => 1,
        width   => 350,
        height  => 120,
        serialize   => sub { join '\n', split /\R+/, $_[0] },
        deserialize => sub { join "\n", split /\\n/, $_[0] },
    },
    'end_gcode' => {
        label   => 'End G-code',
        cli     => 'end-gcode=s',
        type    => 's',
        multiline => 1,
        width   => 350,
        height  => 120,
        serialize   => sub { join '\n', split /\R+/, $_[0] },
        deserialize => sub { join "\n", split /\\n/, $_[0] },
    },
    'layer_gcode' => {
        label   => 'Layer change G-code',
        cli     => 'layer-gcode=s',
        type    => 's',
        multiline => 1,
        width   => 350,
        height  => 50,
        serialize   => sub { join '\n', split /\R+/, $_[0] },
        deserialize => sub { join "\n", split /\\n/, $_[0] },
    },
    'post_process' => {
        label   => 'Post-processing scripts',
        cli     => 'post-process=s@',
        type    => 's@',
        multiline => 1,
        width   => 350,
        height  => 60,
        serialize   => sub { join '; ', @{$_[0]} },
        deserialize => sub { [ split /\s*;\s*/, $_[0] ] },
    },
    
    # retraction options
    'retract_length' => {
        label   => 'Length (mm)',
        cli     => 'retract-length=f',
        type    => 'f',
    },
    'retract_speed' => {
        label   => 'Speed (mm/s)',
        cli     => 'retract-speed=f',
        type    => 'i',
    },
    'retract_restart_extra' => {
        label   => 'Extra length on restart (mm)',
        cli     => 'retract-restart-extra=f',
        type    => 'f',
    },
    'retract_before_travel' => {
        label   => 'Minimum travel after retraction (mm)',
        cli     => 'retract-before-travel=f',
        type    => 'f',
    },
    'retract_lift' => {
        label   => 'Lift Z (mm)',
        cli     => 'retract-lift=f',
        type    => 'f',
    },
    
    # cooling options
    'cooling' => {
        label   => 'Enable cooling',
        cli     => 'cooling!',
        type    => 'bool',
    },
    'min_fan_speed' => {
        label   => 'Min fan speed (%)',
        cli     => 'min-fan-speed=i',
        type    => 'i',
    },
    'max_fan_speed' => {
        label   => 'Max fan speed (%)',
        cli     => 'max-fan-speed=i',
        type    => 'i',
    },
    'bridge_fan_speed' => {
        label   => 'Bridge fan speed (%)',
        cli     => 'bridge-fan-speed=i',
        type    => 'i',
    },
    'fan_below_layer_time' => {
        label   => 'Enable fan if layer print time is below (approximate seconds)',
        cli     => 'fan-below-layer-time=i',
        type    => 'i',
    },
    'slowdown_below_layer_time' => {
        label   => 'Slow down if layer print time is below (approximate seconds)',
        cli     => 'slowdown-below-layer-time=i',
        type    => 'i',
    },
    'min_print_speed' => {
        label   => 'Min print speed (mm/s)',
        cli     => 'min-print-speed=f',
        type    => 'i',
    },
    'disable_fan_first_layers' => {
        label   => 'Disable fan for the first N layers',
        cli     => 'disable-fan-first-layers=i',
        type    => 'i',
    },
    'fan_always_on' => {
        label   => 'Keep fan always on',
        cli     => 'fan-always-on!',
        type    => 'bool',
    },
    
    # skirt/brim options
    'skirts' => {
        label   => 'Loops',
        cli     => 'skirts=i',
        type    => 'i',
    },
    'skirt_distance' => {
        label   => 'Distance from object (mm)',
        cli     => 'skirt-distance=f',
        type    => 'f',
    },
    'skirt_height' => {
        label   => 'Skirt height (layers)',
        cli     => 'skirt-height=i',
        type    => 'i',
    },
    'brim_width' => {
        label   => 'Brim width (mm)',
        cli     => 'brim-width=f',
        type    => 'f',
    },
    
    # transform options
    'scale' => {
        label   => 'Scale',
        cli     => 'scale=f',
        type    => 'f',
    },
    'rotate' => {
        label   => 'Rotate (°)',
        cli     => 'rotate=i',
        type    => 'i',
    },
    'duplicate_mode' => {
        label   => 'Duplicate',
        gui_only => 1,
        type    => 'select',
        values  => [qw(no autoarrange grid)],
        labels  => ['No', 'Autoarrange', 'Grid'],
    },
    'duplicate' => {
        label    => 'Copies (autoarrange)',
        cli      => 'duplicate=i',
        type    => 'i',
    },
    'bed_size' => {
        label   => 'Bed size (mm)',
        cli     => 'bed-size=s',
        type    => 'point',
        serialize   => sub { join ',', @{$_[0]} },
        deserialize => sub { [ split /,/, $_[0] ] },
    },
    'duplicate_grid' => {
        label   => 'Copies (grid)',
        cli     => 'duplicate-grid=s',
        type    => 'point',
        serialize   => sub { join ',', @{$_[0]} },
        deserialize => sub { [ split /,/, $_[0] ] },
    },
    'duplicate_distance' => {
        label   => 'Distance between copies',
        cli     => 'duplicate-distance=f',
        type    => 'i',
        aliases => [qw(multiply_distance)],
    },
    
    # sequential printing options
    'complete_objects' => {
        label   => 'Complete individual objects (watch out for extruder collisions)',
        cli     => 'complete-objects!',
        type    => 'bool',
    },
    'extruder_clearance_radius' => {
        label   => 'Extruder clearance radius (mm)',
        cli     => 'extruder-clearance-radius=f',
        type    => 'i',
    },
    'extruder_clearance_height' => {
        label   => 'Extruder clearance height (mm)',
        cli     => 'extruder-clearance-height=f',
        type    => 'i',
    },
    'raft_pattern_angle' => {
        label   => 'Raft Pattern angle (°)',
        cli     => 'raft-pattern-angle=i',
        type    => 'i',
    },
    'raft_pattern' => {
        label   => 'Pattern',
        cli     => 'raft-pattern=s',
        type    => 'select',
        values  => [qw(rectilinear honeycomb)],
        labels  => [qw(rectilinear honeycomb)],
    },
    'raft_height' => {
        label   => 'raft height (layers)',
        cli     => 'raft-height=i',
        type    => 'i',
    },
    'raft_density' => {
        label   => 'Raft fill density 0-100%',
        cli     => 'raft-density=f',
        type    => 'f',
    },
};

sub get {
    my $class = @_ == 2 ? shift : undef;
    my ($opt_key) = @_;
    no strict 'refs';
    my $value = ${"Slic3r::$opt_key"};
    $value = get($Options->{$opt_key}{ratio_over}) * $1/100
        if $Options->{$opt_key}{ratio_over} && $value =~ /^(\d+(?:\.\d+)?)%$/;
    return $value;
}

sub get_raw {
    my $class = @_ == 2 ? shift : undef;
    my ($opt_key) = @_;
    no strict 'refs';
    my $value = ${"Slic3r::$opt_key"};
    return $value;
}

sub set {
    my $class = @_ == 3 ? shift : undef;
    my ($opt_key, $value) = @_;
    no strict 'refs';
    ${"Slic3r::$opt_key"} = $value;
}

sub serialize {
    my $class = @_ == 2 ? shift : undef;
    my ($opt_key) = @_;
    return $Options->{$opt_key}{serialize}
        ? $Options->{$opt_key}{serialize}->(get_raw($opt_key))
        : get_raw($opt_key);
}

sub deserialize {
    my $class = @_ == 3 ? shift : undef;
    my ($opt_key, $value) = @_;
    return $Options->{$opt_key}{deserialize}
        ? set($opt_key, $Options->{$opt_key}{deserialize}->($value))
        : set($opt_key, $value);
}

sub save {
    my $class = shift;
    my ($file) = @_;
    
    open my $fh, '>', $file;
    binmode $fh, ':utf8';
    printf $fh "# generated by Slic3r $Slic3r::VERSION\n";
    foreach my $opt (sort keys %$Options) {
        next if $Options->{$opt}{gui_only};
        my $value = get_raw($opt);
        $value = $Options->{$opt}{serialize}->($value) if $Options->{$opt}{serialize};
        printf $fh "%s = %s\n", $opt, $value;
    }
    close $fh;
}

sub setenv {
    my $class = shift;
    foreach my $opt (sort keys %$Options) {
        next if $Options->{$opt}{gui_only};
        my $value = get($opt);
        $value = $Options->{$opt}{serialize}->($value) if $Options->{$opt}{serialize};
        $ENV{"SLIC3R_" . uc $opt} = $value;
    }
}

sub load {
    my $class = shift;
    my ($file) = @_;
    
    my %ignore = map { $_ => 1 } @Ignore;
    
    local $/ = "\n";
    open my $fh, '<', $file;
    binmode $fh, ':utf8';
    while (<$fh>) {
        s/\R+$//;
        next if /^\s+/;
        next if /^$/;
        next if /^\s*#/;
        /^(\w+) = (.*)/ or die "Unreadable configuration file (invalid data at line $.)\n";
        my ($key, $val) = ($1, $2);
        
        # handle legacy options
        next if $ignore{$key};
        if ($key =~ /^(extrusion_width|bottom_layer_speed|first_layer_height)_ratio$/) {
            $key = $1;
            $key =~ s/^bottom_layer_speed$/first_layer_speed/;
            $val = $val =~ /^\d+(?:\.\d+)?$/ && $val != 0 ? ($val*100) . "%" : 0;
        }
        
        if (!exists $Options->{$key}) {
            $key = +(grep { $Options->{$_}{aliases} && grep $_ eq $key, @{$Options->{$_}{aliases}} }
                keys %$Options)[0] or warn "Unknown option $key at line $.\n";
        }
        next unless $key;
        my $opt = $Options->{$key};
        set($key, $opt->{deserialize} ? $opt->{deserialize}->($val) : $val);
    }
    close $fh;
}

sub validate_cli {
    my $class = shift;
    my ($opt) = @_;
    
    for (qw(start end layer)) {
        if (defined $opt->{$_."_gcode"}) {
            if ($opt->{$_."_gcode"} eq "") {
                set($_."_gcode", "");
            } else {
                die "Invalid value for --${_}-gcode: file does not exist"
                    if !-e $opt->{$_."_gcode"};
                open my $fh, "<", $opt->{$_."_gcode"};
                $opt->{$_."_gcode"} = do { local $/; <$fh> };
                close $fh;
            }
        }
    }
}

sub validate {
    my $class = shift;
    
    # -j, --threads
    die "Invalid value for --threads\n"
        if $Slic3r::threads < 1;
    die "Your perl wasn't built with multithread support\n"
        if $Slic3r::threads > 1 && !$Slic3r::have_threads;

    # --layer-height
    die "Invalid value for --layer-height\n"
        if $Slic3r::layer_height <= 0;
    die "--layer-height must be a multiple of print resolution\n"
        if $Slic3r::layer_height / $Slic3r::scaling_factor % 1 != 0;
    
    # --first-layer-height
    die "Invalid value for --first-layer-height\n"
        if $Slic3r::first_layer_height !~ /^(?:\d*(?:\.\d+)?)%?$/;
    $Slic3r::_first_layer_height = Slic3r::Config->get('first_layer_height');
    
    # --filament-diameter
    die "Invalid value for --filament-diameter\n"
        if grep $_ < 1, @$Slic3r::filament_diameter;
    
    # --nozzle-diameter
    die "Invalid value for --nozzle-diameter\n"
        if grep $_ < 0, @$Slic3r::nozzle_diameter;
    die "--layer-height can't be greater than --nozzle-diameter\n"
        if grep $Slic3r::layer_height > $_, @$Slic3r::nozzle_diameter;
    die "First layer height can't be greater than --nozzle-diameter\n"
        if grep $Slic3r::_first_layer_height > $_, @$Slic3r::nozzle_diameter;
    
    # initialize extruder(s)
    $Slic3r::extruders = [];
    for my $t (0, map $_-1, $Slic3r::perimeter_extruder, $Slic3r::infill_extruder, $Slic3r::support_material_extruder) {
        $Slic3r::extruders->[$t] ||= Slic3r::Extruder->new(
            map { $_ => Slic3r::Config->get($_)->[$t] // Slic3r::Config->get($_)->[0] } #/
                qw(nozzle_diameter filament_diameter extrusion_multiplier temperature first_layer_temperature)
        );
    }
    
    # calculate flow
    $Slic3r::flow = $Slic3r::extruders->[0]->make_flow(width => $Slic3r::extrusion_width);
    if ($Slic3r::first_layer_extrusion_width) {
        $Slic3r::first_layer_flow = $Slic3r::extruders->[0]->make_flow(
            layer_height => $Slic3r::_first_layer_height,
            width        => $Slic3r::first_layer_extrusion_width,
        );
    }
    $Slic3r::perimeters_flow = $Slic3r::extruders->[ $Slic3r::perimeter_extruder-1 ]
        ->make_flow(width => $Slic3r::perimeter_extrusion_width || $Slic3r::extrusion_width);
    $Slic3r::infill_flow = $Slic3r::extruders->[ $Slic3r::infill_extruder-1 ]
        ->make_flow(width => $Slic3r::infill_extrusion_width || $Slic3r::extrusion_width);
    $Slic3r::support_material_flow = $Slic3r::extruders->[ $Slic3r::support_material_extruder-1 ]
        ->make_flow(width => $Slic3r::support_material_extrusion_width || $Slic3r::extrusion_width);
    
    Slic3r::debugf "Default flow width = %s (spacing = %s)\n",
        $Slic3r::flow->width, $Slic3r::flow->spacing;
    
    # --perimeters
    die "Invalid value for --perimeters\n"
        if $Slic3r::perimeters < 0;
    
    # --solid-layers
    die "Invalid value for --solid-layers\n"
        if $Slic3r::solid_layers < 0;
    
    # --print-center
    die "Invalid value for --print-center\n"
        if !ref $Slic3r::print_center 
            && (!$Slic3r::print_center || $Slic3r::print_center !~ /^\d+,\d+$/);
    $Slic3r::print_center = [ split /[,x]/, $Slic3r::print_center ]
        if !ref $Slic3r::print_center;
    
    # --fill-pattern
    die "Invalid value for --fill-pattern\n"
        if !exists $Slic3r::Fill::FillTypes{$Slic3r::fill_pattern};
    
    # --solid-fill-pattern
    die "Invalid value for --solid-fill-pattern\n"
        if !exists $Slic3r::Fill::FillTypes{$Slic3r::solid_fill_pattern};
    
    # --fill-density
    die "Invalid value for --fill-density\n"
        if $Slic3r::fill_density < 0 || $Slic3r::fill_density > 1;
    
    # --infill-every-layers
    die "Invalid value for --infill-every-layers\n"
        if $Slic3r::infill_every_layers !~ /^\d+$/ || $Slic3r::infill_every_layers < 1;
    # TODO: this check should be limited to the extruder used for infill
    die "Maximum infill thickness can't exceed nozzle diameter\n"
        if grep $Slic3r::infill_every_layers * $Slic3r::layer_height > $_, @$Slic3r::nozzle_diameter;
    
    # --scale
    die "Invalid value for --scale\n"
        if $Slic3r::scale <= 0;
    
    # --bed-size
    die "Invalid value for --bed-size\n"
        if !ref $Slic3r::bed_size 
            && (!$Slic3r::bed_size || $Slic3r::bed_size !~ /^\d+,\d+$/);
    $Slic3r::bed_size = [ split /[,x]/, $Slic3r::bed_size ]
        if !ref $Slic3r::bed_size;
    
    # --duplicate-grid
    die "Invalid value for --duplicate-grid\n"
        if !ref $Slic3r::duplicate_grid 
            && (!$Slic3r::duplicate_grid || $Slic3r::duplicate_grid !~ /^\d+,\d+$/);
    $Slic3r::duplicate_grid = [ split /[,x]/, $Slic3r::duplicate_grid ]
        if !ref $Slic3r::duplicate_grid;
    
    # --duplicate
    die "Invalid value for --duplicate or --duplicate-grid\n"
        if !$Slic3r::duplicate || $Slic3r::duplicate < 1 || !$Slic3r::duplicate_grid
            || (grep !$_, @$Slic3r::duplicate_grid);
    die "Use either --duplicate or --duplicate-grid (using both doesn't make sense)\n"
        if $Slic3r::duplicate > 1 && $Slic3r::duplicate_grid && (grep $_ && $_ > 1, @$Slic3r::duplicate_grid);
    $Slic3r::duplicate_mode = 'autoarrange' if $Slic3r::duplicate > 1;
    $Slic3r::duplicate_mode = 'grid' if grep $_ && $_ > 1, @$Slic3r::duplicate_grid;
    
    # --skirt-height
    die "Invalid value for --skirt-height\n"
        if $Slic3r::skirt_height < 0;
    
    # --bridge-flow-ratio
    die "Invalid value for --bridge-flow-ratio\n"
        if $Slic3r::bridge_flow_ratio <= 0;
    
    # extruder clearance
    die "Invalid value for --extruder-clearance-radius\n"
        if $Slic3r::extruder_clearance_radius <= 0;
    die "Invalid value for --extruder-clearance-height\n"
        if $Slic3r::extruder_clearance_height <= 0;
    
    $_->first_layer_temperature($_->temperature) for grep !defined $_->first_layer_temperature, @$Slic3r::extruders;
    $Slic3r::first_layer_temperature->[$_] = $Slic3r::extruders->[$_]->first_layer_temperature for 0 .. $#$Slic3r::extruders;  # this is needed to provide a value to the legacy GUI and for config file re-serialization
    $Slic3r::first_layer_bed_temperature //= $Slic3r::bed_temperature;  #/
    
    # G-code flavors
    $Slic3r::extrusion_axis = 'A' if $Slic3r::gcode_flavor eq 'mach3';
    $Slic3r::extrusion_axis = ''  if $Slic3r::gcode_flavor eq 'no-extrusion';
    
    # legacy with existing config files
    $Slic3r::small_perimeter_speed ||= $Slic3r::perimeter_speed;
    $Slic3r::bridge_speed ||= $Slic3r::infill_speed;
    $Slic3r::solid_infill_speed ||= $Slic3r::infill_speed;
    $Slic3r::top_solid_infill_speed ||= $Slic3r::solid_infill_speed;

    die "Invalid value for --raft-height\n"
        if $Slic3r::raft_height < 0;
}

sub replace_options {
    my $class = shift;
    my ($string, $more_variables) = @_;
    
    if ($more_variables) {
        my $variables = join '|', keys %$more_variables;
        $string =~ s/\[($variables)\]/$more_variables->{$1}/eg;
    }
    
    my @lt = localtime; $lt[5] += 1900; $lt[4] += 1;
    $string =~ s/\[timestamp\]/sprintf '%04d%02d%02d-%02d%02d%02d', @lt[5,4,3,2,1,0]/egx;
    $string =~ s/\[year\]/$lt[5]/eg;
    $string =~ s/\[month\]/$lt[4]/eg;
    $string =~ s/\[day\]/$lt[3]/eg;
    $string =~ s/\[hour\]/$lt[2]/eg;
    $string =~ s/\[minute\]/$lt[1]/eg;
    $string =~ s/\[second\]/$lt[0]/eg;
    $string =~ s/\[version\]/$Slic3r::VERSION/eg;
    
    # build a regexp to match the available options
    my $options = join '|',
        grep !$Slic3r::Config::Options->{$_}{multiline},
        keys %$Slic3r::Config::Options;
    
    # use that regexp to search and replace option names with option values
    $string =~ s/\[($options)\]/Slic3r::Config->serialize($1)/eg;
    return $string;
}

1;
