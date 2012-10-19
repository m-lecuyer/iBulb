//
//  VBuyController.m
//  led_flash
//
//  Created by Mathias Lécuyer on 01/08/12.
//  Copyright (c) 2012 Polytechnique. All rights reserved.
//

#import "VBuyController.h"

#import "ViralController.h"

@interface VBuyController ()

@end

@implementation VBuyController

@synthesize viralController;
@synthesize cancelButton;
@synthesize featuresTableController;

- (IBAction) cancelPushed {
    [viralController cancelShareController];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
