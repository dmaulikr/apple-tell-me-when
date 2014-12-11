#import "TMWNotificationsController.h"              // Header

#import "TMWStore.h"                                // TMW (Model)
#import "TMWAPIService.h"                           // TMW (Model)
#import "TMWNotification.h"                         // TMW (Model)

#import "TMWStoryboardIDs.h"                        // TMW (ViewControllers)
#import "TMWSegueEmbedViewInTableBacgroundkView.h"  // TMW (ViewControllers/Segue)
#import "TMWUIProperties.h"                         // TMW (Views)
#import "TMWNotificationsListCellView.h"            // TMW (Views/Notifications)

#pragma mark Definitions

#define TMWNotifListCntrll_RefreshString    @"Querying notifications..."

@interface TMWNotificationsController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem* buttonClear;
- (IBAction)clearButtonTriggered:(UIBarButtonItem*)sender;
@end

@implementation TMWNotificationsController

#pragma mark - Public API

- (void)queryNotifications
{
    [self refreshRequest:nil];
}

#pragma mark UIViewController methods

- (void)viewDidLoad
{
    UIRefreshControl* control = (self.refreshControl) ? self.refreshControl : [[UIRefreshControl alloc] init];
    control.tintColor = [UIColor whiteColor];
    [control addTarget:self action:@selector(refreshRequest:) forControlEvents:UIControlEventValueChanged];
    control.attributedTitle = [[NSAttributedString alloc] initWithString:TMWNotifListCntrll_RefreshString attributes:@{
        NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName : [UIFont fontWithName:TMWFont_NewJuneBook size:14]
    }];
    self.refreshControl = control;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self queryNotifications];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    if (![TMWStore sharedInstance].notifications.count)
    {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.navigationItem setRightBarButtonItems:nil animated:YES];
        [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromNotifsToNoNotifs sender:self];
        return 0;
    }
    else
    {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.navigationItem setRightBarButtonItems:@[_buttonClear] animated:YES];
        [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromNoNotifsToNotifs sender:self];
        return 1;
    }
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [TMWStore sharedInstance].notifications.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    TMWNotificationsListCellView* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TMWNotificationsListCellView class])];
    cell.notification = [[TMWStore sharedInstance].notifications objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - Private functionality

- (void)refreshRequest:(UIRefreshControl*)sender
{
    __weak UITableView* tableView = self.tableView;
    [TMWAPIService requestNotificationsForUserID:[TMWStore sharedInstance].relayrUser.uid completion:^(NSError* error, NSArray* notifications) {
        if (error) { return [sender endRefreshing]; }  // TODO:
        
        if (notifications.count)
        {
            TMWStore* store = [TMWStore sharedInstance];
            [TMWNotification synchronizeStoredNotifications:store.notifications withNewlyArrivedNotifications:notifications];
        }
        
        [sender endRefreshing];
        [tableView reloadData];
    }];
}

- (IBAction)clearButtonTriggered:(UIBarButtonItem *)sender
{
    __weak TMWNotificationsController* weakSelf = self;
    NSArray* notifications = [TMWStore sharedInstance].notifications.copy;
    
    [TMWAPIService deleteNotifications:notifications completion:^(NSError* error) {
        if (error) { return; }  // TODO: Handle error
        [[TMWStore sharedInstance].notifications removeObjectsInArray:notifications];
        
        TMWNotificationsController* strongSelf = weakSelf;
        if (!strongSelf) { return; }
        [strongSelf.tableView reloadData];
    }];
}
@end
