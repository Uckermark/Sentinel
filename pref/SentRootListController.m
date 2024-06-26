#include "SentRootListController.h"

#define StartSentinel @"com.megadev.sentinel/StartSentinel"


@implementation SentinelPref : HBRootListController

-(instancetype)init {
    self = [super init];

    if (self) {
    HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
    appearanceSettings.tintColor = [UIColor redColor];
    appearanceSettings.tableViewCellSeparatorColor = [UIColor colorWithWhite:0 alpha:0];
    self.hb_appearanceSettings = appearanceSettings;
    self.respringButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply"
    style:UIBarButtonItemStylePlain
    target:self
    action:@selector(respring:)];
    self.respringButton.tintColor = [UIColor redColor];
    self.navigationItem.rightBarButtonItem = self.respringButton;
    }
    return self;
}

-(NSArray *)specifiers {
    if (_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
    }

    return _specifiers;
}

- (void)respring:(id)sender {
    pid_t pid;
    const char *argv[] = {ROOT_PATH("/usr/bin/killall"), "backboardd", NULL};
    posix_spawn(&pid, ROOT_PATH("/usr/bin/killall"), NULL, NULL, (char *const *)argv, NULL);
}

-(void)triggersent{
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)StartSentinel, nil, nil, true);
}


@end









