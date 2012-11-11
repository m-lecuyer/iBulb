//
//  led_flashAppDelegate.m
//  led_flash
//
//  Created by Benoit Marilleau on 12/07/10.
//  Copyright Pionid 2010. All rights reserved.
//

#import "led_flashAppDelegate.h"
#import "MyStoreObserver.h"
#import "Flurry.h"

@implementation led_flashAppDelegate

@synthesize window;
@synthesize monController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    [Flurry startSession:@"66RNHG8P7C2N7JSHPWP5"];
    
    brightness = [UIScreen mainScreen].brightness;

    // Override point for customization after application launch.
	MyStoreObserver *observer = [[MyStoreObserver alloc] init];
	observer.monController = monController;
	[[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
	
    [window makeKeyAndVisible];
	
	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [UIScreen mainScreen].brightness = brightness;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [UIScreen mainScreen].brightness = brightness;
	[[NSUserDefaults standardUserDefaults] synchronize];

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	[monController devientActive];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */

    [UIScreen mainScreen].brightness = brightness;
	[[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
