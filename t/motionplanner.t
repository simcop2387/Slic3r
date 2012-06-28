use Test::More;
use strict;
use warnings;

plan tests => 10;

BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/../lib";
}

use Slic3r;

#==========================================================

{
    my $square = Slic3r::ExPolygon->new(
        Slic3r::Polygon->new([0,0], [10,0], [10,10], [0,10]),
    );
    my $path = $square->internal_path(
        Slic3r::Point->new(2,2),
        Slic3r::Point->new(8,8),
    );
    is_deeply $path, [[2,2], [8,8]], 'straight line in square';
}

{
    my $square_with_hole = Slic3r::ExPolygon->new(
        Slic3r::Polygon->new([0,0], [10,0], [10,10], [0,10]),
        Slic3r::Polygon->new([4,4], [4,6], [6,6], [6,4]),
    );
    ok $square_with_hole->encloses_line(Slic3r::Line->new([4,4], [4,6])), 'expolygon encloses line';
    ok !$square_with_hole->encloses_line(Slic3r::Line->new([10,0], [4,6])), 'expolygon does not enclose line';
    
    my $path1 = $square_with_hole->internal_path(
        Slic3r::Point->new(2,2),
        Slic3r::Point->new(8,8),
    );
    is_deeply $path1, [[2,2], [4,6], [8,8]], 'square with hole';
    
    my $path2 = $square_with_hole->internal_path(
        Slic3r::Point->new(2,5),
        Slic3r::Point->new(8,5),
    );
    is_deeply $path2, [[2,5], [4,4], [6,4], [8,5]], 'square with hole';
}

{
    my $rectangle_with_holes = Slic3r::ExPolygon->new(
        Slic3r::Polygon->new([0,0], [20,0], [20,10], [0,10]),
        Slic3r::Polygon->new([4,2], [4,8], [6,8], [6,2]),
        Slic3r::Polygon->new([12,4], [12,6], [14,6], [14,4]),
    );
    
    my $path1 = $rectangle_with_holes->internal_path(
        Slic3r::Point->new(2,4),
        Slic3r::Point->new(15,5.5),
    );
    is_deeply $path1, [[2,4], [4,2], [6,2], [14,4], [15,5.5]], 'square with holes';
}

#==========================================================

{
    local $Slic3r::scaling_factor = 1;
    $Slic3r::flow = Slic3r::Flow->new(width => 0.5);
    my $rectangle_with_holes = Slic3r::ExPolygon->new(
        Slic3r::Polygon->new([0,0], [30,0], [30,16], [0,16]),
        Slic3r::Polygon->new([6,6], [6,11], [8,11], [8,6]),
        Slic3r::Polygon->new([16,8], [16,10], [20,10], [20,8]),
    );
    my $mp = Slic3r::Extruder::MotionPlanner->new(
        islands         => [$rectangle_with_holes],
        bounding_box_p  => Slic3r::Polygon->new_from_bounding_box(+($rectangle_with_holes->offset_ex(5))[0]->bounding_box),
        _inner_margin   => 2,
    );
    
    if (0) {
        require "Slic3r/SVG.pm";
        Slic3r::SVG::output(undef, "space.svg",
            points          => [ values %{$mp->_pointmap} ],
            polygons        => [ map @$_, @{$mp->islands} ],
            red_polygons    => [ map $_->holes, map @$_, @{$mp->_inner} ],
        );
    }
    
    my $sp = sub { $mp->shortest_path(map Slic3r::Point->new($_), @_) };
    
    is_deeply $sp->([1,8], [29,8]), [[1,8], [4,4], [28,2], [29,8]], 'motion planner - inside island';
    is_deeply $sp->([7,8], [30,16]), [[7,8], [10,4], [23,8], [28,14], [30,16]], 'motion planner - from hole to contour';
    is_deeply $sp->([7,8], [18,9]), [[7,8], [10,4], [14,6], [18,9]], 'motion planner - from hole to hole';
    is_deeply $sp->([20,20], [20,1]), [[20,20], [32,18], [20,1]], 'motion planner - from outside to inside';
}

#==========================================================
1;