//#import "MediaRemote.h"
#import <Cephei/HBPreferences.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <spawn.h>

#define StartSentinel @"com.megadev.sentinel/StartSentinel"

HBPreferences *pfs;
NSString *shutdownpercent = @"3.0";
UILabel *statusbarvalue = nil;
BOOL enable;

UIWindow *rootwindow = nil;

@interface UIRootSceneWindow

- (void)setFrame:(CGRect)arg1 ;

@end

NSUserDefaults *def = [[NSUserDefaults alloc] initWithSuiteName:@"com.megadev.sentinel"];

@interface SBScreenWakeAnimationController

+ (id)sharedInstance;
- (void)setScreenWakeTemporarilyDisabled:(BOOL)arg1 forReason:(id)arg2;

@end

	
@interface SpringBoard

- (void)_simulateLockButtonPress;
- (void)_updateRingerState:(int)arg1 withVisuals:(BOOL)arg2 updatePreferenceRegister:(BOOL)arg3 ;

@end

BOOL spoofpercent;
BOOL stopmusic;

@class DNDModeAssertionLifetime;

@interface DNDModeAssertionDetails : NSObject

+ (id)userRequestedAssertionDetailsWithIdentifier:(NSString *)identifier modeIdentifier:(NSString *)modeIdentifier lifetime:(DNDModeAssertionLifetime *)lifetime;
- (BOOL)invalidateAllActiveModeAssertionsWithError:(NSError **)error;
- (id)takeModeAssertionWithDetails:(DNDModeAssertionDetails *)assertionDetails error:(NSError **)error;

@end

@interface DNDModeAssertionService : NSObject

+ (id)serviceForClientIdentifier:(NSString *)clientIdentifier;
- (BOOL)invalidateAllActiveModeAssertionsWithError:(NSError **)error;
- (id)takeModeAssertionWithDetails:(DNDModeAssertionDetails *)assertionDetails error:(NSError **)error;

@end



static BOOL DNDEnabled;
static DNDModeAssertionService *assertionService;


@interface _CDBatterySaver

- (id)batterySaver;
- (long long)getPowerMode;
- (BOOL)setPowerMode:(long long)arg1 error:(id *)arg2;

@end

@interface SBLockScreenManager

+ (id)sharedInstance;
- (void)setBiometricAutoUnlockingDisabled:(BOOL)arg1 forReason:(id)arg2 ;
- (_Bool)unlockUIFromSource:(int)arg1 withOptions:(id)arg2;

@end

@interface SBAirplaneModeController

+ (id)sharedInstance;
- (BOOL)isInAirplaneMode;
- (void)setInAirplaneMode:(BOOL)arg1 ;

@end

@interface SBSleepWakeHardwareButtonInteraction

- (void)_performSleep;
- (void)_performWake;

@end

@interface SBTapToWakeController

- (void)setScreenOff:(BOOL)arg1 ;
- (BOOL)shouldTapToWake;

@end

@interface SBLiftToWakeController

- (void)removeObserver:(id)arg1;
+ (id)sharedController;
- (void)_screenTurnedOff;
- (void)_stopObservingIfNecessary;

@end

@interface SBUIController

- (id)init;
- (BOOL)isOnAC;
+ (id)sharedInstance;
- (void)updateBatteryState:(id)arg1 ;
- (void)_deviceUILocked;
- (void)setChargingChimeEnabled:(BOOL)arg1 ;

@end

@interface SBHomeHardwareButton

- (void)setHapticType:(long long)arg1 ;

@end

@interface _UIStatusBarStringView : UILabel

- (void)setText:(id)arg1 ;	
- (void)setOriginalText:(NSString *)arg1 ;

@end

%hook _UIStatusBarStringView

- (void)setText:(id)arg1{
    if(spoofpercent) {
	    if([arg1 rangeOfString:[NSString stringWithFormat:@"%%"]].location != NSNotFound) {
            UIDevice *myDevice = [UIDevice currentDevice];
            [myDevice setBatteryMonitoringEnabled:YES];
            double batLeft = (float)[myDevice batteryLevel] * 100;
            int spoofedpercent = batLeft - [shutdownpercent intValue] + 1;
            NSString *batteryleftstring = [NSString stringWithFormat:@"%i%%",spoofedpercent];
            %orig(batteryleftstring);
	    } else {
		    %orig;
	    }
    } else {
	    %orig;
    }
}

%end

static void enableDND(){
    if (!assertionService) {
        assertionService = (DNDModeAssertionService *)[%c(DNDModeAssertionService) serviceForClientIdentifier:@"com.apple.donotdisturb.control-center.module"];
    }
    DNDModeAssertionDetails *newAssertion = [%c(DNDModeAssertionDetails) userRequestedAssertionDetailsWithIdentifier:@"com.apple.control-center.manual-toggle" modeIdentifier:@"com.apple.donotdisturb.mode.default" lifetime:nil];
    [assertionService takeModeAssertionWithDetails:newAssertion error:NULL];
}

static void disableDND(){
    if (!assertionService) {
        assertionService = (DNDModeAssertionService *)[%c(DNDModeAssertionService) serviceForClientIdentifier:@"com.apple.donotdisturb.control-center.module"];
    }
    [assertionService invalidateAllActiveModeAssertionsWithError:NULL];
}

%group tweak

BOOL sentineletoggled = NO;

%hook UIRootSceneWindow

-(void)setFrame:(CGRect)arg1{
	  rootwindow = (UIWindow *)self;

	  return %orig;
}

%end




%hook SBUIController

- (void)ACPowerChanged{
	if(!sentineletoggled){
		%orig;
	}
}


- (void)updateBatteryState:(id)arg1 {

	%orig;
		
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];

    double batLeft = (float)[myDevice batteryLevel] * 100;

    if ([[%c(SBUIController) sharedInstance] isOnAC]) {
        if(sentineletoggled){
		    pid_t pid;
            const char *argv[] = {"/usr/bin/killall", "backboardd", NULL};
            posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)argv, NULL);

	        sentineletoggled = NO;

	        [def synchronize];
        }
	}

    NSString *kFirstLaunchDateKey = @"firstLaunchDate";
    NSDate *firstLaunchDate = [def objectForKey:kFirstLaunchDateKey];

    if (!firstLaunchDate) {
        [def setObject:[NSDate date] forKey:kFirstLaunchDateKey];
    }

    NSDate *today = [NSDate date];
    NSTimeInterval twohours = [today timeIntervalSinceDate:firstLaunchDate];
    
    if ( twohours > 300 ) {
        [def setValue:@(NO) forKey:@"didSaveModeActivate"];
	}
    
    if( batLeft < [shutdownpercent intValue] || batLeft == [shutdownpercent intValue]){
        BOOL triggeredyes = [[def objectForKey:@"didSaveModeActivate"]boolValue];

        if(!triggeredyes) {
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)StartSentinel, nil, nil, true);
        }
    }
}
%end


void Sentinel() {
    UIView *window1 = [[UIView alloc] initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width*3,[[UIScreen mainScreen] bounds].size.height*3)];
    window1.backgroundColor = [UIColor blackColor];

    UIImage *image = [[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Sentinel/logo.png"];
    UIImageView *sentinellogo = [[UIImageView alloc] initWithImage:image];
    sentinellogo.alpha = 0.8;
    sentinellogo.frame = CGRectMake(0,0,50,50);
    sentinellogo.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2, 

    [[UIScreen mainScreen] bounds].size.height / 2);
	[window1 addSubview:sentinellogo];						 

    [rootwindow addSubview:window1];

    NSString *kFirstLaunchDateKey = @"firstLaunchDate";
    [def setObject:[NSDate date] forKey:kFirstLaunchDateKey];
	[[%c(SBUIController) sharedInstance] setChargingChimeEnabled:NO];

	[[%c(SBLiftToWakeController) sharedController] _stopObservingIfNecessary];
	sentineletoggled = YES;

    BOOL powermode = [[objc_getClass("_CDBatterySaver") batterySaver] getPowerMode];
    BOOL Airplane = [[%c(SBAirplaneModeController) sharedInstance] isInAirplaneMode];

    BOOL activated = YES;

    [def setValue:@(activated) forKey:@"didSaveModeActivate"];

    [def setValue:@(activated) forKey:@"shouldrestore"];

    [def setValue:@(powermode) forKey:@"isPowerModeActive"];
    [def setValue:@(Airplane) forKey:@"isAirplaneActive"];
    [def setValue:@(DNDEnabled) forKey:@"isDNDActive"];
    [def synchronize];

    enableDND();

    [(SpringBoard *)[%c(SpringBoard) sharedApplication] _updateRingerState:0 withVisuals:NO updatePreferenceRegister:NO];
    [[objc_getClass("_CDBatterySaver") batterySaver] setPowerMode:1 error:nil];

    if(!stopmusic){
    	NSLog(@"[Sentinel] Stop music unimplemented");
        //MRMediaRemoteSendCommand(kMRPause, nil);
    }

    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [[UIDevice currentDevice] proximityState];

    SBLockScreenManager *sensor = [%c(SBLockScreenManager) sharedInstance];
    [sensor setBiometricAutoUnlockingDisabled:YES forReason:@"com.megadev.sentinel"];

    [[%c(SBAirplaneModeController) sharedInstance] setInAirplaneMode:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0  * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[(SpringBoard *)[%c(SpringBoard) sharedApplication] _simulateLockButtonPress];
        pid_t pid;
        const char *argv[] = {"/usr/bin/SentinelRunner", "", NULL};
        posix_spawn(&pid, "/usr/bin/SentinelRunner", NULL, NULL, (char *const *)argv, NULL);
	});
}

%hook DNDState

-(BOOL)isActive {
    //save the DND state.
	DNDEnabled = %orig;
	return DNDEnabled;
}

%end

%hook SBTapToWakeController

-(void)tapToWakeDidRecognize:(id)arg1{
    %orig;

	if(sentineletoggled){
        NSLog(@"kankerhomo");

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0  * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

			[(SpringBoard *)[%c(SpringBoard) sharedApplication] _simulateLockButtonPress];

            pid_t pid;
            const char *argv[] = {"/usr/bin/SentinelRunner", "", NULL};
            posix_spawn(&pid, "/usr/bin/SentinelRunner", NULL, NULL, (char *const *)argv, NULL);
        });
	}
}

%end 


%hook SpringBoard

int pressed = 0;

-(_Bool)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1 {
	if(sentineletoggled){
	    for(UIPress* press in arg1.allPresses.allObjects) {
		    if (press.type == 102 && press.force == 1) {
		        pressed += 1;
	            if(pressed == 3){
	                pid_t pid;
                    const char *argv[] = {"/usr/bin/killall", "backboardd", NULL};
                    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)argv, NULL);
	                sentineletoggled = NO;
                }
		    } else {
                return %orig;
		    }
	    }
	}
	return %orig;
}


- (void)applicationDidFinishLaunching:(id)arg1 {
    BOOL shouldrestore = [[def objectForKey:@"shouldrestore"]boolValue];
    BOOL lpmAfterSave = [[def objectForKey:@"isPowerModeActive"]boolValue];
    BOOL airplaneafterSave = [[def objectForKey:@"isAirplaneActive"]boolValue];
    BOOL wasDNDon = [[def objectForKey:@"isDNDActive"]boolValue];
	%orig;

    if(shouldrestore){
        [def setValue:@(NO) forKey:@"shouldrestore"];

        if(!wasDNDon){
	        disableDND();
        }
        [[objc_getClass("_CDBatterySaver") batterySaver] setPowerMode:lpmAfterSave error:nil];
        [[%c(SBAirplaneModeController) sharedInstance] setInAirplaneMode:airplaneafterSave];
    }
}

%end

%end




%ctor {
    pfs = [[HBPreferences alloc] initWithIdentifier:@"com.megadev.sentinel"];

    [pfs registerBool:&enable default:YES forKey:@"enabled"];
    [pfs registerBool:&stopmusic default:NO forKey:@"stopmusic"];
    [pfs registerBool:&spoofpercent default:NO forKey:@"spoofpercent"];
    [pfs registerObject:&shutdownpercent default:@"3.0" forKey:@"shutdownpercent"];

    if(enable){
    	%init(tweak);
    }

    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"])
    {
        //load ReplayKitModule bundle so we can hook it
        NSBundle* moduleBundle = [NSBundle bundleWithPath:@"/System/Library/ControlCenter/Bundles/ReplayKitModule.bundle"];
        if (!moduleBundle.loaded)
            [moduleBundle load];
        %init;
    }

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)Sentinel, (CFStringRef)StartSentinel, NULL, (CFNotificationSuspensionBehavior) kNilOptions);
}