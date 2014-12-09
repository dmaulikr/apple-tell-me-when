#import "TMWTabBarController.h" // Apple
#import "TMWManager.h"          // TMW (Model)
#import "TMWActions.h"          // TMW (ViewControllers/Protocols)
#import "TMWStoryboardIDs.h"    // TMW (ViewControllers/Segues)
#import "TMWRootViewControllerSwapSegue.h"  // TMW (ViewControllers/Segues)

@interface TMWTabBarController () <UITabBarControllerDelegate,TMWActions>
@property (nonatomic, strong) NSMutableArray* overlayImageViews;
@property (nonatomic, strong) NSArray* normalTabItemImages;
@property (nonatomic, strong) NSArray* activeTabItemImages;
@end

@implementation TMWTabBarController

#pragma mark - Public API

#pragma mark NSObject methods

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
    [self setUpTabBarImageArrays];
}

#pragma mark UIViewController methods

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self tabBarController:self didSelectViewController:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customiseNavigationBar];
    [self setUpTabBarOverlay];
}


#pragma mark - Tab bar controller delegate methods

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSInteger index = [tabBarController selectedIndex];
    for (UIImageView *imageView in _overlayImageViews) {
        [imageView setHighlighted:NO];
        [(UIImageView *)[imageView.subviews objectAtIndex:0] setHighlighted:NO];
    }
    UIImageView *selectedImageView = [_overlayImageViews objectAtIndex:index];
    [selectedImageView setHighlighted:YES];
    [(UIImageView *)[selectedImageView.subviews objectAtIndex:0] setHighlighted:YES];
}


#pragma mark - Private Methods

- (void)setUpTabBarImageArrays
{
    _overlayImageViews = [NSMutableArray array];
    _normalTabItemImages = @[[UIImage imageNamed:@"RulesTabNormal"], [UIImage imageNamed:@"NotificationsTabNormal"]];
    _activeTabItemImages = @[[UIImage imageNamed:@"RulesTabActive"], [UIImage imageNamed:@"NotificationsTabActive"]];
}

- (void)setUpTabBarOverlay
{
    UIView *tabBarOverlay = [[UIView alloc] initWithFrame:[[self tabBar] bounds]];
    [tabBarOverlay setBackgroundColor:[UIColor colorWithRed:00/255.0f green:28/255.0f blue:62/255.0f alpha:1]];
    [tabBarOverlay setUserInteractionEnabled:NO];
    NSInteger width = [[self tabBar] frame].size.width / [_normalTabItemImages count];
    NSInteger height = [[self tabBar] frame].size.height;
    for (int imageindex = 0; imageindex < [_normalTabItemImages count]; imageindex++) {
        UIImageView *customTabBarBackground = [[UIImageView alloc] initWithFrame:CGRectMake(imageindex * width, 0, width, height)];
        [_overlayImageViews addObject:customTabBarBackground];
        [customTabBarBackground setContentMode:UIViewContentModeRedraw]; // Stretch the background to fit all screen sizes
        [customTabBarBackground setImage:[UIImage imageNamed:@"TabBarBackgroundItemNormal"]];
        [customTabBarBackground setHighlightedImage:[UIImage imageNamed:@"TabBarItemBackgroundActive"]];
        [tabBarOverlay addSubview:customTabBarBackground];
        UIImageView *customTabBarItem = [[UIImageView alloc] initWithFrame:customTabBarBackground.bounds];
        [customTabBarItem setContentMode:UIViewContentModeScaleAspectFit];
        [customTabBarItem setImage:[_normalTabItemImages objectAtIndex:imageindex]];
        [customTabBarItem setHighlightedImage:[_activeTabItemImages objectAtIndex:imageindex]];
        [customTabBarBackground addSubview:customTabBarItem];
        customTabBarBackground = nil;
        customTabBarItem = nil;
    }
    [[self tabBar] addSubview:tabBarOverlay];
}

- (void)customiseNavigationBar
{
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"NewJuneBook" size:16], NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    UINavigationController *rulesNavigationController = (UINavigationController *)[self.viewControllers objectAtIndex:0];
    if (rulesNavigationController) {
        rulesNavigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"NewJuneBold" size:20], NSForegroundColorAttributeName:[UIColor whiteColor]};
    }
    UINavigationController *notificationNavigationController = (UINavigationController *)[self.viewControllers objectAtIndex:1];
    if (notificationNavigationController) {
        notificationNavigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"NewJuneBold" size:20], NSForegroundColorAttributeName:[UIColor whiteColor]};
    }
}

#pragma mark TMWActions methods

- (void)signoutFromSender:(id)sender
{
    NSLog(@"Signout called");
    
    [[TMWManager sharedInstance] signOut];
    
    UIViewController* signInVC = [[UIStoryboard storyboardWithName:TMWStoryboard bundle:nil] instantiateInitialViewController];
    TMWRootViewControllerSwapSegue* segue = [[TMWRootViewControllerSwapSegue alloc] initWithIdentifier:TMWStoryboardIDs_SegueFromSignToMain source:self destination:signInVC];
    [segue perform];
}

@end
