//
//  ViewController.m
//  JKSwitch
//
//  Created by James Kelly on 8/30/12.
//  Copyright (c) 2012 James Kelly All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
{
    JKSwitch *customSwitch;
}

- (void)viewDidLoad{
    [super viewDidLoad];

    customSwitch = [[JKSwitch alloc] initWithFrame:CGRectMake(100, 100, 0, 0)]; //width and height are ignored by the init method.
    [customSwitch addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
    [customSwitch setTag:1];
    [self.view addSubview:customSwitch];

}

-(void)switchFlipped:(id)sender{
    JKSwitch *revievedSwitch = (JKSwitch*)sender;
    if (revievedSwitch == customSwitch) {
        if(customSwitch.on)NSLog(@"Custom switch is ON");
        else NSLog(@"Custom switch is OFF");
    }
}



@end
