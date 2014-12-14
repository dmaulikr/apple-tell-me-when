#import "TMWRulesSummaryController.h"       // Header

#import "TMWStore.h"                        // TMW (Model)
#import "TMWRule.h"                         // TMW (Model)
#import "TMWAPIService.h"                   // TMW (Model)
#import "TMWStoryboardIDs.h"                // TMW (ViewControllers)
#import "TMWSegueUnwindingRules.h"          // TMW (ViewControllers/Segues)
#import "TMWRuleTransmittersController.h"   // TMW (ViewControllers/Rules)

@interface TMWRulesSummaryController () <TMWSegueUnwindingRules>
- (IBAction)activationToogled:(UISwitch *)sender;
@property (strong, nonatomic) IBOutlet UILabel* ruleNameLabel;
@property (strong, nonatomic) IBOutlet UILabel* transmitterNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView* measurementImageView;
@property (strong, nonatomic) IBOutlet UILabel* measurementNameLabel;
@property (strong, nonatomic) IBOutlet UILabel* conditionLabel;
@end

@implementation TMWRulesSummaryController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _ruleNameLabel.text = _rule.name;
    _transmitterNameLabel.text = _rule.transmitter.name;
    _measurementImageView.image = _rule.icon;
    _measurementNameLabel.text = _rule.type;
    _conditionLabel.text = [NSString stringWithFormat:@"%@ %@", _rule.type, _rule.thresholdDescription];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:TMWStoryboardIDs_SegueFromRulesSummaryToTransm])
    {
        TMWRuleTransmittersController* cntrll = (TMWRuleTransmittersController*)segue.destinationViewController;
        cntrll.rule = _rule;
    }
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSUInteger const row = indexPath.row;
    if (row == 1)
    {
        
    }
    else if (row == 2)
    {
        [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesSummaryToTransm sender:self];
    }
    else if (row == 3)
    {
        
    }
    else if (row == 4)
    {
        
    }
}

#pragma mark - Private functionality

- (IBAction)activationToogled:(UISwitch*)sender
{
    TMWRule* rule = _rule;
    rule.active = sender.on;
    [TMWAPIService setRule:_rule completion:^(NSError* error) {
        if (!error) { return; }
        rule.active = !sender.on;
        [sender setOn:rule.active animated:YES];
    }];
}

#pragma mark Navigation functionality

- (void)unwindFromRuleTransmitters:(UIStoryboardSegue*)segue
{
    
}

- (void)unwindFromRuleMeasurements:(UIStoryboardSegue*)segue
{
    
}

- (void)unwindFromRuleThreshold:(UIStoryboardSegue*)segue
{
    
}

- (void)unwindFromRuleName:(UIStoryboardSegue*)segue
{
    
}

@end
