#import "TMWMainController.h"               // Apple
@import AudioToolbox;

#import "AppDelegate.h"
#import "TMWStore.h"                        // TMW (Model)
#import "TMWNavRulesController.h"           // TMW (ViewControllers)
#import "TMWNavNotificationsController.h"   // TMW (ViewControllers)
#import "TMWActions.h"                      // TMW (ViewControllers/Protocols)
#import "TMWStoryboardIDs.h"                // TMW (ViewControllers/Segues)
#import "TMWSegueSwapRootViewController.h"  // TMW (ViewControllers/Segues)
#import "TMWUIProperties.h"                 // TMW (Views)

#pragma mark - Definitions

#define TWMMainCntrll_ItemBadgeString       @"!"
#define TMWMainCntrll_NotifSoundName        @"DingDing"
#define TMWMainCntrll_NotifSoundExtension   @"wav"

@interface TMWMainController () <UITabBarControllerDelegate>
@property (readonly,nonatomic) TMWNavRulesController* navRulesController;
@property (readonly,nonatomic) TMWNavNotificationsController* navNotificationsController;
@property (readonly,nonatomic) SystemSoundID sound;
@end

@implementation TMWMainController

#pragma mark - Public API

- (void)deviceTokenChangedFromData:(NSData*)fromData toData:(NSData*)toData
{
    if (![fromData isEqualToData:toData]) { printf("\nDevice token changed...\n"); }
    [self.navRulesController deviceTokenChangedFromData:fromData toData:toData];
}

- (void)notificationDidArrived:(NSDictionary*)userInfo
{
    TMWNavNotificationsController* navNotifCntrll = self.navNotificationsController;
    navNotifCntrll.tabBarItem.badgeValue = nil;
    
    if (self.selectedViewController == navNotifCntrll)
    {
        [navNotifCntrll notificationDidArrived:userInfo];
    }
    else if (((AppDelegate*)[UIApplication sharedApplication].delegate).enteringForeground)
    {
        self.selectedViewController = navNotifCntrll;
        [navNotifCntrll notificationDidArrived:userInfo];
    }
    else
    {
        navNotifCntrll.tabBarItem.badgeValue = TWMMainCntrll_ItemBadgeString;
        AudioServicesPlayAlertSound(_sound);
    }
}

- (void)loadIoTsWithCompletion:(void (^)(NSError*))completion
{
    [[TMWStore sharedInstance].relayrUser queryCloudForIoTs:completion];
}

- (void)loadRulesWithCompletion:(void (^)(NSError* error))completion
{
    [self.navRulesController queryRulesWithCompletion:^(NSError* error) {
        if (error) { if (completion) { completion(error); } return; }
        
        TMWNavNotificationsController* navNotifCntrll = self.navNotificationsController;
        [navNotifCntrll setupNotifications];    // Delete notifications from which I have no rules.
        if (self.selectedViewController == navNotifCntrll) { [navNotifCntrll queryNotifications]; }
        
        if (completion) { completion(error); }
    }];
}

- (IBAction)signoutFromSender:(id)sender
{
    TMWStore* store = [TMWStore sharedInstance];
    [store.relayrApp signOutUser:store.relayrUser];
    store.relayrUser = nil;
    [store.rules removeAllObjects];
    [store.notifications removeAllObjects];
    [store removeFromFileSystem];
    
    UIViewController* signInVC = [[UIStoryboard storyboardWithName:TMWStoryboard bundle:nil] instantiateInitialViewController];
    [[[TMWSegueSwapRootViewController alloc] initWithIdentifier:TMWStoryboardIDs_SegueFromSignToMain source:self destination:signInVC] perform];
}

#pragma mark UIViewController methods

- (void)viewDidLoad
{
    self.delegate = self;
}

#pragma mark UITabBarControllerDelegate methods

- (void)tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController
{
    TMWNavNotificationsController* navNotifCntrll = self.navNotificationsController;
    if (tabBarController.selectedViewController != navNotifCntrll) { return; }

    [navNotifCntrll setupNotifications];
    [navNotifCntrll queryNotifications];
    viewController.tabBarItem.badgeValue = nil;
}

#pragma mark NSObject methods

- (void)awakeFromNib
{
    [[UINavigationBar appearance] setTitleTextAttributes:@{
        NSFontAttributeName             : [UIFont fontWithName:TMWFont_NewJuneBold size:20],
        NSForegroundColorAttributeName  : [UIColor whiteColor]
    }];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{
        NSFontAttributeName             : [UIFont fontWithName:TMWFont_NewJuneBook size:14],
        NSForegroundColorAttributeName  : [UIColor whiteColor]
    } forState:UIControlStateNormal];
    
    NSURL* soundPath = [[NSBundle mainBundle] URLForResource:TMWMainCntrll_NotifSoundName withExtension:TMWMainCntrll_NotifSoundExtension];
    if (!soundPath) { return; }
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPath, &_sound);
}

- (void)dealloc
{
    AudioServicesDisposeSystemSoundID(_sound);
}

#pragma mark - Private functionality

- (TMWNavRulesController*)navRulesController
{
    TMWNavRulesController* result;
    for (UINavigationController* navCntrll in self.childViewControllers)
    {
        if ([navCntrll isKindOfClass:[TMWNavRulesController class]]) { result = (TMWNavRulesController*)navCntrll; break; }
    }
    return result;
}

- (TMWNavNotificationsController*)navNotificationsController
{
    TMWNavNotificationsController* result;
    for (UINavigationController* navCntrll in self.childViewControllers)
    {
        if ([navCntrll isKindOfClass:[TMWNavNotificationsController class]]) { result = (TMWNavNotificationsController*)navCntrll; break; }
    }
    return result;
}

@end
