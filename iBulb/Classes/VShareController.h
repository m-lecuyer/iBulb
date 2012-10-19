//
//  VShareController.h
//  led_flash
//
//  Created by Mathias Lécuyer on 27/07/12.
//  Copyright (c) 2012 Polytechnique. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViralController;
@class VSShareTable;
@class VSMorePointsTable;

@interface VShareController : UIViewController {
    
    ViralController *viralController;
    
    VSShareTable *shareTableController;
    VSMorePointsTable *morePointsTableController;
    
    UIBarButtonItem *cancelButton;
}

@property (nonatomic, retain) IBOutlet ViralController *viralController;

@property (nonatomic, retain) IBOutlet VSShareTable *shareTableController;
@property (nonatomic, retain) IBOutlet VSMorePointsTable *morePointsTableController;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;


- (void) displayShareWithContacts;
- (void) displayShareOnFacebook;
- (void) displayShareOnTwitter;

- (IBAction) cancelPushed;

@end
