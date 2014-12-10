#import "TMWNotificationsViewController.h" // Headers
#import "TMWNotification.h"
#import "TMWNotificationTableViewCell.h"
#import "TMWStore.h"
#import "TMWAPIService.h"
#import "TMWNotificationDetailViewController.h"
#import "TMWActions.h"                          // TMW (ViewControllers/Models)

#pragma mark - Constants

static NSString *const kNotificationsTableViewCellReuseIdentifier = @"NotificationsTableViewCell";

@interface TMWNotificationsViewController ()
@property (strong, nonatomic) IBOutlet UIView *noNotificationsView;
@property (strong, nonatomic) IBOutlet UITableView *notificationsTableView;
@property (strong, nonatomic) NSArray *notificationsTableViewDataSource;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *clearButton;
- (IBAction)signOutUser:(id)sender;
- (IBAction)clearNotifications:(id)sender;
@end


@implementation TMWNotificationsViewController

#pragma mark - Public API

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TMWAPIService requestNotificationsForUserID:[TMWStore sharedInstance].relayrUser.uid completion:^(NSError *error, NSArray *notifications) {
        if (!error) {
            _notificationsTableViewDataSource = notifications;
             NSLog(@"Received %lu notofications", (unsigned long)notifications.count);
        } else {
            NSLog(@"%@", error.description);
        }
        [self showOrHideTableView];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowNotificationsDetailView"]) {
        TMWNotificationDetailViewController *notificationDetailViewController = segue.destinationViewController;
        notificationDetailViewController.notification = sender;
    }
}


#pragma mark - Table View Data Source Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMWNotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNotificationsTableViewCellReuseIdentifier];
    TMWNotification *notification = [_notificationsTableViewDataSource objectAtIndex:indexPath.row];
    for (TMWRule *rule in [TMWStore sharedInstance].rules) {
        if ([notification.ruleID isEqualToString:rule.uid]) {
            cell.notificationNameLabel.text = rule.name.uppercaseString;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.calendar = [NSCalendar currentCalendar];
            dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
            timeFormatter.calendar = [NSCalendar currentCalendar];
            timeFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
            [timeFormatter setDateFormat:@"HH:mm:ss"];
            cell.notificationDateLabel.text = [dateFormatter stringFromDate:notification.timestamp];
            cell.notificationTimeLabel.text = [timeFormatter stringFromDate:notification.timestamp];
            cell.ruleDescriptionLabel.text = [NSString stringWithFormat:@"%@ %@", rule.type, rule.thresholdDescription];
        }
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _notificationsTableViewDataSource.count;
}


#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TMWNotification *notification = [_notificationsTableViewDataSource objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ShowNotificationsDetailView" sender:notification];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath: (NSIndexPath *)indexPath {
    [self deleteNotificationFromTableViewDataSource:[_notificationsTableViewDataSource objectAtIndex:indexPath.row]];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self showOrHideTableView];
}


#pragma mark - IBActions

- (IBAction)signOutUser:(id)sender {
    id <TMWActions> target = [self targetForAction:@selector(signoutFromSender:) withSender:self];
    [target signoutFromSender:self];
}

- (IBAction)clearNotifications:(id)sender {
    NSLog(@"Clear notifications");
    [TMWAPIService deleteNotifications:_notificationsTableViewDataSource completion:^(NSError *error) {
        if (!error) {
            NSLog(@"Notifications deleted sucessfully");
        } else {
            NSLog(@"%@", error);
        }
    }];
    _notificationsTableViewDataSource = @[];
    [self showOrHideTableView];
    // TODO: Remove any stored notifications
}


#pragma mark - Private Methods

- (void)deleteNotificationFromTableViewDataSource:(TMWNotification *)notification {
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:_notificationsTableViewDataSource];
    [newArray removeObject:notification];
    _notificationsTableViewDataSource = (NSArray *)newArray;
    // TODO: Add model code for the notifications.
}

- (void)showOrHideTableView {
    if ([_notificationsTableViewDataSource count]) {
        _notificationsTableView.hidden = NO;
        _noNotificationsView.hidden = YES;
        _clearButton.enabled = YES;
        [_notificationsTableView reloadData];
    } else {
        _noNotificationsView.hidden = NO;
        _notificationsTableView.hidden = YES;
        _clearButton.enabled = NO;
    }
}

@end
