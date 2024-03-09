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
    NSTask *t = [[[NSTask alloc] init] autorelease];
    [t setLaunchPath:@"/usr/bin/killall"];
    [t setArguments:[NSArray arrayWithObjects:@"backboardd", nil]];
    [t launch];
}

-(void)triggersent{
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)StartSentinel, nil, nil, true);
}


@end









