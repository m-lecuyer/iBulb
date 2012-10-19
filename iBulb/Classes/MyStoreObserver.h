//
//  MyStoreObserver.h
//  led_flash
//
//  Created by Mathias Lécuyer on 13/11/10.
//  Copyright 2010 Pionid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@class myviewcontroller;

@interface MyStoreObserver : NSObject <SKPaymentTransactionObserver>{

	myviewcontroller *monController;
	
}

@property (nonatomic, retain) myviewcontroller *monController;

-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
-(void) completeTransaction:(SKPaymentTransaction *)transaction;
-(void) restoreTransaction:(SKPaymentTransaction *)transaction;
-(void) failedTransaction:(SKPaymentTransaction *)transaction;

-(void) recordTransaction:(SKPaymentTransaction *) transaction;
-(void) provideContent:(NSString *) productIdentifier;

@end
