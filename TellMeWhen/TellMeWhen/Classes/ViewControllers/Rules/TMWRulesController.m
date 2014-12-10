#import "TMWRulesController.h"      // Header
#import "TMWStore.h"                // TMW (Model)
#import "TMWAPIService.h"           // TMW (Model)
#import "TMWStoryboardIDs.h"        // TMW (ViewControllers/Segues)

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
    [self childChoser];
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
    return nil;
}

#pragma mark - Private functionality

- (void)childChoser
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
            if (!error) { [strongSelf childChoser]; }
        }];
    }
    
    [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesToNoRules sender:self];
    
    [TMWAPIService requestRulesForUserID:user.uid completion:^(NSError* error, NSArray* rules) {
        if (error || !rules.count) { return; }  // TODO: Show error
    }];
}

- (void)showRules:(NSArray*)rules
{
    if (!rules.count) { [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesToNoRules sender:self]; }
    
    _rules = rules;
    [_tableView reloadData];
}

@end
