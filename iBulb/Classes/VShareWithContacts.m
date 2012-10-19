//
//  PMInviteNewFriends.m
//  NoK
//
//  Created by Mathias LECUYER on 29/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VShareWithContacts.h"

#import "VShareController.h"
#import "ABContactsHelper.h"
#import "ABContact.h"
#import "ABGroup.h"

@implementation ContactLocal
@synthesize firstname;
@synthesize lastname;
@synthesize email;
@synthesize phone;
@synthesize sectionNumber;
@end

@implementation VShareWithContacts
@synthesize shareController;
@synthesize displayedContacts;
@synthesize selectedContacts;
@synthesize tView;
@synthesize mailOrSMS;

static NSArray *contacts;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    contacts = [[ABContactsHelper contacts] retain];
    mailOrSMS = [NSNumber numberWithInt:0];
    displayedContacts = [self sortContactsForArray:contacts];
    selectedContacts = [[NSMutableArray alloc] initWithCapacity:0];
    [tView reloadData];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/* 
 * --------------------------------------------------------------------------------------------------------------
 *  TABLE VIEW DELEGATE AND DATASOURCE
 * --------------------------------------------------------------------------------------------------------------
 */

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[displayedContacts objectAtIndex:section] count] > 0) {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [displayedContacts count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[displayedContacts objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ContactLocal *contact = [[displayedContacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *s = @"";
    if (contact.firstname) s = [s stringByAppendingString:[NSString stringWithFormat:@"%@ ", contact.firstname]];
    if (contact.lastname) s = [s stringByAppendingString:contact.lastname];
    cell.textLabel.text = s;
    
    if([mailOrSMS intValue] == 0){
        cell.detailTextLabel.text = contact.email;
    }
    else if([mailOrSMS intValue] == 1){
        cell.detailTextLabel.text = contact.phone;
    }
    
    if ([selectedContacts containsObject:contact]) {
        cell.imageView.image = [UIImage imageNamed:@"tickedbox.png"];
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"untickedbox.png"];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactLocal *c=[[displayedContacts objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([selectedContacts containsObject:c]) {
        [selectedContacts removeObject:c];
    }
    else {
        [selectedContacts addObject:c];
    }
    [tableView reloadData];
}

/* 
 * --------------------------------------------------------------------------------------------------------------
 *  END TABLE VIEW DELEGATE AND DATASOURCE
 * --------------------------------------------------------------------------------------------------------------
 */


- (IBAction) mailOrSMSSwitched :(id)sender {
    int i = ((UISegmentedControl*)sender).selectedSegmentIndex;
    if (i != [mailOrSMS intValue]) {
        mailOrSMS = [NSNumber numberWithInt:i];
        
        [contacts release]; contacts = nil;
        [displayedContacts release]; displayedContacts = nil;
        [selectedContacts release]; selectedContacts = nil;

        contacts = [[ABContactsHelper contacts] retain];
        displayedContacts = [self sortContactsForArray:contacts];
        selectedContacts = [[[NSMutableArray alloc] initWithCapacity:0] retain];
        [tView reloadData];
    }
}

- (NSArray *) sortContactsForArray:(NSArray*)arrayOfContacts {
    NSMutableArray *sortedContacts = [[[NSMutableArray alloc] initWithCapacity:0] retain];
    
    NSMutableArray *sortedContactsTmp = [[[NSMutableArray alloc] initWithCapacity:0] retain];
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];

    for (ABContact *contact in arrayOfContacts)
	{
        if([mailOrSMS intValue] == 0 && [contact.emailArray count]>0){
            ContactLocal *cont = [[[ContactLocal alloc] init] retain];
            cont.firstname = contact.firstname;
            cont.lastname = contact.lastname;
            cont.email = [contact.emailArray objectAtIndex:0];
            [sortedContactsTmp addObject:cont];
            [cont release];
        }
        if([mailOrSMS intValue] == 1 && [contact.phoneArray count]>0){
            ContactLocal *cont = [[[ContactLocal alloc] init] retain];
            cont.firstname = contact.firstname;
            cont.lastname = contact.lastname;
            cont.phone = [contact.phoneArray objectAtIndex:0];
            [sortedContactsTmp addObject:cont];
            [cont release];
        }
    }
    
    for (ContactLocal *c in sortedContactsTmp) {
        NSInteger sect = [theCollation sectionForObject:c collationStringSelector:@selector(firstname)];
        c.sectionNumber = sect;
    }

    NSInteger highSection = [[theCollation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    for (int i=0; i<=highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
    }

    for (ContactLocal *c in sortedContactsTmp) {
        [(NSMutableArray *)[sectionArrays objectAtIndex:c.sectionNumber] addObject:c];
    }

    for (NSMutableArray *sectionArray in sectionArrays) {
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray
                                            collationStringSelector:@selector(firstname)];
        [sortedContacts addObject:sortedSection];
    }
            
    return sortedContacts;
}

/* 
 * --------------------------------------------------------------------------------------------------------------
 *  INVITE FRIENDS ACTION
 * --------------------------------------------------------------------------------------------------------------
 */

- (IBAction) invite {
    if ([mailOrSMS intValue] == 0) {
        Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
        if (mailClass != nil)
        {
            if ([mailClass canSendMail]) [self displayMailComposerSheet];
        }
    }
    else if ([mailOrSMS intValue] == 1) {
        Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
        if (smsClass != nil)
        {
            if ([smsClass canSendText]) [self displaySMSComposerSheet];
        }
    }
}

- (void)displaySMSComposerSheet {
    NSMutableArray *recipients = [[NSMutableArray alloc] initWithCapacity:0];
    for (ContactLocal *contact in selectedContacts) {
        [recipients addObject:[contact phone]];
    }
    
    MFMessageComposeViewController *feedbackSMS = [[MFMessageComposeViewController alloc] init];
    feedbackSMS.messageComposeDelegate = self;
    feedbackSMS.navigationBar.tintColor = [UIColor colorWithRed:153.0/255 green:40.0/255 blue:171.0/255 alpha:1.0];
    
    [feedbackSMS setTitle:@"Mojo Invite"];
    [feedbackSMS setRecipients:recipients];
    [feedbackSMS setBody:[NSString stringWithFormat:@"Hey! I just invited you in a conversation on MojoGroups! Join the group and start chatting: http://www.mojogroups.com/get?code=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"inviteCode"]]];
    
    [self presentModalViewController:feedbackSMS animated:YES];
    [feedbackSMS release];
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
- (void)displayMailComposerSheet 
{
    NSMutableArray *recipients = [[NSMutableArray alloc] initWithCapacity:0];
    for (ContactLocal *contact in selectedContacts) {
        [recipients addObject:[contact email]];
    }
    
    MFMailComposeViewController *feedbackMail = [[MFMailComposeViewController alloc] init];
    feedbackMail.mailComposeDelegate = self;
    feedbackMail.navigationBar.tintColor = [UIColor colorWithRed:153.0/255 green:40.0/255 blue:171.0/255 alpha:1.0];
    
    [feedbackMail setTitle:@"Mojo Invite"];
    [feedbackMail setSubject:[NSString stringWithFormat:@"Join me on Mojo!"]];
    [feedbackMail setToRecipients:recipients];
    [feedbackMail setMessageBody:[NSString stringWithFormat:@"Hey! \n\nI just invited you in a conversation on MojoGroups! \n\nIt's free to download and to use. Join the group and start chatting: http://www.mojogroups.com/get?code=%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"inviteCode"]] isHTML:NO];
    
    [self presentModalViewController:feedbackMail animated:YES];
    [feedbackMail release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
    [self dismissModalViewControllerAnimated:YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissModalViewControllerAnimated:YES];
}

/* 
 * --------------------------------------------------------------------------------------------------------------
 *  END INVITE FRIENDS ACTION
 * --------------------------------------------------------------------------------------------------------------
 */

- (IBAction) cancel {
    [shareController dismissViewControllerAnimated:YES completion:nil];
}

@end
