#import "TMWRuleMeasurementsController.h"   // Header

#import "TMWStore.h"                        // TMW (Model)
#import "TMWRule.h"                         // TMW (Model)
#import "TMWRuleCondition.h"                // TMW (Model)
#import "TMWStoryboardIDs.h"                // TMW (ViewControllers/Segues)
#import "TMWSegueUnwindingRules.h"          // TMW (ViewControllers/Segues)
#import "TMWRuleThresholdController.h"      // TMW (ViewControllers/Rules)

@interface TMWRuleMeasurementsController () <TMWSegueUnwindingRules>
@property (readonly,nonatomic) NSString* segueIdentifierForUnwind;
@end

@implementation TMWRuleMeasurementsController

#pragma mark - Public API

#pragma mark UIViewController methods

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:TMWStoryboardIDs_SegueFromRulesMeasuToThresh])
    {
        TMWRuleThresholdController* cntrll = (TMWRuleThresholdController*)segue.destinationViewController;
        NSString* meaning = [self meaningFromSelectedCell];
        RelayrDevice* device = [_rule.transmitter devicesWithInputMeaning:_rule.condition.meaning].firstObject;
        
        if (!_needsServerModification)
        {
            _rule.condition = [[TMWRuleCondition alloc] initWithMeaning:meaning];
            _rule.deviceID = device.uid;
        }
        else
        {
            TMWRule* tmpRule = _rule.copy;
            tmpRule.condition.meaning = meaning;
            tmpRule.condition.operation = [TMWRuleCondition lessThanOperator];
            tmpRule.condition.value = [TMWRuleCondition defaultValueForMeaning:tmpRule.condition.meaning];
            tmpRule.deviceID = device.uid;
        }
        
        cntrll.rule = _rule;
        cntrll.needsServerModification = _needsServerModification;
    }
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    return ([_rule.condition.meaning isEqualToString:[self meaningFromSelectedCell]])   ?
        [self performSegueWithIdentifier:self.segueIdentifierForUnwind sender:self]     :
        [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesMeasuToThresh sender:self];
}

#pragma mark - Private functionality

- (IBAction)backButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:self.segueIdentifierForUnwind sender:self];
}

- (NSString*)meaningFromSelectedCell
{
    NSInteger const row = [self.tableView indexPathForSelectedRow].row;
    return (row == 0) ? [TMWRuleCondition meaningForTemperature]
        :  (row == 1) ? [TMWRuleCondition meaningForHumidity]
        :  (row == 2) ? [TMWRuleCondition meaningForNoise]
        :  (row == 3) ? [TMWRuleCondition meaningForProximity]
        :  (row == 4) ? [TMWRuleCondition meaningForLight]
        :  nil;
}

#pragma mark Navigation functionality

- (NSString*)segueIdentifierForUnwind
{
    return (!_needsServerModification) ? TMWStoryboardIDs_UnwindFromRuleMeasurToTrans : TMWStoryboardIDs_UnwindFromRuleMeasurToSum;
}

- (IBAction)unwindFromRuleThreshold:(UIStoryboardSegue*)segue { }

@end
