#define PLIST_PATH @"/var/mobile/Library/Preferences/com.gilshahar7.topicprominentprefs.plist"

@interface SBLockScreenBulletinCell
@property (nonatomic, assign) NSString *primaryText;
@property (nonatomic, assign) NSString *subtitleText;
@property (nonatomic, assign) NSString *secondaryText;
@property (nonatomic, assign) NSString *savedTitle;
-(void)doodlockscreen:(NSString *)title;
@end

@interface SBLockScreenNotificationListView
-(NSArray *)visibleNotificationCells;
@end

@interface BBContent
@property (nonatomic, assign) NSString *title;
@property (nonatomic, assign) NSString *subtitle;
@end

@interface BBBulletin
@property (nonatomic, assign) BBContent *content;
@property (nonatomic, assign) NSString *section;
@end

@interface SBLockScreenNotificationListController
-(BBBulletin *)_firstBulletin;
@end

@interface SBDefaultBannerTextView
@property (nonatomic, assign) NSString *primaryText;
@property (nonatomic, assign) NSString *subtitleText;
@property (nonatomic, assign) NSString *secondaryText;
@property (nonatomic, assign) NSString *savedTitlebullet;
-(void)doodbullet:(NSString *)title;
@end

@interface SBDefaultBannerView
@end

@interface SBBannerContextView
@end

@interface SBBannerContainerView
@property (nonatomic, assign) SBBannerContextView *bannerView;
@end

@interface SBBannerContainerViewController
@property (nonatomic, assign) SBBannerContainerView *view;
-(BBBulletin *)_bulletin;
@end

%hook SBLockScreenNotificationListController
-(void)_addItem:(id)arg1 forBulletin:(id)arg2 playLightsAndSirens:(BOOL)arg3 withReply:(id)arg4{
	%orig(arg1,arg2,arg3,arg4);
	NSString *myTitle = [self _firstBulletin].content.title;
	SBLockScreenBulletinCell *myCell = [MSHookIvar<SBLockScreenNotificationListView *>(self, "_notificationView") visibleNotificationCells][0];
	if(myTitle && ![[self _firstBulletin].section isEqualToString:@"com.apple.MobileSMS"]){
		//myCell.primaryText = myTitle;
		[myCell doodlockscreen:myTitle];
		//[self _firstBulletin].content.subtitle = myTitle;
		//[self _firstBulletin].content.title = nil;
	}

}
%end


%hook SBBannerContainerViewController
-(void)setBannerContext:(id)arg1 withReplaceReason:(int)arg2 completion:(id)arg3{
	%orig(arg1,arg2,arg3);
	
	NSString *myTitle = [self _bulletin].content.title;
	SBDefaultBannerView *myBannerView = MSHookIvar<SBDefaultBannerView *>(self.view.bannerView, "_contentView");
	SBDefaultBannerTextView *myBannerTextView = MSHookIvar<SBDefaultBannerTextView *>(myBannerView, "_textView");
	if(myTitle && ![[self _bulletin].section isEqualToString:@"com.apple.MobileSMS"]){
		[myBannerTextView doodbullet:myTitle];
		//[self _bulletin].content.subtitle = myTitle;
		//[self _bulletin].content.title = nil;
	}
	
}
%end

%hook SBLockScreenBulletinCell
%property NSString *savedTitle;
%new
-(void)doodlockscreen:(NSString *)title{
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];
	NSInteger lockscreen = [[prefs objectForKey:@"lockscreen"] intValue];
	if(!self.savedTitle){
		self.savedTitle = title;
	}
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
%end

%hook SBDefaultBannerTextView
%property NSString *savedTitlebullet;
%new
-(void)doodbullet:(NSString *)title{
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:PLIST_PATH];
	NSInteger banners = [[prefs objectForKey:@"banners"] intValue];
	bool disablebundled = [[prefs objectForKey:@"disablebundled"] boolValue];
	
	if(!self.savedTitlebullet){
		self.savedTitlebullet = title;
	}
	
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