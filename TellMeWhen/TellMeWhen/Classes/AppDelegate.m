#import "AppDelegate.h"     // Header

#import "TMWStore.h"        // TMW (Model)
#import "TMWLogging.h"      // TMW (Model)
#import "TMWStoryboardIDs.h"// TMW (ViewControllers/Segues)
#import "TMWActions.h"      // TMW (ViewControllers/Protocol)
#import "TMWSegueSwapRootViewController.h"
#import <Relayr/Relayr.h>   // Relayr.framework
#import "NSData+Hexadecimal.h"

#define AppDelegate_EnteringForegroundTimer     0.8

@interface AppDelegate ()
@property (readwrite,nonatomic) BOOL enteringForeground;
@end

@implementation AppDelegate

#pragma mark - Public API

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    self.enteringForeground = YES;
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:TMWStoryboard bundle:nil];
    
    TMWStore* store = [TMWStore sharedInstance];
    UIViewController <TMWActions>* controller;
    if (store.relayrApp && store.relayrUser)
    {
        controller = [storyboard instantiateViewControllerWithIdentifier:TMWStoryboardIDs_ControllerMain];
        [controller loadIoTsWithCompletion:^(NSError* error) { if (!error && store.relayrUser.transmitters.count) { [controller loadRulesWithCompletion:nil]; } }];
    }
    else { controller = [storyboard instantiateInitialViewController]; }
    _window.rootViewController = controller;
    [_window makeKeyAndVisible];
    
    // Setup the notifications.
    UIUserNotificationType const notificationTypes = UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications];
    
    // Retrieve the notification (if any) that launched the application.
    NSDictionary* notif = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notif.count) { [((id <TMWActions>)_window.rootViewController) notificationDidArrived:notif]; }
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
    [RelayrCloud logMessage:TMWLogging_View_AppOpenned onBehalfOfUser:[TMWStore sharedInstance].relayrUser];
    self.enteringForeground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication*)application { }
- (void)applicationWillResignActive:(UIApplication*)application
{
    self.enteringForeground = NO;
}

- (void)applicationWillTerminate:(UIApplication*)application { }
- (void)applicationDidEnterBackground:(UIApplication*)application
{
    TMWStore* store = [TMWStore sharedInstance];
    RelayrApp* app = store.relayrApp;
    RelayrUser* user = app.loggedUsers.firstObject;
    if (!app || !user)
    {
        store.relayrUser = nil;
        [store.rules removeAllObjects];
        [store.notifications removeAllObjects];
        [store removeFromFileSystem];
        return;
    } else { [store persistInFileSystem]; }
}

- (void)application:(UIApplication*)application didRegisterUserNotificationSettings:(UIUserNotificationSettings*)notificationSettings { }
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    [((id <TMWActions>)_window.rootViewController) deviceTokenChangedFromData:[TMWStore sharedInstance].deviceToken toData:deviceToken];
    printf("%s\n", [[deviceToken hexadecimalString] cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    [((id <TMWActions>)_window.rootViewController) deviceTokenChangedFromData:[TMWStore sharedInstance].deviceToken toData:nil];
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    [((id <TMWActions>)_window.rootViewController) notificationDidArrived:userInfo];
}

#pragma mark - Private functionality

- (void)setEnteringForeground:(BOOL)enteringForeground
{
    static NSTimer* timer;
    if (timer) { if (timer.valid) { [timer invalidate]; } timer = nil; }
    
    if (enteringForeground)
    {
        __weak AppDelegate* weakSelf = self;
        timer = [NSTimer scheduledTimerWithTimeInterval:AppDelegate_EnteringForegroundTimer target:[NSBlockOperation blockOperationWithBlock:^{
            weakSelf.enteringForeground = NO;
        }] selector:@selector(main) userInfo:nil repeats:NO];
    }
    
    _enteringForeground = enteringForeground;
}

@end
