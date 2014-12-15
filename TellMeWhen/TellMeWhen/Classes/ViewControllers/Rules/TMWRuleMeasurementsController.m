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
        cntrll.rule = _rule;
        
        if (_needsServerModification)
        {
            cntrll.needsServerModification = _needsServerModification;
            cntrll.tmpMeaning = [self meaningFromSelectedCell];
        }
    }
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    return [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesMeasuToThresh sender:self];
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
