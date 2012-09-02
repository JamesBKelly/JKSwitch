//
//  JKSwitch.m
//  JKSwitch
//
//  Created by James Kelly on 8/30/12.
//  Copyright (c) 2012 James Kelly. All rights reserved.
//

#import "JKSwitch.h"
#import <QuartzCore/QuartzCore.h>

#define WIDTH       79.0
#define HEIGHT      27.0
#define BACK_WIDTH  131.0
#define BUTTON_DIAM 27.0
#define HORZ_PADDING 0.0    //padding between the button and the edge of the switch.
#define TAP_SENSITIVITY 25.0 //margin of error to detect if the switch was tapped or swiped.

@implementation JKSwitch
{
    UIImageView *backgroundImageView;
    UIImageView *buttonImageView;
    BOOL isOn;
    CGPoint firstTouchPoint;
    float touchDistanceFromButton;
    id returnTarget;
    SEL returnAction;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, WIDTH, HEIGHT)];
    if (self) {
        self.layer.masksToBounds = YES;
        
        //masked view
        //  ->background image
        //  ->mask
        //button image
        //border image
        //
        //The mask is placed over the view, then the background image is slid left and right inside the view.
        //If the mask is applied to the background image directly then the mask will move around with it.
        
        UIView *maskedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        [self addSubview:maskedView];
       
        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-(WIDTH - BUTTON_DIAM), 0, BACK_WIDTH, HEIGHT)];  
        [backgroundImageView setImage:[UIImage imageNamed:@"back.png"]];
        [maskedView addSubview:backgroundImageView];
        
        CALayer *mask = [CALayer layer];
        mask.contents = (id)[[UIImage imageNamed:@"mask.png"] CGImage];
        mask.frame = CGRectMake(0, 0, 79, 27);
        maskedView.layer.mask = mask;
        maskedView.layer.masksToBounds = YES;
        
        UIImageView *borderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        buttonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(HORZ_PADDING, 0, BUTTON_DIAM, BUTTON_DIAM)];
        [self addSubview:buttonImageView];
        [self addSubview:borderImageView];
        [borderImageView setImage:[UIImage imageNamed:@"border.png"]];
        [buttonImageView setImage:[UIImage imageNamed:@"button.png"]];
    }
    return self;
}

-(void)setOn:(BOOL)on animated:(BOOL)animated{
    isOn = on;
    CGRect newBackFrame;
    CGRect newButtonFrame;
    if (on) {
        newBackFrame = CGRectMake(0, 0, BACK_WIDTH, HEIGHT);
        newButtonFrame = CGRectMake(WIDTH - BUTTON_DIAM - HORZ_PADDING, 0, BUTTON_DIAM, BUTTON_DIAM);
    }
    else {
        newBackFrame = CGRectMake(-(WIDTH-BUTTON_DIAM), 0, BACK_WIDTH, HEIGHT);
        newButtonFrame = CGRectMake(HORZ_PADDING, 0, BUTTON_DIAM, BUTTON_DIAM);
    }
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.23];
        [backgroundImageView setFrame:newBackFrame];
        [buttonImageView setFrame:newButtonFrame];
        [UIView commitAnimations];
    }   
    else {
        [backgroundImageView setFrame:newBackFrame];
        [buttonImageView setFrame:newButtonFrame];
    }
    [self returnStatus];
}

-(BOOL)on{
    return isOn; 
}

-(void)toggleAnimated:(BOOL)animated{
    if (isOn){
        [self setOn:NO animated:animated];
    }
    else {
        [self setOn:YES animated:animated];
    }
}

-(void)returnStatus{
    //The following line may cause a warning - "performSelector may cause a leak because its selector is unknown".
    //This is because ARC's behaviour is tied in with objective-c naming conventions of methods (convenience constructors that return autoreleased objects
    //vs. init methods that return retained objects). ARC doesn't know what _action is, so it doesn't know how to deal with it.  This is a known issue.
    //              http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [returnTarget performSelector:returnAction withObject:self];
    #pragma clang diagnostic pop
}

#pragma mark - Touch event methods.
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    firstTouchPoint = [touch locationInView:self];
    touchDistanceFromButton = firstTouchPoint.x - buttonImageView.frame.origin.x;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject]; 
    CGPoint lastTouchPoint = [touch locationInView:self];   
    
    if (firstTouchPoint.x < lastTouchPoint.x) {
        //Move the button right
        [buttonImageView setFrame:CGRectMake(lastTouchPoint.x - touchDistanceFromButton, 0, BUTTON_DIAM, BUTTON_DIAM)];
    } 
    else{
        //Move the button left
        [buttonImageView setFrame:CGRectMake(lastTouchPoint.x - touchDistanceFromButton, 0, BUTTON_DIAM, BUTTON_DIAM)];
    }
    
    //Swipe fast enough and the button will be drawn outside the bounds.
    //If so, relocate it to the left/right of the switch.
    if (buttonImageView.frame.origin.x > (WIDTH - BUTTON_DIAM - HORZ_PADDING)) {
        [buttonImageView setFrame:CGRectMake(WIDTH - BUTTON_DIAM - HORZ_PADDING, 0, BUTTON_DIAM, BUTTON_DIAM)];
    }
    else if(buttonImageView.frame.origin.x < HORZ_PADDING){
        [buttonImageView setFrame:CGRectMake(HORZ_PADDING,0, BUTTON_DIAM,BUTTON_DIAM)];
    }
    
    [backgroundImageView setFrame:CGRectMake(buttonImageView.frame.origin.x - WIDTH + BUTTON_DIAM, 0, BACK_WIDTH, HEIGHT)];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint endTouchPoint = [touch locationInView:self];
    if(firstTouchPoint.x > (endTouchPoint.x - TAP_SENSITIVITY) &&
       firstTouchPoint.x < (endTouchPoint.x + TAP_SENSITIVITY) &&
       firstTouchPoint.y > (endTouchPoint.y - TAP_SENSITIVITY) &&
       firstTouchPoint.y < (endTouchPoint.y + TAP_SENSITIVITY)){
        //TAPPED
        [self toggleAnimated:YES];
    }
    else {
        //SWIPED 
        CGRect newButtonFrame;
        float distanceToEnd;
        BOOL needsMove = NO;
        
        //If the button is languishing somewhere in the middle of the switch
        //move it to either on or off.
        
        //First, edge cases
        if (buttonImageView.frame.origin.x == HORZ_PADDING) {
            distanceToEnd = 0;
            isOn = NO;
        }
        else if(buttonImageView.frame.origin.x == (WIDTH - BUTTON_DIAM - HORZ_PADDING)){
            distanceToEnd = 0;
            isOn = YES;
        }
        //Then, right or left
        if(buttonImageView.frame.origin.x < ((WIDTH / 2) - (BUTTON_DIAM / 2))){            
            //move left
            newButtonFrame = CGRectMake(HORZ_PADDING, 0, BUTTON_DIAM, BUTTON_DIAM);
            distanceToEnd = buttonImageView.frame.origin.x;
            isOn = NO;
            needsMove = YES;
        }
        else if(buttonImageView.frame.origin.x < (WIDTH - BUTTON_DIAM - HORZ_PADDING)){
            //move right
            newButtonFrame = CGRectMake(WIDTH - BUTTON_DIAM - HORZ_PADDING, 0, BUTTON_DIAM, BUTTON_DIAM);
            distanceToEnd = WIDTH - buttonImageView.frame.origin.x - BUTTON_DIAM;
            isOn = YES;
            needsMove = YES;
        }
        
        if (needsMove){
            //animate more quickly if the button is towards the end of the switch.
            float animTime = distanceToEnd / 140;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDelay:0];
            [UIView setAnimationDuration:animTime];
            [buttonImageView setFrame:newButtonFrame];
            [backgroundImageView setFrame:CGRectMake(buttonImageView.frame.origin.x - WIDTH + BUTTON_DIAM, 0, BACK_WIDTH, HEIGHT)];
            [UIView commitAnimations];
        }
        [self returnStatus];
    }
}

#pragma mark - Event handling.

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events {
    if (events & UIControlEventValueChanged) {
        returnTarget = target;
        returnAction = action;
    }
}

@end
