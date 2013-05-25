//
//  PrincipalView.m
//
//  Created by Mathias Lécuyer on 06/08/10.
//  Copyright 2010 Pionid. All rights reserved.
//

#import "PrincipalView.h"
#import "myviewcontroller.h"

#define HORIZ_SWIPE_DRAG_MIN 25

#define TAG_OPTION_PANNEL_LEFT 57
#define TAG_OPTION_PANNEL_RIGHT 58

#define OPENED_POSITION 45
#define CLOSED_POSITION 405
#define OTHER_PAN_OPENED_POSITION 765

#define ECART_DEUX_PANNEL 810




@implementation PrincipalView

@synthesize startTouchPosition;
@synthesize currentView;

@synthesize torchIsOn;
@synthesize vc;

/*- (void) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	
}*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
   UITouch *touch = [touches anyObject];
	
	if([touch view] != self){
		return;
	}
	
    startTouchPosition = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *aTouch = [touches anyObject];
	
	if([aTouch view] != self){
	return;
	}
	
    CGPoint loc = [aTouch locationInView:self];

    CGPoint prevloc = [aTouch previousLocationInView:self];
	
	[UIView beginAnimations: @"option_pannel_middle_move" context: nil];
		
	float deltaX = loc.x - prevloc.x;
			
	if (currentView == 1 && (startTouchPosition.x - loc.x) > 0) {
		deltaX = deltaX/2;
	}
	if (currentView == 1 && (startTouchPosition.x - loc.x) > 50) {
		deltaX = 0;
	}
	if (currentView == -1 && (startTouchPosition.x - loc.x) < 0) {
		deltaX = deltaX/2;
	}
	if (currentView == -1 && (startTouchPosition.x - loc.x) < -50) {
		deltaX = 0;
	}
		
	UIView *vue = [self viewWithTag:TAG_OPTION_PANNEL_LEFT];
	CGRect myFrame = vue.frame;
	myFrame.origin.x += deltaX;
	[vue setFrame:myFrame];
	
	UIView *vue2 = [self viewWithTag:TAG_OPTION_PANNEL_RIGHT];
	if (vue2) {
		CGRect myFrame2 = vue.frame;
		myFrame2.origin.x = myFrame.origin.x - ECART_DEUX_PANNEL;
		[vue2 setFrame:myFrame2];
	}

	[UIView commitAnimations];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	BOOL isGoingLeft = YES;
	BOOL isMoving = NO;
	
	UITouch *touch = [touches anyObject];
	if([touch view] != self){
		return;
	}
    CGPoint lastTouchPosition = [touch locationInView:self];
	
	if (startTouchPosition.x > lastTouchPosition.x) {
		isGoingLeft = NO;
	}
	if(fabsf(lastTouchPosition.x - startTouchPosition.x)>= HORIZ_SWIPE_DRAG_MIN){
		isMoving = YES;
	}
	
	[self endOfTouch:isMoving goingLeft:isGoingLeft];

	startTouchPosition = CGPointMake(0.0, 0.0);
}

- (void) settingsPannel {
    if (currentView == 1)
        [self endOfTouch:YES goingLeft:YES];
    else
        [self endOfTouch:YES goingLeft:NO];    
}

- (void) optionsPannel {
    if (currentView == -1)
        [self endOfTouch:YES goingLeft:NO];
    else
        [self endOfTouch:YES goingLeft:YES];
}


- (void)endOfTouch:(BOOL)isMoving goingLeft:(BOOL)goingLeft{
	BOOL isThereAViewOnTheLeft = (currentView == 0) || (currentView == 1);
	BOOL isThereAViewOnTheRight = (currentView == 0) || (currentView == -1);	
	
	[UIView beginAnimations: @"option_pannel_end_move" context: nil];
	
	UIView *vue = [self viewWithTag:TAG_OPTION_PANNEL_LEFT];
	CGRect myFrame = vue.frame;	
	
	if(isMoving && ((goingLeft && isThereAViewOnTheLeft) || (!goingLeft && isThereAViewOnTheRight))) {
		if (goingLeft) {
			self.currentView -= 1;
		}
		else {
			if (self.currentView == -1) {
				[[self viewWithTag:1337] resignFirstResponder];
			}

			self.currentView += 1;
		}
	}

	if (self.currentView == 0) {
		myFrame.origin.x = CLOSED_POSITION;
	}
	else if (self.currentView == 1) {
		myFrame.origin.x = OPENED_POSITION;
	}
	else if (self.currentView == -1) {
		myFrame.origin.x = OTHER_PAN_OPENED_POSITION;
	}
	
	[vue setFrame:myFrame];
	
	UIView *vue2 = [self viewWithTag:TAG_OPTION_PANNEL_RIGHT];
	if (vue2) {
		CGRect myFrame2 = vue2.frame;
		myFrame2.origin.x = myFrame.origin.x - ECART_DEUX_PANNEL;
		[vue2 setFrame:myFrame2];
	}
	
	[UIView setAnimationDuration:1.0f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationWillStartSelector:@selector(debutAnimation)];
	[UIView setAnimationDidStopSelector:@selector(finAnimation)];
	
	[UIView commitAnimations];
    
    vc.shakeSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"shakeToLight"];
    vc.lockSwitch.on = ![[NSUserDefaults standardUserDefaults] boolForKey:@"idleTimerDisabled"];
    vc.flashSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"flashAvailable"];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {	
	UIView *vue = [self viewWithTag:TAG_OPTION_PANNEL_LEFT];
	CGRect myFrame = vue.frame;
	
	if (self.currentView == 0) {
		myFrame.origin.x = CLOSED_POSITION;
	}
	else if (self.currentView == 1) {
		myFrame.origin.x = OPENED_POSITION;
	}
	
	[vue setFrame:myFrame];
	
	UIView *vue2 = [self viewWithTag:TAG_OPTION_PANNEL_RIGHT];
	if (vue2) {
		CGRect myFrame2 = vue2.frame;
		myFrame2.origin.x = myFrame.origin.x - ECART_DEUX_PANNEL;
		[vue2 setFrame:myFrame2];
	}
	
	startTouchPosition = CGPointMake(0.0, 0.0);
	
	if (currentView == 0) {
		self.exclusiveTouch = NO;
	}
	
	self.userInteractionEnabled = YES;
}

- (void)debutAnimation{
	self.userInteractionEnabled = NO;
}


- (void)finAnimation{
	if (currentView == 0) {
	}

	self.userInteractionEnabled = YES;
}

@end

