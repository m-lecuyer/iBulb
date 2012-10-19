//
//  myviewcontroller.m
//  led_flash
//
//  Created by Benoit Marilleau on 12/07/10.
//  Copyright 2010 Pionid. All rights reserved.
//

#import "myviewcontroller.h"
#import "PrincipalView.h"
#import "FlurryAnalytics.h"

@implementation myviewcontroller

@synthesize modeControll;
@synthesize bouton;
@synthesize mySlider;
@synthesize myImageView;
@synthesize rightPannel;
@synthesize leftPannel;
@synthesize brihgtnessSlider;
@synthesize flashAvailable;
@synthesize isTheirAFlashOnTheDevice;
@synthesize torchIsOn;

@synthesize videoCaptureDevice;
@synthesize videoInput;

@synthesize adView;
@synthesize bannerIsVisible;

@synthesize adMobAd;

@synthesize timerStrombo;
@synthesize morseOn;
@synthesize morseCode;

@synthesize adFreePurchaseLabel;
@synthesize cellAdFreePurchase;
@synthesize buyButton;
@synthesize plusOneToDisplayBuyButton;

@synthesize textToPlayInMorse;


#pragma mark - View life cycle

- (void)viewDidLoad {	
    [super viewDidLoad];
	
    brightness = [UIScreen mainScreen].brightness;    
    
	if(self){
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardWillShow:) 
													 name:UIKeyboardWillShowNotification 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(keyboardWillHide:) 
													 name:UIKeyboardWillHideNotification 
                                                object:nil];		
	}

	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"notFirstUseOfApplication"]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shakeToLight"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"idleTimerDisabled"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notFirstUseOfApplication"];
	}
	
	[self loadUserPreferences];

	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
    
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	
    
     if ([videoCaptureDevice hasTorch]) {			
     NSError *error = nil; 
     videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
     if (videoInput) { 
     [captureSession addInput:videoInput];
     AVCaptureVideoDataOutput* videoOutput = [[AVCaptureVideoDataOutput alloc] init];
     [videoOutput setSampleBufferDelegate:self queue:dispatch_get_current_queue()];
     [captureSession addOutput:videoOutput];
     [captureSession startRunning];
     [videoCaptureDevice lockForConfiguration:&error];
     [videoCaptureDevice setTorchMode:AVCaptureTorchModeOn];
     
     if (!isTheirAFlashOnTheDevice && !flashAvailable) {
     flashAvailable = YES;
     }
     isTheirAFlashOnTheDevice = YES;
     }
     }
     else{
     flashAvailable = NO;
     isTheirAFlashOnTheDevice = NO;
     }
     }
        else{
            flashAvailable = NO;
            isTheirAFlashOnTheDevice = NO;
	}
    
    if (flashAvailable) {
        onBrightness = brightness;
    }
    else {
        onBrightness = 1.0;
    }

    [self saveUserPreferences];
    [self changeStateViewWithFlash:flashAvailable forStateOn:YES];
    torchIsOn = YES;
    ((PrincipalView*)self.view).currentView = 0;

	if (![self adFreeVersionPruchased]) {
		[self requestProductData];
	}
	plusOneToDisplayBuyButton = 0;
	
}

- (void)viewDidAppear:(BOOL)animated {
    [self becomeFirstResponder];
    UIApplication *app = [UIApplication sharedApplication];
	app.idleTimerDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"idleTimerDisabled"];
    NSInteger mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentMode"];

    if (!rightPannel) {
        [[NSBundle mainBundle] loadNibNamed:@"Pannels" owner:self options:nil];
        modeControll.selectedSegmentIndex = mode;
        
        brihgtnessSlider.value = onBrightness;    
        [self changeModeDisplayForMode:mode];
        
        rightPannel.frame = CGRectMake(405, 37, 320, 380);
        leftPannel.frame = CGRectMake(-405, 37, 320, 380);
        [self.view addSubview:rightPannel];
        [self.view addSubview:leftPannel];
    }
    
    if (![self adFreeVersionPruchased] && !adView) {
		//-------------------------------------------------
		//on rajoute la bannière de pub, et on la cache, elle s'ouvrira qd une pub sera chargée (normalement...)
		adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
		adView.delegate = self;
		adView.tag = 1;
		[self.view addSubview:adView];
		adView.frame = CGRectOffset(adView.frame, 0, -50);
		bannerIsVisible = NO;
        
		adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
		[adMobAd retain];
		adMobIsVisible = NO;
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.bouton = nil;
	self.mySlider = nil;
	self.myImageView = nil;
	self.adFreePurchaseLabel = nil;
	self.cellAdFreePurchase = nil;
	self.buyButton = nil;
	self.adView = nil;
	self.adMobAd = nil;
}


- (void)dealloc {
    [super dealloc];
	[adMobAd release];
	[bouton release];
	[mySlider release];
	[myImageView release];
	[adView release];
	[timerStrombo release];
	[morseCode release];
	[adFreePurchaseLabel release];
	[cellAdFreePurchase release];
	[buyButton release];
}

#pragma mark - Torch

//cette fonction reprend les données utilisateur sauvegardées et les met dans les variables correspondantes
- (void) loadUserPreferences{
	flashAvailable = [[NSUserDefaults standardUserDefaults] boolForKey:@"flashAvailable"];
	isTheirAFlashOnTheDevice = [[NSUserDefaults standardUserDefaults] boolForKey:@"isTheirAFlashOnTheDevice"];
	
	float monFloat2 = [[NSUserDefaults standardUserDefaults] floatForKey:@"morseTimeOfADot"];
	if (monFloat2 == 0) {
		morseTimeOfADot = 0.3;
	}
	else{
		morseTimeOfADot = monFloat2;
	}
    
    float monFloat = [[NSUserDefaults standardUserDefaults] floatForKey:@"stroboFreq"];
	if (monFloat == 0) {
		stroboFreq = 0.1;
	}
	else{
		stroboFreq = monFloat;
	}
}

- (void) saveUserPreferences{
	[[NSUserDefaults standardUserDefaults] setBool:flashAvailable forKey:@"flashAvailable"];
	[[NSUserDefaults standardUserDefaults] setBool:isTheirAFlashOnTheDevice forKey:@"isTheirAFlashOnTheDevice"];
    [[NSUserDefaults standardUserDefaults] setFloat:morseTimeOfADot forKey:@"morseTimeOfADot"];
    [[NSUserDefaults standardUserDefaults] setFloat:stroboFreq forKey:@"stroboFreq"];
}

- (IBAction)buttonTouchedUp{	
    [FlurryAnalytics logEvent:@"ON_OFF_BUTTON"];
    
	int mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentMode"];
	if (mode == 2) {
		if ([timerStrombo isValid]) {
			[timerStrombo invalidate];
			[self changeStateViewWithFlash:flashAvailable forStateOn:NO];
		}
		else {
			timerStrombo = [[NSTimer scheduledTimerWithTimeInterval:stroboFreq target:self selector:@selector(changeState) userInfo:self repeats:YES] retain];
			[timerStrombo fire];
		}
	}
	else if (mode == 1) {
		if (!morseOn) {
			
			morseOn = YES;
			morseCode = [self morseCode];
			
			[self changeStateViewWithFlash:flashAvailable forStateOn:NO];
			[self performSelectorInBackground:@selector(morseMode:) withObject:[self stringToMorse:[textToPlayInMorse.text lowercaseString]]];
		}
		else {
			morseOn = NO;
		}
        
	}
	else {
		[self changeStateViewWithFlash:flashAvailable forStateOn:!torchIsOn];
	}
}

- (IBAction)buttonTouchedDown {
	int mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentMode"];
	if (mode == 1 && (!textToPlayInMorse.text || [textToPlayInMorse.text isEqualToString:@""])) {
		[self changeStateViewWithFlash:flashAvailable forStateOn:!torchIsOn];
	}
    
    if (torchIsOn) {
        if (flashAvailable) {
            self.myImageView.image = [UIImage imageNamed:@"on-down.png"];
        }
        else {
            self.myImageView.image = [UIImage imageNamed:@"on-down-noflash.png"];
        }
    }
    else {
        self.myImageView.image = [UIImage imageNamed:@"off-down.png"];
    }
}

- (void) changeState {
	[self changeStateViewWithFlash:flashAvailable forStateOn:!torchIsOn];
}

- (void) changeState: (BOOL) on {
	[self changeStateViewWithFlash:flashAvailable forStateOn:on];
}

- (void) devientActive{
	[self loadUserPreferences];
	int mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentMode"];
	if (mode == 1 || mode == 2){
		[self changeStateViewWithFlash:flashAvailable forStateOn:NO];
	}
	else [self changeStateViewWithFlash:flashAvailable forStateOn:YES];;
}

- (void)changeStateViewWithFlash:(BOOL)withFlash forStateOn:(BOOL)forStateOn{
	if (withFlash) {
		if (forStateOn) {
            [UIScreen mainScreen].brightness = onBrightness;
			[videoCaptureDevice setTorchMode:AVCaptureTorchModeOn];
			torchIsOn = YES;
			//on met la bonne image
			self.myImageView.image = [UIImage imageNamed:@"on-up.png"];
		}
		else {
            [UIScreen mainScreen].brightness = brightness;
			[videoCaptureDevice setTorchMode:AVCaptureTorchModeOff];
			torchIsOn = NO;
			self.myImageView.image = [UIImage imageNamed:@"off-up.png"];
		}
	}
	else {
		if (forStateOn) {
            [UIScreen mainScreen].brightness = onBrightness;
            
			self.myImageView.image = [UIImage imageNamed:@"on-up-noflash.png"];
            
			torchIsOn = YES;
			
			if (isTheirAFlashOnTheDevice) {
				[videoCaptureDevice setTorchMode:AVCaptureTorchModeOff];
			}
		}
		else {
            [UIScreen mainScreen].brightness = brightness;
            
			self.myImageView.image = [UIImage imageNamed:@"off-up.png"];
            
			torchIsOn = NO;
            
			if (isTheirAFlashOnTheDevice) {
				[videoCaptureDevice setTorchMode:AVCaptureTorchModeOff];
			}
		}
	}
	((PrincipalView*)self.view).torchIsOn = self.torchIsOn;
}

//accéléromètre: secousse -> =bouton
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
	BOOL shakeToLight = [[NSUserDefaults standardUserDefaults] boolForKey:@"shakeToLight"];
	if (event.subtype == 1 && shakeToLight) {
		[self buttonTouchedUp];
		[self buttonTouchedDown];
	}
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

#pragma mark - Morse

-(void) keyboardWillShow:(NSNotification *)note{
	[UIView beginAnimations:@"" context:nil];
	[UIView setAnimationDuration:0.3f];
    
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
	[UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.3f];
	
	[UIView commitAnimations];
	
	[self becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];    
	return YES;
}

- (NSDictionary *)morseCode {
	
	if (morseCode == nil) {
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"morseCode" ofType:@"plist"];
		NSDictionary *dico = [[NSDictionary alloc] initWithContentsOfFile:filePath];
		self.morseCode = dico;
		[dico release];
	}
	return morseCode;
}

- (NSArray *) stringToMorse: (NSString *)textToTraduce {
    
	NSArray *morseArray = [[NSArray array] retain];;
    
	for(int i = 0; i < [textToTraduce length]; i++){
		morseArray = [morseArray arrayByAddingObject:[NSString stringWithFormat:@"GAP"]];
		morseArray = [morseArray arrayByAddingObject:[NSString stringWithFormat:@"GAP"]];
		morseArray = [morseArray arrayByAddingObject:[NSString stringWithFormat:@"GAP"]];
        
		morseArray = [morseArray arrayByAddingObjectsFromArray:[morseCode objectForKey:
																[NSString stringWithFormat:@"%C", [textToTraduce characterAtIndex:i]]]];
	}
	return morseArray;
}

- (void) morseMode: (NSArray *)morseArray {
	int i = 0;
	NSString *toDo;
	
	while(morseOn && i < [morseArray count]){
		toDo = [morseArray objectAtIndex:i];
		
		if ([toDo isEqualToString:[NSString stringWithFormat:@"DOT"]]) {
			[self performSelectorOnMainThread:@selector(changeState) withObject:nil waitUntilDone:NO];
			[NSThread sleepForTimeInterval:morseTimeOfADot];
			[self performSelectorOnMainThread:@selector(changeState) withObject:nil waitUntilDone:NO];
		}
		else if ([toDo isEqualToString:[NSString stringWithFormat:@"DASH"]]) {
			[self performSelectorOnMainThread:@selector(changeState) withObject:nil waitUntilDone:NO];
			[NSThread sleepForTimeInterval:morseTimeOfADot*3];
			[self performSelectorOnMainThread:@selector(changeState) withObject:nil waitUntilDone:NO];
		}
		else if ([toDo isEqualToString:[NSString stringWithFormat:@"GAP"]]) {
			[NSThread sleepForTimeInterval:morseTimeOfADot];
		}
		
		i++;
	}
	morseOn = NO;
	[self performSelectorOnMainThread:@selector(changeState:) withObject:NO waitUntilDone:NO];
}

#pragma mark - Settings pannel

- (IBAction) settingsPannel {
    [FlurryAnalytics logEvent:@"DISPLAY_SETTINGS"];

    [(PrincipalView*)self.view settingsPannel];
}

- (IBAction)shakeSwitchSwitched:(UISwitch *)shakeSwitch {
    [FlurryAnalytics logEvent:@"SHAKE_TO_LIGHT"];

	[[NSUserDefaults standardUserDefaults] setBool:shakeSwitch.on forKey:@"shakeToLight"];
}

- (IBAction)flashSwitchSwitched:(UISwitch *)flashSwitch {
    [FlurryAnalytics logEvent:@"FLASH_SWITCH"];

	[self mySwitchSwitched:flashSwitch];
}

- (IBAction)lockSwitchSwitched:(UISwitch *)lockSwitch {
    [FlurryAnalytics logEvent:@"LOCK_SWITCH"];

	[[NSUserDefaults standardUserDefaults] setBool:!lockSwitch.on forKey:@"idleTimerDisabled"];
	UIApplication *app = [UIApplication sharedApplication];
	app.idleTimerDisabled = !lockSwitch.on;
}

- (void)mySwitchSwitched:(UISwitch *)theSwitch{
	if(!theSwitch.on){
		flashAvailable = NO;
		//[videoCaptureDevice setTorchMode:AVCaptureTorchModeOff];
        brihgtnessSlider.value = 1.0;
        onBrightness = 1.0;
        
		[self changeStateViewWithFlash:NO forStateOn:torchIsOn];
	}
	else {
		flashAvailable = YES;
		if (torchIsOn) {
            brihgtnessSlider.value = brightness;
            onBrightness = brightness;
			//[videoCaptureDevice setTorchMode:AVCaptureTorchModeOn];
		}
		[self changeStateViewWithFlash:YES forStateOn:torchIsOn];
	}
	[[NSUserDefaults standardUserDefaults] setFloat:flashAvailable forKey:@"flashAvailable"];
}

#pragma mark - Options pannel

@synthesize morseTextView;
@synthesize freqSliderView;
@synthesize freqSlider;
@synthesize torchModeOptionsView;

- (IBAction) optionsPannel {
    [FlurryAnalytics logEvent:@"DISPLAY_OPTIONS"];

    [(PrincipalView*)self.view optionsPannel];
}

- (IBAction)changeMode:(UISegmentedControl*)segmentedControll {
    [FlurryAnalytics logEvent:@"CHANGE_MODE"];
    
    NSInteger newMode = segmentedControll.selectedSegmentIndex;	
    [[NSUserDefaults standardUserDefaults] setInteger:newMode forKey:@"currentMode"];
    
    [self changeModeDisplayForMode:newMode];
    
    if (!(newMode == 2) && [timerStrombo isValid]) {
        [timerStrombo invalidate];
    }
    if (newMode != 1) {
        morseOn = NO;
    }
    
    if (newMode == 0) {
        [self changeStateViewWithFlash:flashAvailable forStateOn:YES];
    }
    else {
        [self changeStateViewWithFlash:flashAvailable forStateOn:NO];
    }
}

- (void) changeModeDisplayForMode:(NSInteger)mode {
    [self.morseTextView removeFromSuperview];
    [self.freqSliderView removeFromSuperview];
    [self.torchModeOptionsView removeFromSuperview];
        
    switch (mode) {
        case 0:
            [self.leftPannel addSubview:torchModeOptionsView];
            break;
        case 1:
            [self.leftPannel addSubview:freqSliderView];
            freqSlider.value = morseTimeOfADot;
            [self.leftPannel addSubview:morseTextView];
            break;
        case 2:
            [self.leftPannel addSubview:freqSliderView];
            freqSlider.value = stroboFreq;
            break;
            
        default:
            break;
    }
}

- (IBAction)freqSlide:(UISlider*)sender {
    [FlurryAnalytics logEvent:@"FREQ_SLIDER"];
    NSInteger mode = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentMode"];
    switch (mode) {
        case 1:
            morseTimeOfADot = sender.value;
            break;
        case 2:
            stroboFreq = sender.value;
            if ([timerStrombo isValid]) {
                [timerStrombo invalidate];
                timerStrombo = [[NSTimer scheduledTimerWithTimeInterval:stroboFreq target:self selector:@selector(changeState) userInfo:self repeats:YES] retain];
                [timerStrombo fire];
            }
            break;
            
        default:
            break;
    }
}

- (IBAction) brightnessSlide:(UISlider*)slider {
    [FlurryAnalytics logEvent:@"BRIGHTNESS_SLIDER"];
    [UIScreen mainScreen].brightness = slider.value;
    onBrightness = slider.value;
}


#pragma mark - Ad gestion

//iAd

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	if (self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		// assumes the banner view is at the top of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -50);
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
	if (!adMobIsVisible) {
		[self.view addSubview:adMobAd];
		[UIView beginAnimations:@"animateAdMobBannerOn" context:NULL];
		adMobAd.frame = CGRectOffset(adMobAd.frame, 0, 48);
        [UIView commitAnimations];
		adMobIsVisible = YES;
	}
	else if (!adMobAd) {
		adMobAd = [AdMobView requestAdWithDelegate:self]; // start a new ad request
		[adMobAd retain];
	}
    
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
	if (!bannerIsVisible) {
		if (adMobIsVisible) {
			[UIView beginAnimations:@"animateAdMobBannerOn" context:NULL];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(iAdOn)];
			adMobAd.frame = CGRectOffset(adMobAd.frame, 0, -48);
			[UIView commitAnimations];
			adMobIsVisible = NO;
		}
		else {
			[self iAdOn];
		}
    }
}

- (void)iAdOn{
	[UIView beginAnimations:@"animateAdBannerOn" context:NULL];
	// assumes the banner view is offset 50 pixels so that it is not visible.
	adView.frame = CGRectOffset(adView.frame, 0, 50);
	[UIView commitAnimations];
	self.bannerIsVisible = YES;
}

//AdMob

- (NSString *)publisherIdForAd:(AdMobView *)adView {
	return @"a14c8e53102d0c7"; // this should be prefilled; if not, get it from www.admob.com
}

- (UIViewController *)currentViewControllerForAd:(AdMobView *)adView {
	return self;
}

- (UIColor *)adBackgroundColorForAd:(AdMobView *)adView {
	return [UIColor colorWithRed:0.498 green:0.565 blue:0.667 alpha:1];
}

- (UIColor *)primaryTextColorForAd:(AdMobView *)adView {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}

- (UIColor *)secondaryTextColorForAd:(AdMobView *)adView {
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}

// Sent when an ad request loaded an ad; this is a good opportunity to attach
// the ad view to the hierachy.
- (void)didReceiveAd:(AdMobView *)adView {
	adMobAd.frame = CGRectMake(0, 0, 320, 48);
	adMobAd.frame = CGRectOffset(adMobAd.frame, 0, -48);
	
	if (!bannerIsVisible) {
		[self.view addSubview:adMobAd];
		[UIView beginAnimations:@"animateAdMobBannerOn" context:NULL];
		adMobAd.frame = CGRectOffset(adMobAd.frame, 0, 48);
        [UIView commitAnimations];
		adMobIsVisible = YES;
	}
}

// Sent when an ad request failed to load an ad
- (void)didFailToReceiveAd:(AdMobView *)adView {
	[UIView beginAnimations:@"animateAdMobBannerOn" context:NULL];
	adMobAd.frame = CGRectOffset(adMobAd.frame, 0, -48);
	[UIView commitAnimations];
	[adMobAd removeFromSuperview];
	[adMobAd release];
	adMobAd = nil;
	adMobIsVisible = NO;
}

#pragma mark - In-app gestion


- (BOOL) adFreeVersionPruchased {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"adFreeVersionPruchased"];
}

- (void) requestProductData {
	NSString *obj1 = [NSString stringWithFormat:@"com.pionid.LED.iBulbAdFree"];
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObjects: obj1, [NSString stringWithFormat:@"Test"], nil]];
	
	request.delegate = self;
	[request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *myProduct = response.products;
	
	for( NSString *invalidId in response.invalidProductIdentifiers )
        
        if ([myProduct count] != 0) {
            plusOneToDisplayBuyButton = 1;
            
            NSString *iD = [[myProduct objectAtIndex:0] localizedTitle];
            adFreePurchaseLabel.text = iD;
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:[[myProduct objectAtIndex:0] priceLocale]];
            NSString *formattedString = [numberFormatter stringFromNumber:[[myProduct objectAtIndex:0] price]];
            
            [buyButton setTitle:formattedString forState:UIControlStateNormal];
            //buyButton.backgroundColor = [UIColor grayColor];
            
        }
    [request autorelease];
}

- (IBAction) purchase {
	if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:[NSString stringWithFormat:@"com.pionid.LED.iBulbAdFree"]];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
		[buyButton removeFromSuperview];
		
		UIActivityIndicatorView *waitSymbol = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		cellAdFreePurchase.accessoryView = waitSymbol;
		[waitSymbol startAnimating];
		[waitSymbol release];
	}
	else
	{
		//... // Warn the user that purchases are disabled.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"INAPP_DISABLED_TITLE", nil) message:NSLocalizedString(@"INAPP_DISABLED_CORE", nil)
													   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void) failedTransaction {
	[cellAdFreePurchase.accessoryView removeFromSuperview];
	cellAdFreePurchase.accessoryView = buyButton;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self purchase];
	}
}

#pragma mark - Viral

@synthesize viralController;

- (ViralController *) viralController {
    if (viralController) {
        return viralController;
    }
    
    viralController = [[ViralController alloc] init];
    return viralController;
}

- (IBAction) shareThisAppButton {
    [FlurryAnalytics logEvent:@"SHARE_THE_APP"];
    [self.viralController displayShareControllerInController:self];
}

- (IBAction) onpenBuyCenter {
    [FlurryAnalytics logEvent:@"BUY_CENTER"];
    [self.viralController displayBuyControllerInController:self];
}

@end
