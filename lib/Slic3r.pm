package Slic3r;

# Copyright holder: Alessandro Ranellucci
# This application is licensed under the GNU Affero General Public License, version 3

use strict;
use warnings;
require v5.10;

our $VERSION = "0.8.5-dev";

our $debug = 0;
sub debugf {
    printf @_ if $debug;
}

# load threads before Moo as required by it
our $have_threads;
BEGIN {
    use Config;
    $have_threads = $Config{useithreads} && eval "use threads; use Thread::Queue; 1";
}

use FindBin;
our $var = "$FindBin::Bin/var";

use Moo 0.091009;
use Slic3r::Config;
use Slic3r::ExPolygon;
use Slic3r::Extruder;
use Slic3r::ExtrusionLoop;
use Slic3r::ExtrusionPath;
use Slic3r::ExtrusionPath::Arc;
use Slic3r::ExtrusionPath::Collection;
use Slic3r::Fill;
use Slic3r::Flow;
use Slic3r::Format::AMF;
use Slic3r::Format::OBJ;
use Slic3r::Format::STL;
use Slic3r::GCode;
use Slic3r::Geometry qw(PI);
use Slic3r::Layer;
use Slic3r::Line;
use Slic3r::Point;
use Slic3r::Polygon;
use Slic3r::Polyline;
use Slic3r::Print;
use Slic3r::Print::Object;
use Slic3r::Surface;
use Slic3r::TriangleMesh;
eval "use Slic3r::Build";

our $threads            = $have_threads ? 2 : 1;

# miscellaneous options
our $notes              = '';

# output options
our $output_filename_format = '[input_filename_base].gcode';
our $post_process       = [];

# printer options
our $print_center       = [100,100];  # object will be centered around this point
our $z_offset           = 0;
our $gcode_flavor       = 'reprap';
our $use_relative_e_distances = 0;
our $extrusion_axis     = 'E';
our $gcode_arcs         = 0;
our $g0                 = 0;
our $gcode_comments     = 0;

# filament options
our $bed_temperature    = 0;
our $first_layer_bed_temperature;

# extruders
our $extruders              = [];
our $nozzle_diameter        = [0.5];
our $filament_diameter      = [3];    # mm
our $extrusion_multiplier   = [1];
our $temperature            = [200];
our $first_layer_temperature= [];

# extruder mapping (1-based indexes)
our $perimeter_extruder         = 1;
our $infill_extruder            = 1;
our $support_material_extruder  = 1;

# speed options
our $travel_speed           = 130;      # mm/s
our $perimeter_speed        = 30;       # mm/s
our $small_perimeter_speed  = 30;       # mm/s or %
our $external_perimeter_speed  = '100%';       # mm/s or %
our $infill_speed           = 60;       # mm/s
our $solid_infill_speed     = 60;       # mm/s or %
our $top_solid_infill_speed = 50;       # mm/s or %
our $bridge_speed           = 60;       # mm/s
our $first_layer_speed      = '30%';    # mm/s or %  

# acceleration options
our $acceleration           = 0;
our $perimeter_acceleration = 25;   # mm/s^2
our $infill_acceleration    = 50;   # mm/s^2

# accuracy options
our $scaling_factor         = 0.000001;
our $resolution             = 0.01;
our $small_perimeter_length = (6.5 / $scaling_factor)*2*PI;
our $layer_height           = 0.4;
our $first_layer_height     = '100%';  # mm or %
our $_first_layer_height    = undef;   # mm (computed)
our $infill_every_layers    = 1;

# flow options
our $extrusion_width                = 0;
our $first_layer_extrusion_width    = '200%';
our $perimeter_extrusion_width      = 0;
our $infill_extrusion_width         = 0;
our $support_material_extrusion_width = 0;
our $bridge_flow_ratio              = 1;
our $overlap_factor                 = 0.5;
our $flow;
our $first_layer_flow;
our $perimeters_flow;
our $infill_flow;
our $support_material_flow;
our $raft_material_flow;

# print options
our $perimeters         = 3;
our $solid_layers       = 3;
our $fill_pattern       = 'rectilinear';
our $solid_fill_pattern = 'rectilinear';
our $fill_density       = 0.4;  # 1 = 100%
our $fill_angle         = 45;
our $extra_perimeters   = 1;
our $randomize_start    = 1;
our $support_material   = 0;
our $support_material_threshold = 45;
our $support_material_pattern = 'rectilinear';
our $support_material_spacing = 2.5;
our $support_material_angle = 0;
our $start_gcode = "G28 ; home all axes";
our $end_gcode = <<"END";
M104 S0 ; turn off temperature
G28 X0  ; home X axis
M84     ; disable motors
END
our $layer_gcode        = '';

# retraction options
our $retract_length         = 1;    # mm
our $retract_restart_extra  = 0;    # mm
our $retract_speed          = 30;   # mm/s
our $retract_before_travel  = 2;    # mm
our $retract_lift           = 0;    # mm

# cooling options
our $cooling                = 0;
our $min_fan_speed          = 35;
our $max_fan_speed          = 100;
our $bridge_fan_speed       = 100;
our $fan_below_layer_time   = 60;
our $slowdown_below_layer_time = 15;
our $min_print_speed        = 10;
our $disable_fan_first_layers = 1;
our $fan_always_on          = 0;

# skirt/brim options
our $skirts             = 1;
our $skirt_distance     = 6;    # mm
our $skirt_height       = 1;    # layers
our $brim_width         = 0;    # mm

# transform options
our $scale              = 1;
our $rotate             = 0;
our $duplicate_mode     = 'no';
our $duplicate          = 1;
our $bed_size           = [200,200];
our $duplicate_grid     = [1,1];
our $duplicate_distance = 6;    # mm

# sequential printing
our $complete_objects           = 0;
our $extruder_clearance_radius  = 20;     # mm
our $extruder_clearance_height  = 20;     # mm

# raft options
our $raft_height = 0; # layers
our $raft_width  = 4; # mm, no option for this yet, should there be? TODO
our $raft_pattern = "rectilinear"; # fill pattern
our $raft_pattern_angle = 0; # degrees, 0 seems to be a better default if we have rounded corners
our $raft_density = 0.2; # 1 == 100%

sub parallelize {
    my %params = @_;
    
    if (!$params{disable} && $Slic3r::have_threads && $Slic3r::threads > 1) {
        my $q = Thread::Queue->new;
        $q->enqueue(@{ $params{items} }, (map undef, 1..$Slic3r::threads));
        
        my $thread_cb = sub { $params{thread_cb}->($q) };
        foreach my $th (map threads->create($thread_cb), 1..$Slic3r::threads) {
            $params{collect_cb}->($th->join);
        }
    } else {
        $params{no_threads_cb}->();
    }
}

1;
