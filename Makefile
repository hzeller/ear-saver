
ear-saver.dxf:

%.dxf : %.scad
	openscad -o $@ $^
