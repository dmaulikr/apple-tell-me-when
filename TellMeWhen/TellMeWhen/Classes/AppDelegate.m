#import <Relayr/Relayr.h> // relayr

#import "AppDelegate.h"   // Header
#import "TMWManager.h"


@interface AppDelegate ()
@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setUpNotificationsForApplication:application];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // ...
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // ...
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // ...
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // ...
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    RelayrApp *app = [TMWManager sharedInstance].relayrApp;
    if (!app) { return; }
    
    RelayrUser *user = app.loggedUsers.firstObject;
    if (!user) { return; }
    
    [[TMWManager sharedInstance] persistInFileSystem];
}

- (void)application:(UIApplication*)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    NSLog(@"%@", notificationSettings);
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSData* previousToken = [TMWManager sharedInstance].apnsToken;
    if (![previousToken isEqualToData:deviceToken])
    {
        // TODO: Send the new token to the server...
    }
    [TMWManager sharedInstance].apnsToken = deviceToken;
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [TMWManager sharedInstance].apnsToken = nil;
    NSLog(@"Did fail to register remote notification");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@", userInfo);
}


#pragma mark - Private Methods

- (void)setUpNotificationsForApplication:(UIApplication*)application
{
    UIUserNotificationType const notificationTypes = UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications];
}

@end
