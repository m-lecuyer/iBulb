//
//  MyStoreObserver.m
//  led_flash
//
//  Created by Mathias Lécuyer on 13/11/10.
//  Copyright 2010 Pionid. All rights reserved.
//


#import "MyStoreObserver.h"
#import "led_flashAppDelegate.h"
#import "myviewcontroller.h"

@implementation MyStoreObserver

@synthesize monController;


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction{
	// Your application should implement these two methods.
    [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
	// Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction{
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction{
	[monController failedTransaction];
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"PURCHASE_ERROR_TITLE", nil) 
                                                  message:NSLocalizedString(@"PURCHASE_ERROR_MESSAGE", nil)
                                                  delegate:monController 
                                                  cancelButtonTitle:NSLocalizedString(@"PURCHASE_ERROR_CANCEL", nil)
                                                  otherButtonTitles:NSLocalizedString(@"PURCHASE_ERROR_TITLE", nil), nil];
		[alert show];
		[alert release];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void) recordTransaction:(SKPaymentTransaction *) transaction{
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"adFreeVersionPruchased"];
	monController.plusOneToDisplayBuyButton = 0;
}

-(void) provideContent:(NSString *) productIdentifier{
	[monController.adView removeFromSuperview];
	[monController.adView release];
	[monController.adMobAd removeFromSuperview];
	[monController.adMobAd release];
}


@end
