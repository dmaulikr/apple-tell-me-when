#import "TMWNotificationsController.h"              // Header

#import "TMWStore.h"                                // TMW (Model)
#import "TMWAPIService.h"                           // TMW (Model)
#import "TMWNotification.h"                         // TMW (Model)
#import "TMWLogging.h"                              // TMW (Model)
#import <Relayr/RelayrCloud.h>                      // Relayr.framework
#import "TMWStoryboardIDs.h"                        // TMW (ViewControllers)
#import "TMWSegueEmbedViewInTableBacgroundkView.h"  // TMW (ViewControllers/Segue)
#import "TMWNotificationDetailsController.h"        // TMW (ViewControllers/Notifications)
#import "TMWUIProperties.h"                         // TMW (Views)
#import "TMWNotificationsCellView.h"                // TMW (Views/Notifications)

#pragma mark Definitions

#define TMWNotifListCntrll_RefreshString    @"Querying notifications..."

@interface TMWNotificationsController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem* buttonClear;
- (IBAction)clearButtonTriggered:(UIBarButtonItem*)sender;
@end

@implementation TMWNotificationsController

#pragma mark - Public API

- (void)setupNotifications
{
    BOOL isThereChanges = [[TMWStore sharedInstance] removeUnlinkedNotifications];
    if (!isThereChanges || !self.isViewLoaded) { return; }
    
    [self.tableView reloadData];
}

- (void)queryNotificationsWithCompletion:(void (^)(NSError* error))completion
{
    __weak TMWNotificationsController* weakSelf = self;
    [TMWAPIService requestNotificationsForUserID:[TMWStore sharedInstance].relayrUser.uid completion:^(NSError* error, NSArray* notifications) {
        if (error || !notifications.count) { if (completion) { completion(error); } return; }
        
        [TMWAPIService deleteNotifications:notifications completion:^(NSError* error) {
            if (error) { if (completion) { completion(error); } return; }
            NSUInteger const numPreviousNotifications = [TMWStore sharedInstance].notifications.count;
            
            __autoreleasing NSArray* indexPathsToAdd;
            BOOL isThereChanges = [TMWNotification synchronizeStoredNotifications:[TMWStore sharedInstance].notifications withNewlyArrivedNotifications:notifications resultingInCellsIndexPathsToAdd:&indexPathsToAdd];
            
            TMWNotificationsController* strongSelf = weakSelf;
            if (strongSelf && isThereChanges && strongSelf.isViewLoaded)
            {
                if (!numPreviousNotifications) {
                    [strongSelf.tableView reloadData];
                } else {
                    [strongSelf.tableView insertRowsAtIndexPaths:indexPathsToAdd withRowAnimation:TMWCntrl_RowAdditionAnimation];
                }
            }
            
            if (completion) { completion(error); }
        }];
    }];
}

#pragma mark UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl* control = (self.refreshControl) ? self.refreshControl : [[UIRefreshControl alloc] init];
    control.tintColor = [UIColor whiteColor];
    [control addTarget:self action:@selector(refreshRequest:) forControlEvents:UIControlEventValueChanged];
    control.attributedTitle = [[NSAttributedString alloc] initWithString:TMWNotifListCntrll_RefreshString attributes:@{
        NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName : [UIFont fontWithName:TMWFont_NewJuneBook size:14]
    }];
    self.refreshControl = control;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:TMWStoryboardIDs_SegueFromNotifsToDetails])
    {
        TMWNotificationsCellView* cell = (TMWNotificationsCellView*)[self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
        ((TMWNotificationDetailsController*)segue.destinationViewController).notification = cell.notification;
    }
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    if (![TMWStore sharedInstance].notifications.count)
    {
        [self.navigationItem setRightBarButtonItems:nil animated:YES];
        [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromNotifsToNoNotifs sender:self];
        return 0;
    }
    else
    {
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
    TMWNotificationsCellView* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TMWNotificationsCellView class])];
    cell.notification = [[TMWStore sharedInstance].notifications objectAtIndex:indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) { return; }
    
    NSMutableArray* notifications = [TMWStore sharedInstance].notifications;
    [notifications removeObjectAtIndex:indexPath.row];
    [RelayrCloud logMessage:TMWLogging_Delete_Notification onBehalfOfUser:[TMWStore sharedInstance].relayrUser];
    
    if (!notifications.count)
    {
        [tableView reloadData];
    }
    else
    {
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:TMWCntrl_RowDeletionAnimation];
    }
}

#pragma mark UITableViewDelegate methods

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    TMWNotificationsCellView* cell = (TMWNotificationsCellView*)[tableView cellForRowAtIndexPath:indexPath];
    TMWNotification* notification = cell.notification;
    if (!notification) { return [tableView deselectRowAtIndexPath:indexPath animated:YES]; }
    [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromNotifsToDetails sender:self];
}

#pragma mark - Private functionality

- (void)refreshRequest:(UIRefreshControl*)sender
{
    __weak TMWNotificationsController* weakSelf = self;
    [self queryNotificationsWithCompletion:^(NSError* error) {
        if (weakSelf.isViewLoaded) { [sender endRefreshing]; }
    }];
}

- (IBAction)clearButtonTriggered:(UIBarButtonItem*)sender
{
    __weak TMWNotificationsController* weakSelf = self;
    NSArray* notifications = [TMWStore sharedInstance].notifications.copy;
    
    [TMWAPIService deleteNotifications:notifications completion:^(NSError* error) {
        if (error) { return; }  // TODO: Handle error
        [RelayrCloud logMessage:TMWLogging_Delete_Notifications(@([TMWStore sharedInstance].notifications.count)) onBehalfOfUser:[TMWStore sharedInstance].relayrUser];
        [[TMWStore sharedInstance].notifications removeObjectsInArray:notifications];
        
        TMWNotificationsController* strongSelf = weakSelf;
        if (!strongSelf) { return; }
        [strongSelf.tableView reloadData];
    }];
}

#pragma mark Navigation functionality

- (IBAction)unwindToNotificationsList:(UIStoryboardSegue*)segue
{
}

@end
