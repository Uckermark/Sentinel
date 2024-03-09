#import <Cephei/HBPreferences.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <spawn.h>
#import <rootless.h>

@class DNDModeAssertionLifetime;

@interface UIRootSceneWindow

- (void)setFrame:(CGRect)arg1 ;

@end

@interface SBScreenWakeAnimationController

+ (id)sharedInstance;
- (void)setScreenWakeTemporarilyDisabled:(BOOL)arg1 forReason:(id)arg2;

@end
	
@interface SpringBoard

- (void)_simulateLockButtonPress;
- (void)_updateRingerState:(int)arg1 withVisuals:(BOOL)arg2 updatePreferenceRegister:(BOOL)arg3 ;

@end

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