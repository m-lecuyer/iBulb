//
//  VSShareTable.m
//  led_flash
//
//  Created by Mathias Lécuyer on 29/07/12.
//  Copyright (c) 2012 Polytechnique. All rights reserved.
//

#import "VSShareTable.h"

@interface VSShareTable ()

@end

@implementation VSShareTable

@synthesize shareController;
@synthesize sharingVectors;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.layer.cornerRadius = 14;
    
    NSDictionary *contactsShare = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"Contacts", @"Email or text your friends.", @"contactIcon.png", @"displayShareWithContacts", shareController, nil] forKeys:[NSArray arrayWithObjects: @"title", @"subtitle", @"picture", @"selector", @"target", nil]];
    NSDictionary *facebookShare = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"Facebook", @"Share this app on Facebook.",@"facebookIcon.png", @"displayShareOnFacebook", shareController, nil] forKeys:[NSArray arrayWithObjects: @"title", @"subtitle", @"picture", @"selector", @"target", nil]];
    NSDictionary *twitterShare = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: @"Twitter", @"Tweet about this app.",@"twitterIcon.png", @"displayShareOnTwitter", shareController, nil] forKeys:[NSArray arrayWithObjects: @"title", @"subtitle", @"picture", @"selector", @"target", nil]];
    
    sharingVectors = [[NSMutableArray arrayWithObjects:contactsShare, facebookShare, twitterShare, nil] retain];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [sharingVectors count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"VSCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *currentShareCell = [sharingVectors objectAtIndex:indexPath.row];
    cell.textLabel.text = [currentShareCell objectForKey:@"title"];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.text = [currentShareCell objectForKey:@"subtitle"];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.imageView.image = [UIImage imageNamed:[currentShareCell objectForKey:@"picture"]];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[[sharingVectors objectAtIndex:indexPath.row] objectForKey:@"target"] performSelector:NSSelectorFromString([[sharingVectors objectAtIndex:indexPath.row] objectForKey:@"selector"])];
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
