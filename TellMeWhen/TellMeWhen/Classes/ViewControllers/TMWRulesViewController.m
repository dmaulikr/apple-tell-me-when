#import "TMWRulesViewController.h"      // Headers

#import "TMWRule.h"
#import "TMWRulesTableViewCell.h"
#import "TMWManager.h"
#import "TMWEditRuleViewController.h"
#import "TMWAPIService.h"
#import "TMWActions.h"                  // TMW (ViewControllers/Protocols)

#pragma mark - Constants

static NSString *const kRulesTableViewCellReuseIdentifier = @"RulesTableViewCell";


@interface TMWRulesViewController ()
@property (strong, nonatomic) NSArray *rulesTableViewDataSource;
@property (strong, nonatomic) IBOutlet UITableView *rulesTableView;
@property (strong, nonatomic) IBOutlet UIView *noRulesView;
- (IBAction)createRule:(UIButton *)sender;
- (IBAction)signOutUser:(id)sender;
- (IBAction)unwindToRulesView:(UIStoryboardSegue *)segue;
@end


@implementation TMWRulesViewController

#pragma mark - View Controller Lifecycle Methods

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TMWAPIService requestRulesForUserID:[TMWManager sharedInstance].relayrUser.uid completion:^(NSError *error, NSArray *rules) {
        if (!error) {
            _rulesTableViewDataSource = rules;
        } else {
            NSLog(@"%@", error.description);
        }
        // TODO: Add activity indicator to the UI
        [TMWManager sharedInstance].rules = (NSMutableArray *)_rulesTableViewDataSource;
        [self showOrHideTableView];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowEditRuleView"]) {
        TMWEditRuleViewController *editRuleViewController = segue.destinationViewController;
        editRuleViewController.rule = sender;
    }
}

- (IBAction)unwindToRulesView:(UIStoryboardSegue *)segue {
    // Stub implementation to keep the compiler happy
}


#pragma mark - Table View Data Source Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMWRulesTableViewCell *cell = (TMWRulesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kRulesTableViewCellReuseIdentifier];
    TMWRule *rule = [_rulesTableViewDataSource objectAtIndex:indexPath.row];
    cell.ruleName.text = rule.name.uppercaseString;
    [cell setRuleDescriptionTextForRule:rule];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _rulesTableViewDataSource.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath: (NSIndexPath *)indexPath {
    [TMWAPIService deleteRule:[_rulesTableViewDataSource objectAtIndex:indexPath.row] completion:^(NSError *error) {
        if (!error) {
            NSLog(@"Rule deleted successfully");
        } else {
            NSLog(@"%@", error.description);
        }
    }];
    [self deleteRuleFromTableViewDataSource:[_rulesTableViewDataSource objectAtIndex:indexPath.row]];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self showOrHideTableView];
}


#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TMWRule *rule = [_rulesTableViewDataSource objectAtIndex:indexPath.row];
    [TMWManager sharedInstance].ruleBeingEdited = rule;
    [self performSegueWithIdentifier:@"ShowEditRuleView" sender:rule];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - IBActions

- (IBAction)createRule:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ShowTransmittersView" sender:self];
}

- (IBAction)signOutUser:(id)sender
{
    id <TMWActions> target = [self targetForAction:@selector(signoutFromSender:) withSender:self];
    [target signoutFromSender:self];
}


#pragma mark - Private Methods

- (void)deleteRuleFromTableViewDataSource:(TMWRule *)rule {
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:_rulesTableViewDataSource];
    [newArray removeObject:rule];
    _rulesTableViewDataSource = (NSArray *)newArray;
    [TMWManager sharedInstance].rules = newArray;
}

- (void)showOrHideTableView {
    if (_rulesTableViewDataSource.count) {
        _rulesTableView.hidden = NO;
        _noRulesView.hidden = YES;
        [_rulesTableView reloadData];
    } else {
        _noRulesView.hidden = NO;
        _rulesTableView.hidden = YES;
    }
}

@end
