#import "TMWRulesController.h"      // Header

#import "TMWStore.h"                // TMW (Model)
#import "TMWAPIService.h"           // TMW (Model)
#import "TMWRule.h"                 // TMW (Model)
#import "TMWRuleCondition.h"        // TMW (Model)

#import "TMWStoryboardIDs.h"        // TMW (ViewControllers/Segues)
#import "TMWUIProperties.h"         // TMW (Views)
#import "TMWRulesCellView.h"        // TMW (Views/Rules)

#pragma mark Definitions

#define TMWRulesController_RefreshString    @"Querying rules..."

@interface TMWRulesController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem* createButton;
- (IBAction)createRule:(UIBarButtonItem*)sender;
@end

@implementation TMWRulesController

#pragma mark - Public API

- (void)queryRules
{
    [self refreshRequest:nil];
}

#pragma mark UIViewController methods

- (void)viewDidLoad
{
    UIRefreshControl* control = (self.refreshControl) ? self.refreshControl : [[UIRefreshControl alloc] init];
    control.tintColor = [UIColor whiteColor];
    [control addTarget:self action:@selector(refreshRequest:) forControlEvents:UIControlEventValueChanged];
    control.attributedTitle = [[NSAttributedString alloc] initWithString:TMWRulesController_RefreshString attributes:@{
        NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName : [UIFont fontWithName:TMWFont_NewJuneBook size:14]
    }];
    self.refreshControl = control;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self queryRules];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    if (![TMWStore sharedInstance].relayrUser.transmitters.count)
    {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.navigationItem setRightBarButtonItems:nil animated:YES];
        [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesToOnboarding sender:self];
        return 0;
    }
    else if (![TMWStore sharedInstance].rules.count)
    {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.navigationItem setRightBarButtonItems:@[_createButton] animated:YES];
        [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesToNoRules sender:self];
        return 0;
    }
    else
    {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.navigationItem setRightBarButtonItems:@[_createButton] animated:YES];
        [self removeChildControllers];
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [TMWStore sharedInstance].rules.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    TMWRule* rule = [TMWStore sharedInstance].rules[indexPath.row];
    
    TMWRulesCellView* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TMWRulesCellView class])];
    cell.logo.image = rule.icon;
    cell.ruleName.text = rule.name.uppercaseString;
    cell.ruleDescription.text = [NSString stringWithFormat:@"%@ %@", rule.type, rule.thresholdDescription];
    cell.activator.on = rule.active;
    return cell;
}

#pragma mark - Private functionality

- (void)refreshRequest:(UIRefreshControl*)sender
{
    __weak UITableView* tableView = self.tableView;
    [TMWAPIService requestRulesForUserID:[TMWStore sharedInstance].relayrUser.uid completion:^(NSError* error, NSArray* rules) {
        if (error) { return [sender endRefreshing]; }  // TODO:
        
        if (rules.count)
        {
            TMWStore* store = [TMWStore sharedInstance];
            [TMWRule synchronizeStoredRules:store.rules withNewlyArrivedRules:rules];
        }
        
        [sender endRefreshing];
        [tableView reloadData];
    }];
}

- (IBAction)createRule:(UIBarButtonItem *)sender
{
    // TODO:
}

- (void)removeChildControllers
{
    NSArray* children = [NSArray arrayWithArray:self.childViewControllers];
    for (UIViewController* cntrll in children)
    {
        [cntrll willMoveToParentViewController:nil];
        if ([cntrll isViewLoaded]) { [cntrll.view removeFromSuperview]; }
        self.tableView.backgroundView = nil;
        [cntrll removeFromParentViewController];
    }
}

@end
