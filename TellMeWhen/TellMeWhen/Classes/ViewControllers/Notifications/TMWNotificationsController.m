#import "TMWNotificationsController.h"              // Header

#import "TMWStore.h"                                // TMW (Model)
#import "TMWAPIService.h"                           // TMW (Model)
#import "TMWNotification.h"                         // TMW (Model)

#import "TMWStoryboardIDs.h"                        // TMW (ViewControllers)
#import "TMWSegueEmbedViewInTableBacgroundkView.h"  // TMW (ViewControllers/Segue)
#import "TMWNotificationDetailsController.h"        // TMW (ViewControllers/Notifications)
#import "TMWUIProperties.h"                         // TMW (Views)
#import "TMWNotificationsCellView.h"                // TMW (Views/Notifications)

#pragma mark Definitions

#define TMWNotifListCntrll_RefreshString    @"Querying notifications..."
#define TMWRulesCntrl_UpperLineColor        [UIColor colorWithWhite:0.65 alpha:0.15]
#define TMWRulesCntrl_BottomLineColor       [UIColor colorWithWhite:0.2 alpha:0.65]
#define TMWRulesCntrl_LineHeight            1
#define TMWRulesCntrl_EndRefreshingDelay    0.36

#define TMWRulesCntrl_RowDeletionAnimation  UITableViewRowAnimationLeft
#define TMWRulesCntrl_RowAdditionAnimation  UITableViewRowAnimationLeft

@interface TMWNotificationsController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem* buttonClear;
- (IBAction)clearButtonTriggered:(UIBarButtonItem*)sender;
@end

@implementation TMWNotificationsController
{
    UIColor* _upperLineColor;
    UIColor* _bottomLineColor;
    CGFloat _lineHeight;
}

#pragma mark - Public API

- (void)queryNotifications
{
    [self refreshRequest:nil];
}

#pragma mark UIViewController methods

- (void)viewDidLoad
{
    _upperLineColor = TMWRulesCntrl_UpperLineColor;
    _bottomLineColor = TMWRulesCntrl_BottomLineColor;
    _lineHeight = TMWRulesCntrl_LineHeight;
    
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
    [super viewWillAppear:animated];
    [self queryNotifications];
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
    [cell setUpperLineWithColor:_upperLineColor height:_lineHeight];
    [cell setBottomLineWithColor:_bottomLineColor height:_lineHeight];
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
    
    if (!notifications.count)
    {
        [tableView reloadData];
    }
    else
    {
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:TMWRulesCntrl_RowDeletionAnimation];
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
    if (!notification) { return [cell setSelected:NO animated:YES]; }
    [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromNotifsToDetails sender:self];
}

#pragma mark - Private functionality

- (void)refreshRequest:(UIRefreshControl*)sender
{
    __weak UITableView* tableView = self.tableView;
    [TMWAPIService requestNotificationsForUserID:[TMWStore sharedInstance].relayrUser.uid completion:^(NSError* error, NSArray* notifications) {
        if (error || !notifications.count) { return [sender endRefreshing]; }  // TODO:
        
        [TMWAPIService deleteNotifications:notifications completion:^(NSError* error) {
            [sender endRefreshing];
            if (error) { return; }
            
            NSUInteger const numPreviousNotifications = [TMWStore sharedInstance].notifications.count;
            
            __autoreleasing NSArray* indexPathsToAdd;
            BOOL isThereChanges = [TMWNotification synchronizeStoredNotifications:[TMWStore sharedInstance].notifications withNewlyArrivedNotifications:notifications resultingInCellsIndexPathsToAdd:&indexPathsToAdd];
            if (!isThereChanges) { return; }
            
            if (!numPreviousNotifications) {
                [tableView reloadData];
            } else {
                [tableView insertRowsAtIndexPaths:indexPathsToAdd withRowAnimation:TMWRulesCntrl_RowAdditionAnimation];
            }
        }];
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
