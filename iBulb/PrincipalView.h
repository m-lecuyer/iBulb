//
//  PrincipalView.h
//
//  Created by Mathias Lécuyer on 06/08/10.
//  Copyright 2010 Pionid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>


@interface PrincipalView : UIView {
	CGPoint startTouchPosition;
	int currentView;
		
	BOOL torchIsOn;
}

@property (nonatomic, assign) CGPoint startTouchPosition;
@property (nonatomic, assign) int currentView;

@property (nonatomic, assign) BOOL torchIsOn;


- (void)endOfTouch:(BOOL)isMoving goingLeft:(BOOL)goingLeft;
- (void) settingsPannel;
- (void) optionsPannel;

@end
