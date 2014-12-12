#import "TMWRulesController.h"      // Header

#import "TMWStore.h"                // TMW (Model)
#import "TMWAPIService.h"           // TMW (Model)
#import "TMWRule.h"                 // TMW (Model)
#import "TMWRuleCondition.h"        // TMW (Model)

#import "TMWStoryboardIDs.h"        // TMW (ViewControllers/Segues)
#import "TMWUIProperties.h"         // TMW (Views)
#import "TMWRulesCellView.h"        // TMW (Views/Rules)

#pragma mark Definitions

#define TMWRulesCntrl_RefreshString         @"Querying rules..."
#define TMWRulesCntrl_UpperLineColor        [UIColor colorWithWhite:0.65 alpha:0.15]
#define TMWRulesCntrl_BottomLineColor       [UIColor colorWithWhite:0.2 alpha:0.65]
#define TMWRulesCntrl_LineHeight            1
#define TMWRulesCntrl_EndRefreshingDelay    0.37

#define TMWRulesCntrl_RowDeletionAnimation  UITableViewRowAnimationLeft
#define TMWRulesCntrl_RowAdditionAnimation  UITableViewRowAnimationLeft

@interface TMWRulesController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem* createButton;
- (IBAction)createRule:(UIBarButtonItem*)sender;
@end

@implementation TMWRulesController
{
    UIColor* _upperLineColor;
    UIColor* _bottomLineColor;
    CGFloat _lineHeight;
}

#pragma mark - Public API

- (void)queryRules
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
    [cell setUpperLineWithColor:_upperLineColor height:_lineHeight];
    [cell setBottomLineWithColor:_bottomLineColor height:_lineHeight];
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
        
        if (store.rules.count == 0) {
            [weakTableView reloadData];
        } else {
            [weakTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:TMWRulesCntrl_RowDeletionAnimation];
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
    // TODO:
}

#pragma mark - Private functionality

- (void)refreshRequest:(UIRefreshControl*)sender
{
    __weak UITableView* weakTableView = self.tableView;
    [TMWAPIService requestRulesForUserID:[TMWStore sharedInstance].relayrUser.uid completion:^(NSError* error, NSArray* rules) {
        if (error) { return [sender endRefreshing]; }  // TODO:
        
        TMWStore* store = [TMWStore sharedInstance];
        
        NSArray* indexPathsToAdd;
        NSArray* indexPathsToRemove;
        NSArray* indexPathsToReplace;
        BOOL const isThereChanges = [TMWRule synchronizeStoredRules:store.rules withNewlyArrivedRules:rules.mutableCopy resultingInCellsIndexPathsToAdd:&indexPathsToAdd cellsIndexPathsToRemove:&indexPathsToRemove cellsIndexPathsToReload:&indexPathsToReplace];
        
        [sender endRefreshing];
        if (!isThereChanges) { return; }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TMWRulesCntrl_EndRefreshingDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UITableView* tableView = weakTableView; if (!tableView) { return; }
            
            NSUInteger const ruleNumbers = store.rules.count;
            if ((ruleNumbers>tableView.numberOfSections) || (ruleNumbers<tableView.numberOfSections)) { return [tableView reloadData]; }
            
            [tableView beginUpdates];
            if (indexPathsToReplace.count) { [self.tableView reloadRowsAtIndexPaths:indexPathsToReplace withRowAnimation:UITableViewRowAnimationNone]; }
            if (indexPathsToRemove.count) { [self.tableView deleteRowsAtIndexPaths:indexPathsToRemove withRowAnimation:TMWRulesCntrl_RowDeletionAnimation]; }
            if (indexPathsToAdd.count) { [self.tableView insertRowsAtIndexPaths:indexPathsToAdd withRowAnimation:TMWRulesCntrl_RowAdditionAnimation]; }
            [tableView endUpdates];
        });
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
