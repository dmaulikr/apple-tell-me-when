#import "TMWNotificationsListController.h"  // Header

#import "TMWStore.h"            // TMW (Model)
#import "TMWAPIService.h"       // TMW (Model)

#import "TMWStoryboardIDs.h"    // TMW (ViewControllers)
#import "TMWSegueEmbedViewInTableBacgroundkView.h"
#import "TMWUIProperties.h"     // TMW (Views)

#pragma mark Definitions

#define TMWNotifListCntrll_RefreshString    @"Querying notifications..."

@interface TMWNotificationsListController ()
@end

@implementation TMWNotificationsListController

#pragma mark - Public API

//- (IBAction)unwindToList:(UIStoryboardSegue*)segue { }

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

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
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
            [store.notifications addObjectsFromArray:notifications];
        }
        
        [sender endRefreshing];
        [tableView reloadData];
    }];
}
@end
