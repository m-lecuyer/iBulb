//
//  ViralController.h
//  led_flash
//
//  Created by Mathias Lécuyer on 27/07/12.
//  Copyright (c) 2012 Polytechnique. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViralController : NSObject {
    UIViewController *viralAppController;
}

@property (nonatomic, retain) UIViewController *viralAppController;

- (void) displayShareControllerInController:(UIViewController*)controller;
- (IBAction) cancelShareController;

- (void) displayBuyControllerInController:(UIViewController*)controller;
- (IBAction) cancelBuyController;

@end
