JKSwitch
========

Custom UISwitch for IOS

This project uses ARC.  

A customizable UISwitch that behaves as much like UISwitch as possible.  Customize the switch with images
for the sliding background, the border, and the button.

Usage
------

You will need these images:

- back.png (131 * 27)  your sliding background image.

- border.png (79 * 27)  your border around the switch.  It is not necessary to have a border around your switch however - just use a blank png.

- mask.png (79 * 27) a transparent PNG with black areas through which back.png will show when the switch is manipulated

- button.png (27 * 27)

JKSwitch implements 

-(void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events;

And will respond with UIControlEventValueChanged.
