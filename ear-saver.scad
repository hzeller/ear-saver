// Result of some quick hackery.
// "I didn’t have time to write short code, so I wrote a long one."

$fs=1.2;
e=0.01;

twig_width=6;
center_offset=6;
bobble_diameter_extra=0;
bobble_radius=(twig_width+bobble_diameter_extra)/2;
inner_radius=0.6;
inner_hook=0.5;
arm_long=center_offset+2*bobble_radius+inner_radius;

module hook_punch(width=20) {
     // Inside cavity
     translate([inner_radius, center_offset+inner_hook, -e]) rotate([0, 0, 5]) cylinder(r=inner_radius+inner_hook, h=2, $fs=0.5);

     hull() {
	  translate([inner_radius, center_offset-inner_radius, -e]) cube([e, (inner_radius+inner_hook)*2, 2]);
	  translate([twig_width, center_offset-inner_radius, -e]) cube([e, inner_radius*2, 2]);
     }
}

module hook(width=20) {
     hull() {  // center-part
	  translate([twig_width, 0, 0]) cube([e, center_offset-inner_radius, 1]);
	  translate([width, 0, 0]) cube([e, center_offset, 1]);
     }

     intersection() {  // large rounded end-piece
	  translate([-50, 0, 0]) cube([50, 50, 1]);
	  rr=1.2*arm_long;
	  dd=arm_long;
	  circle_translate=sqrt(rr*rr - dd*dd);
	  // Rotation for low-resolution adaption.
	  translate([circle_translate, 0, 0])
	       rotate([0, 0, 3]) cylinder(r=rr, h=1);
     }

     // Connect center with outside
     cube([twig_width, arm_long, 1]);

     // Extended bobble outside.
     translate([twig_width, center_offset+inner_radius+bobble_radius, 0]) rotate([0, 0, 20]) cylinder(r=bobble_radius, h=1);
}

module hook_group(d=14, c=3) {
     difference() {
	  translate([0, -e, 0]) for (i = [0:1:c-e]) {
	       translate([i*d, 0, 0]) hook(width=d);
	  }
	  translate([0, -e, 0]) for (i = [0:1:c-e]) {
	       translate([i*d, 0, 0]) hook_punch(width=d);
	  }
     }
}

module double_hooks() {
     projection(cut=true) {
	  hook_group();
	  scale([1, -1, 1]) hook_group();
     }
}


module sector(radius, angles, fn = 180) {
     r = radius / cos(180 / fn);
     step = -360 / fn;

     points = concat([[0, 0]],
		     [for(a = [angles[0] : step : angles[1] - 360])
			       [r * cos(a), r * sin(a)]
			  ],
		     [[r * cos(angles[1]), r * sin(angles[1])]]
	  );

     difference() {
	  circle(radius, $fn = fn);
	  polygon(points);
     }
}

module arc(radius, angles, width = 1, fn = 720) {
     difference() {
	  sector(radius + width, angles, fn);
	  sector(radius, angles, fn);
     }
}

module half() {
     angle=7;
     rotate([0, 0, angle]) translate([-84, -2, 0]) double_hooks();

     r2=360 * 40 / (2 * PI * angle);

     translate([0, -r2-10.5, 0]) rotate([0, 0, 90]) arc(radius=r2, angles=[0, 7.15], width=12);
}


translate([e, 0, 0]) half();
scale([-1, 1, 1]) translate([e, 0, 0]) half();
