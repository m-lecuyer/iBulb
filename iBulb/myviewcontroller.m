//
//  myviewcontroller.m
//  led_flash
//
//  Created by Benoit Marilleau on 12/07/10.
//  Copyright 2010 Pionid. All rights reserved.
//

#import "myviewcontroller.h"
#import "PrincipalView.h"
#import "Flurry.h"

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
@synthesize adFreePurchaseWaiting;
@synthesize buyButton;
@synthesize plusOneToDisplayBuyButton;

@synthesize textToPlayInMorse;
@synthesize shakeSwitch, flashSwitch, lockSwitch;

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
        NSLog(@"PPPUUUUUUTTTTEEEE");
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
                [videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
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
	} else {
        buyButton.hidden = YES;
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
        [adFreePurchaseWaiting removeFromSuperview];
        [self.view addSubview:rightPannel];
        [self.view addSubview:leftPannel];
        
        shakeSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"shakeToLight"];
        lockSwitch.on = ![[NSUserDefaults standardUserDefaults] boolForKey:@"idleTimerDisabled"];
        flashSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"flashAvailable"];
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
        
        // Create a view of the standard size at the top of the screen.
        // Available AdSize constants are explained in GADAdSize.h.
        adMobAd = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        adMobAd.frame = CGRectOffset(adMobAd.frame, 0, -48);
        // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
        adMobAd.adUnitID = @"a14c8e53102d0c7";
        // Let the runtime know which UIViewController to restore after taking
        // the user wherever the ad goes and add it to the view hierarchy.
        adMobAd.rootViewController = self;
        
        // Initiate a generic request to load it with an ad.
        [adMobAd loadRequest:[GADRequest request]];
        
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
	self.adFreePurchaseWaiting = nil;
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
	[adFreePurchaseWaiting release];
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
    [Flurry logEvent:@"ON_OFF_BUTTON"];
    
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
            if ([[UIScreen mainScreen] bounds].size.height == 568) {
                self.myImageView.image = [UIImage imageNamed:@"on-down-568h@2x.png"];
            } else {
                self.myImageView.image = [UIImage imageNamed:@"on-down.png"];
            }
        }
        else {
            if ([[UIScreen mainScreen] bounds].size.height == 568) {
                self.myImageView.image = [UIImage imageNamed:@"on-down-noflash-568h@2x.png"];
            } else {
                self.myImageView.image = [UIImage imageNamed:@"on-down-noflash.png"];
            }
        }
    }
    else {
        if ([[UIScreen mainScreen] bounds].size.height == 568) {
            self.myImageView.image = [UIImage imageNamed:@"off-down-568h@2x.png"];
        } else {
            self.myImageView.image = [UIImage imageNamed:@"off-down.png"];
        }
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
			if ([[UIScreen mainScreen] bounds].size.height == 568) {
                self.myImageView.image = [UIImage imageNamed:@"on-up-568h@2x.png"];
            } else {
                self.myImageView.image = [UIImage imageNamed:@"on-up.png"];
            }
		}
		else {
            [UIScreen mainScreen].brightness = brightness;
			[videoCaptureDevice setTorchMode:AVCaptureTorchModeOff];
			torchIsOn = NO;
			if ([[UIScreen mainScreen] bounds].size.height == 568) {
                self.myImageView.image = [UIImage imageNamed:@"off-up-568h@2x.png"];
            } else {
                self.myImageView.image = [UIImage imageNamed:@"off-up.png"];
            }
		}
	}
	else {
		if (forStateOn) {
            [UIScreen mainScreen].brightness = onBrightness;
            
			if ([[UIScreen mainScreen] bounds].size.height == 568) {
                self.myImageView.image = [UIImage imageNamed:@"on-up-noflash-568h@2x.png"];
            } else {
                self.myImageView.image = [UIImage imageNamed:@"on-up-noflash.png"];
            }
            
			torchIsOn = YES;
			
			if (isTheirAFlashOnTheDevice) {
				[videoCaptureDevice setTorchMode:AVCaptureTorchModeOff];
			}
		}
		else {
            [UIScreen mainScreen].brightness = brightness;
            
			if ([[UIScreen mainScreen] bounds].size.height == 568) {
                self.myImageView.image = [UIImage imageNamed:@"off-up-568h@2x.png"];
            } else {
                self.myImageView.image = [UIImage imageNamed:@"off-up.png"];
            }
            
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
    [Flurry logEvent:@"DISPLAY_SETTINGS"];

    [(PrincipalView*)self.view settingsPannel];
}

- (IBAction)shakeSwitchSwitched:(UISwitch *)sSwitch {
    [Flurry logEvent:@"SHAKE_TO_LIGHT"];

	[[NSUserDefaults standardUserDefaults] setBool:sSwitch.on forKey:@"shakeToLight"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)flashSwitchSwitched:(UISwitch *)fSwitch {
    [Flurry logEvent:@"FLASH_SWITCH"];

	[self mySwitchSwitched:fSwitch];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)lockSwitchSwitched:(UISwitch *)lSwitch {
    [Flurry logEvent:@"LOCK_SWITCH"];

	[[NSUserDefaults standardUserDefaults] setBool:!lockSwitch.on forKey:@"idleTimerDisabled"];
	UIApplication *app = [UIApplication sharedApplication];
	app.idleTimerDisabled = !lSwitch.on;
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    [Flurry logEvent:@"DISPLAY_OPTIONS"];

    [(PrincipalView*)self.view optionsPannel];
}

- (IBAction)changeMode:(UISegmentedControl*)segmentedControll {
    [Flurry logEvent:@"CHANGE_MODE"];
    
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
    [Flurry logEvent:@"FREQ_SLIDER"];
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
    [Flurry logEvent:@"BRIGHTNESS_SLIDER"];
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
		[adMobAd loadRequest:[GADRequest request]]; // start a new ad request
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
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:[[myProduct objectAtIndex:0] priceLocale]];
            NSString *formattedString = [numberFormatter stringFromNumber:[[myProduct objectAtIndex:0] price]];
            
            [buyButton setTitle:formattedString forState:UIControlStateNormal];            
        }
    [request autorelease];
}

- (IBAction) purchase {
	if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:[NSString stringWithFormat:@"com.pionid.LED.iBulbAdFree"]];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
		//[buyButton removeFromSuperview];
		
        buyButton.hidden = YES;
        [self.rightPannel addSubview:adFreePurchaseWaiting];
		[adFreePurchaseWaiting startAnimating];
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
    [adFreePurchaseWaiting stopAnimating];
    [adFreePurchaseWaiting removeFromSuperview];
	buyButton.hidden = NO;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self purchase];
    }
    buyButton.hidden = NO;
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
    [Flurry logEvent:@"SHARE_THE_APP"];
    [self.viralController displayShareControllerInController:self];
}

- (IBAction) onpenBuyCenter {
    [Flurry logEvent:@"BUY_CENTER"];
    [self.viralController displayBuyControllerInController:self];
}

@end
