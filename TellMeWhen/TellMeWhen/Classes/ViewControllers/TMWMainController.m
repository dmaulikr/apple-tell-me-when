#import "TMWMainController.h" // Apple
#import "TMWStore.h"          // TMW (Model)
#import "TMWActions.h"          // TMW (ViewControllers/Protocols)
#import "TMWStoryboardIDs.h"    // TMW (ViewControllers/Segues)
#import "TMWRootViewControllerSwapSegue.h"  // TMW (ViewControllers/Segues)

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
    // TODO:
}

- (void)signoutFromSender:(id)sender
{
    TMWStore* store = [TMWStore sharedInstance];
    [store.relayrApp signOutUser:store.relayrUser];
    store.relayrUser = nil;
    
    UIViewController* signInVC = [[UIStoryboard storyboardWithName:TMWStoryboard bundle:nil] instantiateInitialViewController];
    TMWRootViewControllerSwapSegue* segue = [[TMWRootViewControllerSwapSegue alloc] initWithIdentifier:TMWStoryboardIDs_SegueFromSignToMain source:self destination:signInVC];
    [segue perform];
}

#pragma mark UIViewController methods

- (void)viewWillAppear:(BOOL)animated
{
    TMWStore* store = [TMWStore sharedInstance];
    RelayrApp* app = store.relayrApp;
    RelayrUser* user = store.relayrUser;
    NSLog(@"%@\n%@", app, user);
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    [self customiseNavigationBar];
//    [self setUpTabBarOverlay];
//}

#pragma mark - Private functionality

//- (void)customiseNavigationBar
//{
//    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
//     setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"NewJuneBook" size:16], NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
//    UINavigationController *rulesNavigationController = (UINavigationController *)[self.viewControllers objectAtIndex:0];
//    if (rulesNavigationController) {
//        rulesNavigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"NewJuneBold" size:20], NSForegroundColorAttributeName:[UIColor whiteColor]};
//    }
//    UINavigationController *notificationNavigationController = (UINavigationController *)[self.viewControllers objectAtIndex:1];
//    if (notificationNavigationController) {
//        notificationNavigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"NewJuneBold" size:20], NSForegroundColorAttributeName:[UIColor whiteColor]};
//    }
//}

@end
