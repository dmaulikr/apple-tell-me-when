#import "TMWRuleMeasurementsController.h"   // Header

#import "TMWStore.h"                        // TMW (Model)
#import "TMWRule.h"                         // TMW (Model)
#import "TMWRuleCondition.h"                // TMW (Model)
#import "TMWLogging.h"                      // TMW (Model)
#import <Relayr/RelayrCloud.h>              // Relayr.framework
#import "TMWStoryboardIDs.h"                // TMW (ViewControllers/Segues)
#import "TMWSegueUnwindingRules.h"          // TMW (ViewControllers/Segues)
#import "TMWRuleThresholdController.h"      // TMW (ViewControllers/Rules)

@interface TMWRuleMeasurementsController () <TMWSegueUnwindingRules>
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
        RelayrDevice* device = [_rule.transmitter devicesWithInputMeaning:meaning].anyObject;
        
        if (!_needsServerModification)
        {
            [RelayrCloud logMessage:TMWLogging_Creation_Threshold onBehalfOfUser:[TMWStore sharedInstance].relayrUser];
            TMWRule* ruleCopied = _rule.copy;
            ruleCopied.condition = [[TMWRuleCondition alloc] initWithMeaning:meaning];
            ruleCopied.deviceID = device.uid;
            cntrll.rule = ruleCopied;
        }
        else
        {
            [RelayrCloud logMessage:TMWLogging_Edit_Threshold onBehalfOfUser:[TMWStore sharedInstance].relayrUser];
            TMWRule* tmpRule = _rule.copy;
            tmpRule.condition.meaning = meaning;
            tmpRule.condition.operation = [TMWRuleCondition lessThanOperator];
            tmpRule.condition.valueConverted = [TMWRuleCondition defaultValueForMeaning:tmpRule.condition.meaning];
            tmpRule.deviceID = device.uid;
            
            cntrll.tmpRule = tmpRule;
            cntrll.rule = _rule;
        }
        
        cntrll.needsServerModification = _needsServerModification;
    }
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (!_needsServerModification || ![_rule.condition.meaning isEqualToString:[self meaningFromSelectedCell]])
    {
        [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesMeasuToThresh sender:self];
    }
    else
    {
        [RelayrCloud logMessage:TMWLogging_Edit_Finished onBehalfOfUser:[TMWStore sharedInstance].relayrUser];
        [self performSegueWithIdentifier:TMWStoryboardIDs_UnwindFromRuleMeasure sender:self];
    }
}

#pragma mark - Private functionality

- (IBAction)backButtonTapped:(id)sender
{
    if (_needsServerModification) { [RelayrCloud logMessage:TMWLogging_Edit_Cancelled onBehalfOfUser:[TMWStore sharedInstance].relayrUser]; }
    [self performSegueWithIdentifier:TMWStoryboardIDs_UnwindFromRuleMeasure sender:self];
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

- (IBAction)unwindFromRuleThreshold:(UIStoryboardSegue*)segue
{
    if (!_needsServerModification)
    {
        [RelayrCloud logMessage:TMWLogging_Creation_Sensor onBehalfOfUser:[TMWStore sharedInstance].relayrUser];
    }
    else
    {
        [RelayrCloud logMessage:TMWLogging_Edit_Sensor onBehalfOfUser:[TMWStore sharedInstance].relayrUser];
    }
}

@end
