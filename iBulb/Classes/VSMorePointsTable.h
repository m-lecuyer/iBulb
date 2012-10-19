//
//  VSMorePointsTable.h
//  led_flash
//
//  Created by Mathias Lécuyer on 29/07/12.
//  Copyright (c) 2012 Polytechnique. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class VShareController;

@interface VSMorePointsTable : UITableViewController {
    VShareController *shareController;

    NSMutableArray *morePointsVectors;
}

@property (nonatomic, retain) IBOutlet VShareController *shareController;

@property (nonatomic, retain) NSMutableArray *morePointsVectors;

@end
