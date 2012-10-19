//
//  led_flashAppDelegate.h
//  led_flash
//
//  Created by Benoit Marilleau on 12/07/10.
//  Copyright Pionid 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "myviewcontroller.h"

@class MyStoreObserver;

@interface led_flashAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	myviewcontroller *monController;
    CGFloat brightness;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic ,retain) IBOutlet myviewcontroller *monController;

@end

