//
//  myviewcontroller.h
//  led_flash
//
//  Created by Benoit Marilleau on 12/07/10.
//  Copyright 2010 Pionid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <iAd/iAd.h>
#import <QuartzCore/QuartzCore.h>
#import <StoreKit/StoreKit.h>

#import "GADBannerView.h"
#import "ViralController.h"

@class PrincipalView;
@class LanguetteTouchImageView;


@interface myviewcontroller : UIViewController <ADBannerViewDelegate, SKProductsRequestDelegate, UIAlertViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    
    ViralController *viralController;
	
	UIButton *bouton;
	UISlider *mySlider;
	UIImageView *myImageView;
	UIView *rightPannel;
    UIView *leftPannel;
    UISegmentedControl *modeControll;
    
    
	
    UIView *torchModeOptionsView;
    UIView *morseTextView;
    UIView *freqSliderView;
    UISlider *freqSlider;
    
    float brightness;
    float onBrightness;
    UISlider *brihgtnessSlider;
		
	AVCaptureDevice *videoCaptureDevice;
	AVCaptureDeviceInput *videoInput;
	
	ADBannerView *adView;
	BOOL adMobIsVisible;
	
	BOOL bannerIsVisible, torchIsOn, flashAvailable, isTheirAFlashOnTheDevice;
	
	BOOL morseOn;
	
	NSDictionary *morseCode;
	
	float morseTimeOfADot;
    float stroboFreq;
//--------------------------------------------
//tests v1.1	
		
	
	GADBannerView *adMobAd;

	
//--------------------------------------------
	
	NSTimer *timerStrombo;
	
	UILabel *adFreePurchaseLabel;
	UIActivityIndicatorView *adFreePurchaseWaiting;
	UIButton *buyButton;
	int plusOneToDisplayBuyButton;
	
	/*
	 *
	 *
	 * morse
	 *
	 */
	
	UITextField *textToPlayInMorse;
	
	/*
	 *
	 *
	 * fin morse
	 *
	 */
	
}

@property (nonatomic, retain) IBOutlet ViralController *viralController;

@property (nonatomic, retain) IBOutlet UILabel *adFreePurchaseLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *adFreePurchaseWaiting;
@property (nonatomic, retain) IBOutlet UIButton *buyButton;
@property (nonatomic, retain) IBOutlet UIView *rightPannel;
@property (nonatomic, retain) IBOutlet UIView *leftPannel;
@property (nonatomic, retain) IBOutlet UISegmentedControl *modeControll;

@property (nonatomic, retain) IBOutlet UIView *torchModeOptionsView;
@property (nonatomic, retain) IBOutlet UIView *morseTextView;
@property (nonatomic, retain) IBOutlet UIView *freqSliderView;
@property (nonatomic, retain) IBOutlet UISlider *freqSlider;

@property (nonatomic, assign) int plusOneToDisplayBuyButton;

@property (nonatomic, retain) IBOutlet UISlider *brihgtnessSlider;
- (IBAction) brightnessSlide:(UISlider*)slider;


- (IBAction) settingsPannel;
- (IBAction) optionsPannel;

- (IBAction)freqSlide:(UISlider*)sender;
- (IBAction)changeMode:(UISegmentedControl*)segmentedControll;
- (IBAction) purchase;
- (void) failedTransaction;

- (void) changeModeDisplayForMode:(NSInteger)mode;
/*
 *
 *
 * morse
 *
 */

@property (nonatomic, retain) IBOutlet UITextField *textToPlayInMorse;


/*
 *
 *
 * fin morse
 *
 */

@property (nonatomic ,retain) NSTimer *timerStrombo;
@property (nonatomic ,retain) NSDictionary *morseCode;

@property (nonatomic, retain) IBOutlet UIButton *bouton;
@property (nonatomic, retain) IBOutlet UISlider *mySlider;

@property (nonatomic, retain) IBOutlet UIImageView *myImageView;



@property (nonatomic ,retain) AVCaptureDevice *videoCaptureDevice;
@property (nonatomic ,retain) AVCaptureDeviceInput *videoInput;

@property (nonatomic ,retain) ADBannerView *adView;
@property (nonatomic, assign) BOOL bannerIsVisible;

@property (nonatomic ,retain) GADBannerView *adMobAd;


@property (nonatomic,assign) BOOL flashAvailable;
@property (nonatomic, assign) BOOL torchIsOn;
@property (nonatomic, assign) BOOL isTheirAFlashOnTheDevice;
@property (nonatomic, assign) BOOL morseOn;

- (IBAction)buttonTouchedUp;
- (IBAction)buttonTouchedDown;

- (IBAction)shakeSwitchSwitched:(UISwitch *)shakeSwitch;
- (IBAction)flashSwitchSwitched:(UISwitch *)flashSwitch;
- (IBAction)lockSwitchSwitched:(UISwitch *)lockSwitch;

- (IBAction)mySwitchSwitched:(UISwitch *)theSwitch;

- (void)changeStateViewWithFlash:(BOOL)withFlash forStateOn:(BOOL)forStateOn;
- (void)loadUserPreferences;
- (void)saveUserPreferences;
- (void)devientActive;

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error;
- (void)bannerViewDidLoadAd:(ADBannerView *)banner;
- (void)iAdOn;

- (void) changeState;
- (void) changeState: (BOOL) on;

- (NSDictionary *)morseCode;
- (NSArray *) stringToMorse: (NSString *)textToTraduce;

/*
 *
 *
 * inApp Store
 *
 */

- (BOOL) adFreeVersionPruchased;
- (void) requestProductData;

/*
 *
 *
 * inApp Store
 *
 */

- (IBAction) shareThisAppButton;


@end