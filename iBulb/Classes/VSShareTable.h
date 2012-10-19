//
//  VSShareTable.h
//  led_flash
//
//  Created by Mathias Lécuyer on 29/07/12.
//  Copyright (c) 2012 Polytechnique. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class VShareController;

@interface VSShareTable : UITableViewController {
    VShareController *shareController;
    
    NSMutableArray *sharingVectors;
}

@property (nonatomic, retain) IBOutlet VShareController *shareController;

@property (nonatomic, retain) NSMutableArray *sharingVectors;

@end
