#import "TMWRulesController.h"              // Header

#import "TMWStore.h"                        // TMW (Model)
#import "TMWAPIService.h"                   // TMW (Model)
#import "TMWRule.h"                         // TMW (Model)
#import "TMWRuleCondition.h"                // TMW (Model)

#import "TMWStoryboardIDs.h"                // TMW (ViewControllers/Segues)
#import "TMWSegueUnwindingRules.h"          // TMW (ViewControllers/Segues)
#import "TMWRulesSummaryController.h"       // TMW (ViewControllers/Rules)
#import "TMWRuleTransmittersController.h"   // TMW (ViewControllers/Rules)
#import "TMWUIProperties.h"                 // TMW (Views)
#import "TMWRulesCellView.h"                // TMW (Views/Rules)

#pragma mark Definitions

#define TMWRulesCntrl_RefreshString         @"Querying rules..."

@interface TMWRulesController () <TMWSegueUnwindingRules>
@property (strong, nonatomic) IBOutlet UIBarButtonItem* createButton;
- (IBAction)createRule:(UIBarButtonItem*)sender;
- (IBAction)ruleToogle:(UISwitch *)sender;
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
    [super viewDidLoad];
    
    UIRefreshControl* control = (self.refreshControl) ? self.refreshControl : [[UIRefreshControl alloc] init];
    control.tintColor = [UIColor whiteColor];
    [control addTarget:self action:@selector(refreshRequest:) forControlEvents:UIControlEventValueChanged];
    control.attributedTitle = [[NSAttributedString alloc] initWithString:TMWRulesCntrl_RefreshString attributes:@{
        NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName : [UIFont fontWithName:TMWFont_NewJuneBook size:14]
    }];
    self.refreshControl = control;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self queryRules];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:TMWStoryboardIDs_SegueFromRulesToSummary])
    {
        ((TMWRulesSummaryController*)segue.destinationViewController).rule = [TMWStore sharedInstance].rules[self.tableView.indexPathForSelectedRow.row];
    }
    else if ([segue.identifier isEqualToString:TMWStoryboardIDs_SegueFromRulesToNew])
    {
        ((TMWRuleTransmittersController*)segue.destinationViewController).rule = [[TMWRule alloc] initWithUserID:[TMWStore sharedInstance].relayrUser.uid];
    }
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    if (![TMWStore sharedInstance].relayrUser.transmitters.count)
    {
        [self.navigationItem setRightBarButtonItems:nil animated:YES];
        [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesToOnboarding sender:self];
        return 0;
    }
    else if (![TMWStore sharedInstance].rules.count)
    {
        [self.navigationItem setRightBarButtonItems:@[_createButton] animated:YES];
        [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesToNoRules sender:self];
        return 0;
    }
    else
    {
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

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) { return; }
 
    TMWStore* store = [TMWStore sharedInstance];
    TMWRule* ruleToDelete = store.rules[indexPath.row];
    __weak UITableView* weakTableView = tableView;
    
    [TMWAPIService deleteRule:ruleToDelete completion:^(NSError* error) {
        if (error) { return [weakTableView setEditing:NO animated:YES]; }
        
        [TMWRule ruleForID:ruleToDelete.uid withinRulesArray:store.rules];
        [store.rules removeObject:ruleToDelete];
        
        if (!store.rules.count) {
            [weakTableView reloadData];
        } else {
            [weakTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:TMWCntrl_RowDeletionAnimation];
        }
    }];
}

#pragma mark UITableViewDelegate methods

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesToSummary sender:self];
}

#pragma mark - Private functionality

- (void)refreshRequest:(UIRefreshControl*)sender
{
    RelayrUser* user = [TMWStore sharedInstance].relayrUser;
    __weak UITableView* weakTableView = self.tableView;
    
    // If there are no transmitters, when it refreshes it looks for newly added transmitters.
    if (!user.transmitters.count)
    {
        return [user queryCloudForIoTs:^(NSError* error) {
            [sender endRefreshing];
            if (error || !user.transmitters.count) { return; } // TODO: Show text to user...
            [weakTableView reloadData];
        }];
    }
    
    // If there are transmitters, look for rules.
    [TMWAPIService requestRulesForUserID:[TMWStore sharedInstance].relayrUser.uid completion:^(NSError* error, NSArray* rules) {
        [sender endRefreshing];
        if (error) { return; }  // TODO:
        
        TMWStore* store = [TMWStore sharedInstance];
        
        NSArray* indexPathsToAdd;
        NSArray* indexPathsToRemove;
        NSArray* indexPathsToReplace;
        BOOL const isThereChanges = [TMWRule synchronizeStoredRules:store.rules withNewlyArrivedRules:rules.mutableCopy resultingInCellsIndexPathsToAdd:&indexPathsToAdd cellsIndexPathsToRemove:&indexPathsToRemove cellsIndexPathsToReload:&indexPathsToReplace];
        
        if (!isThereChanges) { return; }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TMWCntrl_EndRefreshingDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UITableView* tableView = weakTableView; if (!tableView) { return; }
            
            NSUInteger const ruleNumbers = store.rules.count;
            if ((ruleNumbers>tableView.numberOfSections) || (ruleNumbers<tableView.numberOfSections)) { return [tableView reloadData]; }
            
            [tableView beginUpdates];
            if (indexPathsToReplace.count) { [self.tableView reloadRowsAtIndexPaths:indexPathsToReplace withRowAnimation:UITableViewRowAnimationNone]; }
            if (indexPathsToRemove.count) { [self.tableView deleteRowsAtIndexPaths:indexPathsToRemove withRowAnimation:TMWCntrl_RowDeletionAnimation]; }
            if (indexPathsToAdd.count) { [self.tableView insertRowsAtIndexPaths:indexPathsToAdd withRowAnimation:TMWCntrl_RowAdditionAnimation]; }
            [tableView endUpdates];
        });
    }];
}

- (IBAction)ruleToogle:(UISwitch*)sender
{
    TMWRulesCellView* cellView = (TMWRulesCellView*)[TMWTableViewCell findCellOfChildView:sender];
    if (!cellView) { return; }
    
    TMWRule* rule = [TMWStore sharedInstance].rules[[self.tableView indexPathForCell:cellView].row];
    if (!rule) { return; }
    
    rule.active = sender.on;
    [TMWAPIService setRule:rule completion:^(NSError* error) {
        if (!error) { return; }
        rule.active = !sender.on;
        [sender setOn:rule.active animated:YES];
    }];
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

#pragma mark Navigation functionality

- (IBAction)createRule:(UIBarButtonItem*)sender
{
    [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesToNew sender:self];
}

- (IBAction)unwindFromRuleTransmitters:(UIStoryboardSegue*)segue
{
    // Unwinding from Rules creation.
}

- (IBAction)unwindFromRuleName:(UIStoryboardSegue*)segue
{
    // Unwinding after successful creation
}

- (IBAction)unwindFromRuleSummary:(UIStoryboardSegue*)segue
{
    // Unwinding from Rules summary
}

@end
