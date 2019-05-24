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
@property (nonatomic, strong) NSString *savedTitlebullet;
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

%hook SBLockScreenNotificationListController
-(void)_addItem:(id)arg1 forBulletin:(id)arg2 playLightsAndSirens:(BOOL)arg3 withReply:(id)arg4{
	%orig(arg1,arg2,arg3,arg4);
	NSString *myTitle = [self _firstBulletin].content.title;
	SBLockScreenNotificationListView *notificationView = MSHookIvar<SBLockScreenNotificationListView *>(self, "_notificationView");
	if(notificationView){
		if([[notificationView visibleNotificationCells] count] > 0){
			SBLockScreenBulletinCell *myCell = [notificationView visibleNotificationCells][0];
			if(myTitle && ![[self _firstBulletin].section isEqualToString:@"com.apple.MobileSMS"]){
				//myCell.primaryText = myTitle;
				[myCell doodlockscreen:myTitle];
				//[self _firstBulletin].content.subtitle = myTitle;
				//[self _firstBulletin].content.title = nil;
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
%property (strong) NSString *savedTitle;
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

// - (void)prepareForReuse {
// 	self.savedTitle = nil;
// 	%orig;
// }
%end

%hook SBDefaultBannerTextView
%property (strong) NSString *savedTitlebullet;
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