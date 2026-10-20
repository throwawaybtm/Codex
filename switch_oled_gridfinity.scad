/*
 Nintendo Switch OLED: standalone 7 x 6 Gridfinity, one-tier tray.
 OpenSCAD 2021.01+, millimeters, no external libraries.

 APPROVED LAYOUT REVISION: retain 294 x 252 XY; rearrange partitions and
 increase height to 70 (10U). All rigid devices lie flat, rotated 90 degrees
 from the original plan. The original 56-high layout cannot fit the felt.

 OEM reference values, NOT live web-verified in this session:
 Console + Joy-Cons: 242 x 102 x 13.9; maximum stick/trigger thickness 28.4.
 OLED dock laid flat: 175 x 104 x 50.7. Joy-Con flat: 102 x 35.9 x 28.4.
 https://www.nintendo.com/us/gaming-systems/switch/oled-model/tech-specs/
 https://www.nintendo.com/jp/hardware/detail/switch-oled/index.html
 Felt allowance: +3 XY, +2 pocket depth. No extra printer tolerance added.

 Origin is the lower-left of the exact outer/nominal layout envelope.
 Walls occupy its interior; the clear interior therefore starts at [2,2].
 Z=0 is the underside of the feet. Feet: 0..4.75. Deck: 4.75..9.5.
 Floating floors are 2 thick, with hollow cavities above the solid deck.
 Closed cavities require validated bridging or a soluble-support process.
 Case height and real-device fit still require physical verification.
*/

$fn = 48;                  // Multiple of 4 preserves exact XY extrema.
pitch = 42;
outer_w = 7*pitch;          // 294.
outer_d = 6*pitch;          // 252.
top_z = 10*7;               // 70: includes feet and the separate deck.
wall = 2;
floor_t = 2;
outer_r = 3.75;
foot_h = 4.75;
deck_t = 4.75;
deck_top = foot_h+deck_t;
eps = 0.02;                // Robust wall/floor overlaps; not fit clearance.

// OEM dimensions in the unrotated, flat orientation: [X,Y,pocket depth].
console_oem = [242,102,13.9];
dock_oem = [175,104,50.7];
joy_oem = [102,35.9,28.4];
console_max_oem = 28.4;
function lined(v) = [v[0]+3,v[1]+3,v[2]+2];
function turn_xy(v) = [v[1],v[0],v[2]];
console_need = turn_xy(lined(console_oem)); // 105 x 245 x 15.9.
dock_need = turn_xy(lined(dock_oem));       // 107 x 178 x 52.7.
joy_need = turn_xy(lined(joy_oem));         // 38.9 x 105 x 30.4.
trigger_depth = console_max_oem+2;         // 30.4.

// Revised divider CENTERLINES; console gets 0.2 extra width so its rectangular
// felt envelope clears the shell's rounded inside corners when centered.
console_div = 108.2;
dock_div = 217.2;
column_div = 258.2;
dock_end = 181;
joy_mid = 108;
joy_end = 215;
bin_div = 150.2;
bin_end = 223;

// Clear rectangles [xmin,xmax,ymin,ymax]. Long device axes now follow Y.
console_b = [2,107.2,2,250];       // 105.2 x 248.
dock_b = [109.2,216.2,2,180];     // 107 x 178.
left_b = [218.2,257.2,2,107];     // 39 x 105.
right_b = [218.2,257.2,109,214];  // 39 x 105.
empty_b = [109.2,149.2,182,222];  // 40 x 40.
hdmi_b = [259.2,292,2,250];      // 32.8 x 248; uninterrupted.
// The AC/cable pocket is ONE connected region, represented by three panels.
ac_main = [151.2,216.2,182,250];  // 65 x 68 rectangular core.
ac_left = [109.2,151.2,224,250];
ac_right = [216.2,257.2,216,250];
function bw(b) = b[1]-b[0];
function bd(b) = b[3]-b[2];

// Floor TOPS, measured down from the common rim, include the felt allowance.
dock_z = top_z-dock_need[2];     // 17.3; underside 15.3, above deck 9.5.
joy_z = top_z-joy_need[2];       // 39.6.
tablet_z = top_z-console_need[2];// 54.1.
trigger_z = top_z-trigger_depth;// 39.6.
trigger_band = 42;              // Conservative, adjustable end clearance.
step_front = console_b[2]+trigger_band;
step_back = console_b[3]-trigger_band;

// A hull of four cylinders makes a rounded slab with exact outside size.
module rounded_slab(w,d,r,h) {
    hull()
        for (x=[r,w-r], y=[r,d-r])
            translate([x,y,0]) cylinder(r=r,h=h);
}

// Standard male-foot profile: 0.8 bevel + 1.8 vertical + 2.15 bevel.
// Corner centers remain +/-17. Width/radius pairs are:
// 35.6/0.8 at Z0; 37.2/1.6 at Z0.8 and 2.6; 41.5/3.75 at Z4.75.
module foot_segment(z,h,r1,r2) {
    hull()
        for (x=[-17,17], y=[-17,17])
            translate([x,y,z]) cylinder(h=h,r1=r1,r2=r2);
}
module grid_foot() {
    foot_segment(0,0.8,0.8,1.6);
    foot_segment(0.8,1.8,1.6,1.6);
    foot_segment(2.6,2.15,1.6,3.75);
}
module feet_and_deck() {
    for (ix=[0:6], iy=[0:5])
        translate([(ix+0.5)*pitch,(iy+0.5)*pitch,0]) grid_foot();
    translate([0,0,foot_h])
        rounded_slab(outer_w,outer_d,outer_r,deck_t);
}

// Only the perimeter is hollowed: this is not a full solid pocketed block.
module perimeter() {
    difference() {
        translate([0,0,deck_top-eps])
            rounded_slab(outer_w,outer_d,outer_r,top_z-deck_top+eps);
        translate([wall,wall,deck_top-2*eps])
            rounded_slab(outer_w-2*wall,outer_d-2*wall,
                         outer_r-wall,top_z-deck_top+3*eps);
    }
}
module x_wall(x,y0,y1) {
    translate([x-wall/2,y0,deck_top-eps])
        cube([wall,y1-y0,top_z-deck_top+eps]);
}
module y_wall(y,x0,x1) {
    translate([x0,y-wall/2,deck_top-eps])
        cube([x1-x0,wall,top_z-deck_top+eps]);
}
module partitions() {
    x_wall(console_div,wall,outer_d-wall);
    x_wall(column_div,wall,outer_d-wall);
    x_wall(dock_div,wall,joy_end);
    y_wall(dock_end,console_div,dock_div);
    y_wall(joy_mid,dock_div,column_div);
    y_wall(joy_end,dock_div,column_div);
    x_wall(bin_div,dock_end,bin_end);
    y_wall(bin_end,console_div,bin_div);
}

// Horizontal cylinders centered on the rim cut semicircular finger scoops.
// Axis X cuts an X divider; axis Y cuts a Y divider. Cutters cross one wall.
module scoop_x(x,y,d) {
    translate([x,y,top_z]) rotate([0,90,0])
        cylinder(d=d,h=wall+4*eps,center=true);
}
module scoop_y(x,y,d) {
    translate([x,y,top_z]) rotate([90,0,0])
        cylinder(d=d,h=wall+4*eps,center=true);
}
module walls_with_scoops() {
    difference() {
        union() { perimeter(); partitions(); }
        // Center over the AC core so the notch does not enter the empty bin.
        scoop_y((ac_main[0]+dock_b[1])/2,dock_end,30);
        scoop_x(dock_div,(left_b[2]+left_b[3])/2,25);
        scoop_x(dock_div,(right_b[2]+right_b[3])/2,25);
        // Console rotated 90 degrees: original front/back scoops rotate too.
        scoop_x(wall/2,outer_d/2,25);
        scoop_x(console_div,outer_d/2,25);
    }
}

// No support blocks below raised floors: each slab anchors into nearby walls.
// Deep accessory floor cubes coincide with the top 2 mm of the solid deck.
module panel(b,z_top) {
    translate([b[0]-eps,b[2]-eps,z_top-floor_t])
        cube([bw(b)+2*eps,bd(b)+2*eps,floor_t]);
}
// Thin risers close only the two vertical faces of the stepped console floor.
module step_riser(y) {
    translate([console_b[0]-eps,y-wall/2,trigger_z-floor_t])
        cube([bw(console_b)+2*eps,wall,tablet_z-trigger_z+floor_t]);
}
module floors() {
    panel(dock_b,dock_z);
    panel(left_b,joy_z);
    panel(right_b,joy_z);
    panel(empty_b,deck_top);
    panel(hdmi_b,deck_top);
    panel(ac_main,deck_top);
    panel(ac_left,deck_top);
    panel(ac_right,deck_top);
    panel([console_b[0],console_b[1],console_b[2],step_front],trigger_z);
    panel([console_b[0],console_b[1],step_front,step_back],tablet_z);
    panel([console_b[0],console_b[1],step_back,console_b[3]],trigger_z);
    step_riser(step_front);
    step_riser(step_back);
}

// These assertions verify rectangular envelopes, not actual scanned contours.
module fit_report(label,b,need,z) {
    available = [bw(b),bd(b),top_z-z];
    echo(str(label,": clear ",available,"; required ",need));
    assert(available[0]+0.001>=need[0] && available[1]+0.001>=need[1]
           && available[2]+0.001>=need[2],str(label," clearance failure"));
}
fit_report("Console tablet",console_b,console_need,tablet_z);
fit_report("Flat OLED dock",dock_b,dock_need,dock_z);
fit_report("L Joy-Con",left_b,joy_need,joy_z);
fit_report("R Joy-Con",right_b,joy_need,joy_z);
assert(trigger_band>joy_need[0]+wall/2); // Riser clears felt-lined end envelope.
assert(dock_z-floor_t>deck_top);        // Dock floor has a genuine hollow gap.
assert(joy_z-floor_t>deck_top);
assert(trigger_z-floor_t>deck_top);
assert(tablet_z>trigger_z);
union() { feet_and_deck(); walls_with_scoops(); floors(); }
