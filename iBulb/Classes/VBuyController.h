//
//  VBuyController.h
//  led_flash
//
//  Created by Mathias Lécuyer on 01/08/12.
//  Copyright (c) 2012 Polytechnique. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViralController;

@interface VBuyController : UIViewController {

    ViralController *viralController;
        
    UIBarButtonItem *cancelButton;
    UITableViewController *featuresTableController;
}


@property (nonatomic, retain) IBOutlet ViralController *viralController;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) IBOutlet UITableViewController *featuresTableController;

- (IBAction) cancelPushed;

@end