#import "TMWRulesController.h"      // Header
#import "TMWStore.h"                // TMW (Model)
#import "TMWAPIService.h"           // TMW (Model)
#import "TMWRule.h"                 // TMW (Model)
#import "TMWRuleCondition.h"        // TMW (Model)
#import "TMWStoryboardIDs.h"        // TMW (ViewControllers/Segues)
#import "TMWRulesCellView.h"        // TMW (Views/Rules)

#pragma mark Definitions

#define TMWRulesCntrll_RetryDelay      1.0

@interface TMWRulesController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (readonly,nonatomic) NSArray* rules;
@end

@implementation TMWRulesController

#pragma mark - Public API

- (IBAction)createRule:(id)sender
{
    NSLog(@"Start creating a rule.");
}

- (void)viewDidLoad
{
    [self showChild];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rules.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    TMWRule* rule = _rules[indexPath.row];
    
    TMWRulesCellView* cell = [tableView dequeueReusableCellWithIdentifier:@"TMWRulesCellView"];
    cell.ruleName.text = rule.name.uppercaseString;
    cell.ruleDescription.text = [NSString stringWithFormat:@"%@ %@", rule.type, rule.thresholdDescription];
    return cell;
}

#pragma mark - Private functionality

- (void)showChild
{
    RelayrUser* user = [TMWStore sharedInstance].relayrUser;
    NSSet* transmitters = user.transmitters;
    
    if (!transmitters.count)
    {
        [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesToOnboarding sender:self];
        if (transmitters) { return; }
        
        __weak TMWRulesController* weakSelf = self;
        return [user queryCloudForIoTs:^(NSError* error) {
            TMWRulesController* strongSelf = weakSelf; if (!strongSelf) { return; }
            if (!error) { [strongSelf showChild]; }
        }];
    }
    
    [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesToNoRules sender:self];
    
    __weak TMWRulesController* weakSelf = self;
    [TMWAPIService requestRulesForUserID:user.uid completion:^(NSError* error, NSArray* rules) {
        if (error || !rules.count) { return; }  // TODO: Show error
        [weakSelf showRules:rules];
    }];
}

- (void)showRules:(NSArray*)rules
{
    if (!rules.count) { [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesToNoRules sender:self]; }
    
    _rules = rules;
    [self removeFromParentViewController];
    _tableView.hidden = NO;
    [_tableView reloadData];
}

- (void)removeChildControllers
{
    NSArray* children = [NSArray arrayWithArray:self.childViewControllers];
    for (UIViewController* cntrll in children)
    {
        [cntrll willMoveToParentViewController:nil];
        if ([cntrll isViewLoaded]) { [cntrll.view removeFromSuperview]; }
        [cntrll removeFromParentViewController];
    }
}

@end
