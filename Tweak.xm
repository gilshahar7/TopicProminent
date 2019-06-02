#define PLIST_PATH @"/var/mobile/Library/Preferences/com.gilshahar7.topicprominentprefs.plist"

@interface SBLockScreenBulletinCell
@property (nonatomic, strong) NSString *primaryText;
@property (nonatomic, strong) NSString *subtitleText;
@property (nonatomic, strong) NSString *secondaryText;
@property (nonatomic, strong) NSString *savedTitle;
-(void)doodlockscreen:(NSString *)title;
@end

@interface SBLockScreenNotificationListView
-(NSArray *)visibleNotificationCells;
-(id)_activeBulletinForIndexPath:(id)arg1 ;
-(void)tableView:(id)arg1 willDisplayCell:(id)arg2 forRowAtIndexPath:(id)arg3 ;
-(id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 ;
@end

@interface BBContent
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@end

@interface BBBulletin
@property (nonatomic, strong) BBContent *content;
@property (nonatomic, strong) NSString *section;
@end

@interface SBLockScreenNotificationListController
-(BBBulletin *)_firstBulletin;
@end

@interface SBDefaultBannerTextView
@property (nonatomic, strong) NSString *primaryText;
@property (nonatomic, strong) NSString *subtitleText;
@property (nonatomic, strong) NSString *secondaryText;
@property (nonatomic, copy) NSString *savedTitlebullet;
-(void)doodbullet:(NSString *)title;
@end

@interface SBDefaultBannerView
@end

@interface SBBannerContextView
@end

@interface SBBannerContainerView
@property (nonatomic, strong) SBBannerContextView *bannerView;
@end

@interface SBBannerContainerViewController
@property (nonatomic, strong) SBBannerContainerView *view;
-(BBBulletin *)_bulletin;
@end

%hook SBLockScreenNotificationListView
-(void)tableView:(id)arg1 willDisplayCell:(id)arg2 forRowAtIndexPath:(id)arg3 {
	%orig;
	if ([arg2 isKindOfClass: %c(SBLockScreenBulletinCell)]) {
		SBLockScreenBulletinCell *myCell = (SBLockScreenBulletinCell*)arg2;
		BBBulletin *bulletin = [self _activeBulletinForIndexPath:arg3];
		NSString __weak *contentTitle = bulletin.content.title;
		if (contentTitle) {
			NSString *myTitle = [NSString stringWithString: contentTitle];
			if (myTitle && ![bulletin.section isEqualToString:@"com.apple.MobileSMS"]) {
				[myCell doodlockscreen:myTitle];
			}
		}

	}
}
%end


%hook SBBannerContainerViewController
-(void)setBannerContext:(id)arg1 withReplaceReason:(int)arg2 completion:(id)arg3 {
	%orig;
	if(![[self _bulletin].section isEqualToString:@"com.apple.MobileSMS"] && [self _bulletin] && self.view.bannerView) {
		NSString __weak *contentTitle = [self _bulletin].content.title;
		if (contentTitle) {
			NSString *myTitle = [NSString stringWithString:contentTitle];
			SBDefaultBannerView __weak *myBannerView = MSHookIvar<SBDefaultBannerView *>(self.view.bannerView, "_contentView");
			SBDefaultBannerTextView __weak *myBannerTextView;
			if(myBannerView){
				myBannerTextView = MSHookIvar<SBDefaultBannerTextView *>(myBannerView, "_textView");
			}
			if(myTitle){
				[myBannerTextView doodbullet:myTitle];
				//[self _bulletin].content.subtitle = myTitle;
				//[self _bulletin].content.title = nil;
			}
		}
	}
	
}
%end

%hook SBLockScreenBulletinCell
%property (copy) NSString *savedTitle;
%new
-(void)doodlockscreen:(NSString *)title{
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];
	NSInteger lockscreen = [[prefs objectForKey:@"lockscreen"] intValue];
	self.savedTitle = title;
	if(lockscreen == 2){
		if(self.subtitleText != title){
			self.subtitleText = title;
		}
	}else if(lockscreen == 3){
		if(self.primaryText != title){
			self.primaryText = title;
		}
	}

}

-(void)layoutSubviews{
	%orig;
	if(self.savedTitle){
		[self doodlockscreen:self.savedTitle];
	}
}

- (void)prepareForReuse {
	self.savedTitle = nil;
	%orig;
}
%end

%hook SBDefaultBannerTextView
%property (copy) NSString *savedTitlebullet;
%new
-(void)doodbullet:(NSString *)title{
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];
	NSInteger banners = [[prefs objectForKey:@"banners"] intValue];
	bool disablebundled = [[prefs objectForKey:@"disablebundled"] boolValue];
	
	self.savedTitlebullet = title;
	
	if(disablebundled == false){
		if(self.primaryText){
			if([self.secondaryText containsString:self.primaryText] && [self.secondaryText rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound){
				return;
			}
		}
	}
	
	if(banners == 2){
		if(self.subtitleText != title){
			self.subtitleText = title;
		}
	}
	if(banners == 3){
		if(self.primaryText != title){
			self.primaryText = title;
		}
	}
}

-(void)layoutSubviews{
	%orig;
	if(self.savedTitlebullet){
		[self doodbullet:self.savedTitlebullet];
	}
}
%end