#import <Preferences/Preferences.h>

@interface FlatVibePrefsListController: PSListController {
}
@end

@implementation FlatVibePrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"FlatVibePrefs" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
