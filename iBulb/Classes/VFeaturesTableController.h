//
//  VFeaturesTableController.h
//  led_flash
//
//  Created by Mathias Lécuyer on 01/08/12.
//  Copyright (c) 2012 Polytechnique. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class VBuyController;

@interface VFeaturesTableController : UITableViewController {
    VBuyController *buyController;
    
    NSMutableArray *toBuyVectors;
}

@property (nonatomic, retain) IBOutlet VBuyController *buyController;

@property (nonatomic, retain) NSMutableArray *toBuyVectors;

@end
