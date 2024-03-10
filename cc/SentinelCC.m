#import "SentinelCC.h"
#define StartSentinel @"com.megadev.sentinel/StartSentinel"
@implementation SentinelCC

//Return the icon of your module here
- (UIImage *)iconGlyph
{
	return [UIImage imageNamed:@"icon" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

//Return the color selection color of your module here
- (UIColor *)selectedColor
{
	return [UIColor blueColor];
}

- (BOOL)isSelected
{
  return _selected;
}

- (void)setSelected:(BOOL)selected
{
	_selected = selected;

  [super refreshState];

  if(_selected)
  {

CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)StartSentinel, nil, nil, true);
  }
  else
  {
    //Your module got unselected, do something
  }
}

@end
