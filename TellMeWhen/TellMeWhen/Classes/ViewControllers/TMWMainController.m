#import "TMWMainController.h"               // Apple
#import "TMWStore.h"                        // TMW (Model)
#import "TMWActions.h"                      // TMW (ViewControllers/Protocols)
#import "TMWStoryboardIDs.h"                // TMW (ViewControllers/Segues)
#import "TMWRootViewControllerSwapSegue.h"  // TMW (ViewControllers/Segues)
#import "TMWUIProperties.h"                 // TMW (Views)

@interface TMWMainController () <UITabBarControllerDelegate>
@property (nonatomic, strong) NSMutableArray* overlayImageViews;
@property (nonatomic, strong) NSArray* normalTabItemImages;
@property (nonatomic, strong) NSArray* activeTabItemImages;
@end

@implementation TMWMainController

#pragma mark - Public API

- (void)deviceTokenChangedFromData:(NSData*)fromData toData:(NSData*)toData
{
    // TODO:
}

- (void)notificationDidArrived:(NSDictionary*)userInfo
{
    // TODO: (not important) Maybe show in the UITabBar as a badge.
}

- (void)loadIoTsWithCompletion:(void (^)(NSError*))completion
{
    [[TMWStore sharedInstance].relayrUser queryCloudForIoTs:completion];
}

- (IBAction)signoutFromSender:(id)sender
{
    TMWStore* store = [TMWStore sharedInstance];
    [store.relayrApp signOutUser:store.relayrUser];
    store.relayrUser = nil;
    
    UIViewController* signInVC = [[UIStoryboard storyboardWithName:TMWStoryboard bundle:nil] instantiateInitialViewController];
    TMWRootViewControllerSwapSegue* segue = [[TMWRootViewControllerSwapSegue alloc] initWithIdentifier:TMWStoryboardIDs_SegueFromSignToMain source:self destination:signInVC];
    [segue perform];
}

#pragma mark NSObject methods

- (void)awakeFromNib
{
    [[UINavigationBar appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName  : [UIColor whiteColor],
        NSFontAttributeName             : [UIFont fontWithName:TMWFont_NewJuneBold size:20]
    }];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{
        NSFontAttributeName : [UIFont fontWithName:TMWFont_NewJuneBook size:14],
        NSForegroundColorAttributeName:[UIColor whiteColor]
    } forState:UIControlStateNormal];
}

@end
