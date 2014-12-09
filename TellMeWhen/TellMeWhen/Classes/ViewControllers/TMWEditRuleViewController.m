#import "TMWEditRuleViewController.h" // Headers
#import "TMWTransmitterViewController.h"
#import "TMWMeasurementViewController.h"
#import "TMWThresholdDetailsViewController.h"
#import "TMWRuleNameViewController.h"
#import "TMWRulesViewController.h"
#import "TMWRule.h"
#import "TMWManager.h"
#import "TMWAPIService.h"


@interface TMWEditRuleViewController ()

@property (strong, nonatomic) IBOutlet UILabel *ruleNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *transmitterNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *ruleTypeIconImageView;
@property (strong, nonatomic) IBOutlet UILabel *ruleTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *thresholdOperatorAndValueLabel;
@property (strong, nonatomic) IBOutlet UISwitch *activateRuleSwitch;

- (IBAction)editRuleName:(id)sender;
- (IBAction)editRuleTransmitter:(id)sender;
- (IBAction)editRuleType:(id)sender;
- (IBAction)editRuleThreshold:(id)sender;
- (IBAction)doneEditingRule:(id)sender;
- (IBAction)toggleRuleEnable:(UISwitch *)sender;
- (IBAction)unwindToEditRuleView:(UIStoryboardSegue *)segue;

@end


@implementation TMWEditRuleViewController


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setUpRuleValues];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowTransmittersViewForEditing"]) {
        TMWTransmitterViewController *transmitterViewController = segue.destinationViewController;
        transmitterViewController.editingRule = YES;
    }
    if ([segue.identifier isEqualToString:@"ShowMeasurementsViewForEditing"]) {
        TMWMeasurementViewController *measurementViewController = segue.destinationViewController;
        // TODO: This might need to be a copy of the rule. Test cancelling editing a rule.
        measurementViewController.rule = _rule;
        measurementViewController.editingRule = YES;
    }
    if ([segue.identifier isEqualToString:@"ShowThresholdViewForEditing"]) {
        TMWThresholdDetailsViewController *thresholdViewController = segue.destinationViewController;
        thresholdViewController.rule = _rule;
        thresholdViewController.editingRule = YES;
    }
    if ([segue.identifier isEqualToString:@"ShowNameViewForEditing"]) {
        TMWRuleNameViewController *nameViewController = segue.destinationViewController;
        nameViewController.editingRule = YES;
        nameViewController.rule = _rule;
    } if ([segue.identifier isEqualToString:@"UnwindToRulesView"]) {
        // TODO: Add a copy of the rule if required.
    }
}

- (IBAction)unwindToEditRuleView:(UIStoryboardSegue *)segue {
    // Stub implementation to keep the compiler happy
}


#pragma mark - IBActions

- (IBAction)editRuleName:(id)sender {
    [self performSegueWithIdentifier:@"ShowNameViewForEditing" sender:self];
}

- (IBAction)editRuleTransmitter:(id)sender {
    [self performSegueWithIdentifier:@"ShowTransmittersViewForEditing" sender:self];
}

- (IBAction)editRuleType:(id)sender {
    [self performSegueWithIdentifier:@"ShowMeasurementsViewForEditing" sender:self];
}

- (IBAction)editRuleThreshold:(id)sender {
    [self performSegueWithIdentifier:@"ShowThresholdViewForEditing" sender:self];
}

- (IBAction)doneEditingRule:(id)sender {
    [self performSegueWithIdentifier:@"UnwindToRulesView" sender:self];
}

- (IBAction)toggleRuleEnable:(UISwitch *)sender {
    if ([sender isOn]) {
        _rule.active = YES;
    } else {
        _rule.active = NO;
    }
    [self patchRule];
}


#pragma mark - Private Methods

- (void)setUpRuleValues { // TODO: Move this to the model code somewhere?
    _ruleNameLabel.text = _rule.name.uppercaseString;
    _transmitterNameLabel.text = _rule.transmitter.name;
    _ruleTypeLabel.text = _rule.type;
    _ruleTypeIconImageView.image = _rule.typeImage;
    _thresholdOperatorAndValueLabel.text = _rule.thresholdDescription;
    if (_rule.active == YES) {
        _activateRuleSwitch.on = YES;
    } else {
        _activateRuleSwitch.on = NO;
    }
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
