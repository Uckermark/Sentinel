#import <CepheiPrefs/CepheiPrefs.h>
#import <spawn.h>
#import <rootless.h>


@interface SentinelPref : HBRootListController {
    UITableView * _table;
}

@property (nonatomic, retain) UIBarButtonItem *respringButton;

@end
