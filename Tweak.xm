#include "Tweak.h"

#define StartSentinel @"com.megadev.sentinel/StartSentinel"

HBPreferences *pfs;
NSString *shutdownpercent = @"3.0";
UILabel *statusbarvalue = nil;
BOOL enable;
BOOL spoofpercent;

static BOOL DNDEnabled;
static DNDModeAssertionService *assertionService;
static CommonProduct* currentProduct;

UIWindow *rootwindow = nil;

NSUserDefaults *def = [[NSUserDefaults alloc] initWithSuiteName:@"com.megadev.sentinel"];

static void enableDND() {
    if (!assertionService) {
        assertionService = (DNDModeAssertionService *)[%c(DNDModeAssertionService) serviceForClientIdentifier:@"com.apple.donotdisturb.control-center.module"];
    }
    DNDModeAssertionDetails *newAssertion = [%c(DNDModeAssertionDetails) userRequestedAssertionDetailsWithIdentifier:@"com.apple.control-center.manual-toggle" modeIdentifier:@"com.apple.donotdisturb.mode.default" lifetime:nil];
    [assertionService takeModeAssertionWithDetails:newAssertion error:NULL];
}

static void disableDND() {
    if (!assertionService) {
        assertionService = (DNDModeAssertionService *)[%c(DNDModeAssertionService) serviceForClientIdentifier:@"com.apple.donotdisturb.control-center.module"];
    }
    [assertionService invalidateAllActiveModeAssertionsWithError:NULL];
}

// spoof battery label to match shutdown
%hook _UIStatusBarStringView

- (void)setText:(id)arg1{
    if(spoofpercent && [arg1 rangeOfString:[NSString stringWithFormat:@"%%"]].location != NSNotFound) {
        UIDevice *myDevice = [UIDevice currentDevice];
        [myDevice setBatteryMonitoringEnabled:YES];
        double batLeft = (float)[myDevice batteryLevel] * 100;
        int spoofedpercent = batLeft - [shutdownpercent intValue] + 1;
        NSString *batteryleftstring = [NSString stringWithFormat:@"%i%%",spoofedpercent];
        %orig(batteryleftstring);
    } else {
	    %orig;
    }
}

%end

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
	if (!sentineletoggled) {
		%orig;
	}
}


- (void)updateBatteryState:(id)arg1 {

	%orig;

    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];

    double batLeft = (float)[myDevice batteryLevel] * 100;

    if (sentineletoggled && [[%c(SBUIController) sharedInstance] isOnAC]) {
		pid_t pid;
        const char *argv[] = {ROOT_PATH("/usr/bin/killall"), "backboardd", NULL};
        posix_spawn(&pid, ROOT_PATH("/usr/bin/killall"), NULL, NULL, (char *const *)argv, NULL);
	    sentineletoggled = NO;
	    [def synchronize];
	}

    NSString *kFirstLaunchDateKey = @"firstLaunchDate";
    NSDate *firstLaunchDate = [def objectForKey:kFirstLaunchDateKey];

    if (!firstLaunchDate) {
        [def setObject:[NSDate date] forKey:kFirstLaunchDateKey];
    }

    NSDate *today = [NSDate date];
    NSTimeInterval twohours = [today timeIntervalSinceDate:firstLaunchDate];
    
    if (twohours > 300) {
        [def setValue:@(NO) forKey:@"didSaveModeActivate"];
	}
    
    if (batLeft <= [shutdownpercent intValue]) {
        BOOL triggeredyes = [[def objectForKey:@"didSaveModeActivate"]boolValue];

        if(!triggeredyes) {
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)StartSentinel, nil, nil, true);
        }
    }
}
%end

void hibernate() {
    [(SpringBoard *)[%c(SpringBoard) sharedApplication] _simulateLockButtonPress];

    io_connect_t port = IOPMFindPowerManagement((mach_port_t)MACH_PORT_NULL);
    IOPMSleepSystem(port);
	IOServiceClose(port);
}

void Sentinel() {
    UIView *window1 = [[UIView alloc] initWithFrame:CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width*3,[[UIScreen mainScreen] bounds].size.height*3)];
    window1.backgroundColor = [UIColor blackColor];

    UIImage *image = [[UIImage alloc] initWithContentsOfFile:ROOT_PATH_NS(@"/Library/Application Support/Sentinel/logo.png")];
    UIImageView *sentinellogo = [[UIImageView alloc] initWithImage:image];
    sentinellogo.alpha = 0.8;
    sentinellogo.frame = CGRectMake(0,0,50,50);
    sentinellogo.center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2, [[UIScreen mainScreen] bounds].size.height / 2);
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

    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];

    [[%c(SBLockScreenManager) sharedInstance] setBiometricAutoUnlockingDisabled:YES forReason:@"com.megadev.sentinel"];

    [[%c(SBAirplaneModeController) sharedInstance] setInAirplaneMode:YES];
    [currentProduct putDeviceInThermalSimulationMode:@"heavy"];

    hibernate();
}

%hook CommonProduct

- (id) initProduct: (id) data {
	if ((self = %orig)) if ([self respondsToSelector:@selector(putDeviceInThermalSimulationMode:)]) currentProduct = self;
	return self;
}

- (void) dealloc {
	if (currentProduct == self) currentProduct = nil;
	%orig;
}

%end

%hook DNDState

-(BOOL)isActive {
	DNDEnabled = %orig;
	return DNDEnabled;
}

%end

%hook SBTapToWakeController

-(void)tapToWakeDidRecognize:(id)arg1{
    %orig;

	if (sentineletoggled) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0  * NSEC_PER_SEC), dispatch_get_main_queue(), ^{

			[(SpringBoard *)[%c(SpringBoard) sharedApplication] _simulateLockButtonPress];

            hibernate();
        });
	}
}

%end


%hook SpringBoard

int pressed = 0;

- (_Bool)_handlePhysicalButtonEvent:(UIPressesEvent *)arg1 {
    if(sentineletoggled){
	    for(UIPress* press in arg1.allPresses.allObjects) {
		    if (press.type == 102 && press.force == 1) {
                pressed += 1;
                if (pressed == 3) {
                    pid_t pid;
                    const char *argv[] = {ROOT_PATH("/usr/bin/killall"), "backboardd", NULL};
                    posix_spawn(&pid, ROOT_PATH("/usr/bin/killall"), NULL, NULL, (char *const *)argv, NULL);
                    sentineletoggled = NO;
                }
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

    if (shouldrestore) {
        [def setValue:@(NO) forKey:@"shouldrestore"];

        if (!wasDNDon) {
	        disableDND();
        }
        [[objc_getClass("_CDBatterySaver") batterySaver] setPowerMode:lpmAfterSave error:nil];
        [[%c(SBAirplaneModeController) sharedInstance] setInAirplaneMode:airplaneafterSave];
        [currentProduct putDeviceInThermalSimulationMode:@"off"];
    }
}

%end

%end




%ctor {
    pfs = [[HBPreferences alloc] initWithIdentifier:@"com.megadev.sentinel"];

    [pfs registerBool:&enable default:YES forKey:@"enabled"];
    [pfs registerBool:&spoofpercent default:NO forKey:@"spoofpercent"];
    [pfs registerObject:&shutdownpercent default:@"3.0" forKey:@"shutdownpercent"];

    if(enable){
    	%init(tweak);
    }

    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
        //load ReplayKitModule bundle so we can hook it
        NSBundle* moduleBundle = [NSBundle bundleWithPath:@"/System/Library/ControlCenter/Bundles/ReplayKitModule.bundle"];
        if (!moduleBundle.loaded)
            [moduleBundle load];
        %init;
    }

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)Sentinel, (CFStringRef)StartSentinel, NULL, (CFNotificationSuspensionBehavior) kNilOptions);
}