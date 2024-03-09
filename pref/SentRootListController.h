#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/CepheiPrefs.h>
#import <AVFoundation/AVFoundation.h>
#import <Preferences/PSEditableTableCell.h>
#import <AVKit/AVKit.h>
#import <spawn.h>
#import <UIKit/UIKit.h>
#import "NSTask.h"


@interface SentinelPref : HBRootListController {
    UITableView * _table;
}

@property (nonatomic, retain) UIBarButtonItem *respringButton;

@end
