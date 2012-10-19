//
//  VShareController.m
//  led_flash
//
//  Created by Mathias Lécuyer on 27/07/12.
//  Copyright (c) 2012 Polytechnique. All rights reserved.
//

#import "VShareController.h"
#import <Twitter/Twitter.h>

#import "ViralController.h"
#import "VShareWithContacts.h"

@interface VShareController ()

@end

@implementation VShareController

@synthesize viralController;
@synthesize shareTableController;
@synthesize morePointsTableController;
@synthesize cancelButton;

#pragma marks - sharing actions

- (void) displayShareWithContacts {
    VShareWithContacts *shareWithContacts = [[VShareWithContacts alloc] initWithNibName:@"VShareWithContacts" bundle:nil];
    shareWithContacts.shareController = self;
    [self presentViewController:shareWithContacts animated:YES completion:nil];
}

- (void) displayShareOnFacebook {
    
}

- (void) displayShareOnTwitter {
    // Set up the built-in twitter composition view controller.
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    // Set the initial tweet text. See the framework for additional properties that can be set.
    [tweetViewController setInitialText:@"Hello. This is a tweet."];
    
    // Create the completion handler block.
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {        
        // Dismiss the tweet composition view controller.
        [self dismissViewControllerAnimated:YES completion:nil];
        //[self dismissModalViewControllerAnimated:YES];
    }];
    
    // Present the tweet composition view controller modally.
    [self presentViewController:tweetViewController animated:YES completion:nil];
    //[self presentModalViewController:tweetViewController animated:YES];
}

#pragma marks - controller life cycle

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
