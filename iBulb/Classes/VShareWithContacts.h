//
//  VInviteNewFriends.h
//  NoK
//
//  Created by Mathias LECUYER on 29/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

@class VShareController;

@interface VShareWithContacts : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>{
    VShareController *shareController;
    
    NSArray *displayedContacts;
    
    NSMutableArray *selectedContacts;
    
    NSNumber *mailOrSMS;
    
    UITableView *tView;
}

@property (nonatomic, retain) VShareController *shareController;

@property (nonatomic, retain) NSArray *displayedContacts;
@property (nonatomic, retain) NSMutableArray *selectedContacts;

@property (nonatomic, retain) NSNumber *mailOrSMS;

@property (nonatomic, retain) IBOutlet UITableView *tView;

- (NSArray *) sortContactsForArray:(NSArray*)arrayOfContacts;
- (IBAction) invite;
- (IBAction) mailOrSMSSwitched :(id)sender;
- (void)displayMailComposerSheet;
- (void)displaySMSComposerSheet;

@end

@interface ContactLocal : NSObject {
    NSString *firstname;
    NSString *lastname;
    
    NSString *email;
    NSString *phone;
    
    NSInteger sectionNumber;
}

@property(nonatomic,copy) NSString *firstname;
@property(nonatomic,copy) NSString *lastname;
@property(nonatomic,copy) NSString *email;
@property(nonatomic,copy) NSString *phone;
@property NSInteger sectionNumber;

@end


