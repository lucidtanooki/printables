//
// Mattel Mega Bloks to LEGO Duplo Adapter Generator
//
// Author: Georg Eckert (lucidtanooki@magenta.de)
// Url: https://github.com/lucidtanooki/printables
//
// Based on:
// 
// -- ORIGINAL HEADER START --
//
// LEGO DUPLO BRICK GENERATOR
// 
// Author: Emanuele Iannone (emanuele@fondani.it)
// Url: https://www.thingiverse.com/thing:3113862
//
// Modified for colour letters on top, rounded
// edges, ridges and corners, and sloped stud tops 
//
// by 247generator@thingiverse - 2018
//
// https://www.thingiverse.com/thing:3122711
//
// -- ORIGINAL HEADER END --

/* [Main] */

// Mega studs along X axis.
xSize = 3; // [1:12]

// Mega studs along Y axis.
ySize = 2; // [1:12]

// (1 = standard brick height, 0.5 = base or cap)
zSize = 2; // [0.5,1,2,3,4,5]

// Brick or thin base plate.
baseType = 1; // [1: Brick, 2: Base Plate]

// Flat or studs on top.
enableStuds = 1; // [0: Flat, 1: Studs]

/* [Advanced] */
// Size of a single medi stud section.
baseUnit = 15.75;
// Size of a single mega stud section.
megaUnit = 2 * baseUnit;
// Ridge unit.
ridgeUnit = baseUnit / 2;
// standard height of a block (0.1 added to make up for first layer adhesion squish)
heightUnit = 19.35;
// vertical walls thickness
wallThickness = 1.2;
// Inner walls
innerWallThickness = 0.8;
// top surface thickness
roofThickness = 1.4;
// thin base plate thickness (minimum of double rounded corners)
basePlateThickness = 1.8;
// stud outer radius
studRadius = 4.7;
// height of the gripping section of the stud
studHeight = 4.0;
// height of the guiding section of the stud
studGuide = 0.7;
// grip thickness
ridgeThickness = 0.6;
// ridge extension (controls grip)
ridgeWidth = 4.1;
// Duplo has unsharp corners for safety, printing thinner layers improves roundness
roundedCorners = 0.9; //[0.0:0.1:2.0]
// how curved or polygonal the above rounded corners are
circleResolutionCoarse = 24; //[5:1:60]
circleResolutionFine = 60;

origin = heightUnit * zSize;

// Main
if( baseType == 2 )
{
    CreateBasePlate( xSize, ySize, basePlateThickness );
}
else
{
    CreateBrick( xSize, ySize, zSize, enableStuds );
}
        

module CreateBrick( xStuds, yStuds, heightfact, enableStuds = true )
{
    height = heightfact * heightUnit;
    dx = xStuds * megaUnit;
    dy = yStuds * megaUnit;
    
    union() 
    {
        // Shell
        difference()
        {
            rcube([ dx, dy, height ], roundedCorners);
            translate( v = [ wallThickness, wallThickness, -1] )
            {
                cube([
                    dx - wallThickness * 2,
                    dy - wallThickness * 2,
                    height - roofThickness + 1 ]);
            }
        }
    
        // Studs
        if( enableStuds )
        for( r = [ 0 : xStuds * 2 - 1 ] )
        for( c = [ 0 : yStuds * 2 - 1 ] )
        {
            CreateStud(
                baseUnit / 2 + r * baseUnit,
                baseUnit / 2 + c * baseUnit,
                height,
                studRadius);
        }
       
        // Ridges
        for( xMegaStud = [ 0 : xStuds - 1 ] )
        for( yMegaStud = [ 0 : yStuds - 1 ] )
        {
            CreateRidgeSet( xMegaStud, yMegaStud, height);
        }
        
        // Inner walls
        CreateInnerWalls( xStuds, yStuds, heightfact );
    }
}


module CreateBasePlate (nx, ny, height)
{
    dx = nx * baseUnit;
    dy = ny * baseUnit;
        
    // plate
    rcube( [ dx, dy, height ], roundedCorners);
        
    // studs
    for( r = [ 0 : nx - 1 ] )
    for( c = [ 0 : ny - 1 ] )
    {
        CreateStud(
            baseUnit/2 + r * baseUnit,
            baseUnit/2 + c * baseUnit,
            height,
            studRadius);
    }
}


module CreateInnerWalls( x, y, z )
{
    // <>
    innerWallHeight = z * heightUnit - roofThickness + 0.2;
    
    if( x > 1 )
    for( ix = [ 1 : x - 1 ] )
    {
        translate([ ix * megaUnit, y * megaUnit / 2, innerWallHeight / 2 ])
        {
            cube([ innerWallThickness, y * megaUnit - wallThickness, innerWallHeight ], true );
        }
    }
    
    if( y > 1 )
    for( iy = [ 1 : y - 1 ] )
    {
        translate([ x * megaUnit / 2, iy * megaUnit, innerWallHeight / 2 ])
        {
            cube([ x * megaUnit - wallThickness, innerWallThickness, innerWallHeight ], true );
        }
    }
}


module CreateStud(x, y, z, r)
{
    translate( v = [ x, y, studHeight / 2 + z] )
    {
        difference()
        {
           union()
           {
               cylinder( h = studHeight, r = r, center = true, $fn = circleResolutionFine );
               translate([ 0, 0, ( ( studHeight + studGuide ) / 2 ) ])
               {
                   color( "green" ) 
                   cylinder(
                       h = studGuide,
                       r1 = r,
                       r2 = r - ( r * 0.12 ),
                       center = true,
                       $fn = circleResolutionFine );
               }
           }
      
           cylinder(
               h = ( studHeight + studGuide ) * 1.5,
               r1 = r-1.2,
               r2 = r-1.2,
               center = true,
               $fn = circleResolutionFine );
    }
  }
}


module CreateRidgeSet( xStud, yStud, height )
{
    x = xStud * megaUnit;
    y = yStud * megaUnit;
    
    angles = [ 0, 90, 180, 270 ];
    offsets = [[ 0, 0, 0 ],
               [ 1, 0, 0 ],
               [ 1, 1, 0 ],
               [ 0, 1, 0 ]];
    
    for( i = [ 0 : 3 ] ){
    translate( [ x, y, 0 ] )
    translate( [ offsets[i].x * megaUnit, offsets[i].y * megaUnit, 0 ] )
    rotate( [ 0, 0, angles[i]] )
    {
        for( i = [ 1, 3 ] )
        {
            translate( [ i * ridgeUnit - ridgeThickness / 2, 0, 0 ] )
            rotate( [ 90, 0, 90 ] )
            {
                translate( [ wallThickness - 0.2, 0, 0 ] )
                {
                    // standard ridge
                    union ()
                    {
                        translate([ -0.6, 0, 0 ])
                        cube([
                            1.8,
                            height - roofThickness + 0.2,
                            ridgeThickness ]);
                        
                        translate([ 0.9, 1.2, 0 ])
                        cylinder(
                            r = 1.2,
                            h = ridgeThickness,
                            $fn = circleResolutionCoarse );
                        
                        translate([ 0.8, 1.2, 0 ])
                        cube([
                            1.3,
                            height - roofThickness + 0.2 - 1.2,
                            ridgeThickness ]);
                        
                        translate([ 2.3, 8, 0 ])
                        cylinder(
                            r = 1.6,
                            h = ridgeThickness,
                            $fn = circleResolutionCoarse );
                            
                        translate([ 2, 8, 0 ])
                        cube([
                            1.9,
                            height - roofThickness + 0.2 - 8,
                            ridgeThickness ]);
                    }
                }
            }
        }
    }}
}


// Rounded primitives for openscad
// (c) 2013 Wouter Robers 
// crude hack for centering and 0 rounding fail - 2018 by 247generator
module rcube(Size=[10,10,10],b=1,center=false)
{$fn=circleResolutionCoarse;b=b+0.00001;if (center==true){m=0;translate([(Size[0]*m),(Size[1]*m),(Size[2]*m)]){hull(){for(x=[-(Size[0]/2-b),(Size[0]/2-b)]){for(y=[-(Size[1]/2-b),(Size[1]/2-b)]){for(z=[-(Size[2]/2-b),(Size[2]/2-b)]){ translate([x,y,z]) sphere(b);}}}}}}else{m=0.5;translate([(Size[0]*m),(Size[1]*m),(Size[2]*m)]){hull(){for(x=[-(Size[0]/2-b),(Size[0]/2-b)]){for(y=[-(Size[1]/2-b),(Size[1]/2-b)]){for(z=[-(Size[2]/2-b),(Size[2]/2-b)]){ translate([x,y,z]) sphere(b);}}}}}}}
