//
//  ViralController.m
//  led_flash
//
//  Created by Mathias Lécuyer on 27/07/12.
//  Copyright (c) 2012 Polytechnique. All rights reserved.
//

#import "ViralController.h"

#import "VShareController.h"
#import "VShareWithContacts.h"
#import "VBuyController.h"

@implementation ViralController

@synthesize viralAppController;

- (void) displayShareControllerInController:(UIViewController*)controller {
    viralAppController = controller;
    VShareController *shareController = [[VShareController alloc] initWithNibName:@"VShareController" bundle:nil];
    shareController.viralController = self;
    [controller presentViewController:shareController animated:YES completion:nil];
}

- (void) cancelShareController {
    [viralAppController dismissViewControllerAnimated:YES completion:nil];
}

- (void) displayBuyControllerInController:(UIViewController*)controller {
    viralAppController = controller;
    VBuyController *buyController = [[VBuyController alloc] initWithNibName:@"VBuyController" bundle:nil];
    buyController.viralController = self;
    [controller presentViewController:buyController animated:YES completion:nil];
}

- (void) cancelBuyController {
    [viralAppController dismissViewControllerAnimated:YES completion:nil];
}

@end
