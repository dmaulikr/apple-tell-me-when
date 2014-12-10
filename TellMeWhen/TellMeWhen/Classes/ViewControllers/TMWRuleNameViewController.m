#import "TMWRuleNameViewController.h" // Headers
#import "TMWStore.h"
#import "TMWEditRuleViewController.h"
#import "TMWRule.h"
#import "TMWAPIService.h"


@interface TMWRuleNameViewController ()

@property (strong, nonatomic) IBOutlet UITextField *ruleNameTextField;

- (IBAction)doneButtonPressed:(id)sender;

@end


@implementation TMWRuleNameViewController


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isEditingRule) {
        _ruleNameTextField.text = _rule.name.uppercaseString;
    } else {
        _rule.name = _ruleNameTextField.text; // Set the default value
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_ruleNameTextField becomeFirstResponder]; // Show the keyboard after the view has appeared
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"UnwindToEditRuleView"]) {
        TMWEditRuleViewController *editRuleViewController = segue.destinationViewController;
        TMWRule *rule = (TMWRule *)sender;
        editRuleViewController.rule.name = rule.name;
    }
}


#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (self.isEditingRule) {
        [self performSegueWithIdentifier:@"UnwindToEditRuleView" sender:_rule];
    } else {
        [self performSegueWithIdentifier:@"UnwindToRulesView" sender:self];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _rule.name = _ruleNameTextField.text;
    if (!self.isEditingRule) {
        [self registerNewRule];
    } else {
        [self patchRule];
    }
}


#pragma mark - IBActions

- (IBAction)doneButtonPressed:(id)sender {
    [self textFieldShouldReturn:_ruleNameTextField];
}


#pragma mark - Private Methods

- (void)registerNewRule {
    _rule.notifications = [_rule setupNotificationsWithDeviceToken:[TMWStore sharedInstance].deviceToken];
    [TMWAPIService registerRule:_rule completion:^(NSError *error) {
        if (!error) {
            NSLog(@"Created rule with id: %@", _rule.uid);
        } else {
            NSLog(@"Error creating rule");
        }
    }];
}

- (void)patchRule {
    [TMWAPIService setRule:_rule completion:^(NSError *error) {
        if (!error) {
            NSLog(@"Patched rule");
        } else {
            NSLog(@"%@", error);
        }
    }];
}

@end
