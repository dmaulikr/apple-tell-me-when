#import "TMWRuleTransmittersController.h"   // Header

#import "TMWStore.h"                        // TMW (Model)
#import "TMWAPIService.h"                   // TMW (Model)
#import "TMWRule.h"                         // TMW (Model)
#import "TMWRuleCondition.h"                // TMW (Model)
#import "TMWLogging.h"                      // TMW (Model)
#import <Relayr/RelayrCloud.h>              // Relayr.framework
#import "TMWStoryboardIDs.h"                // TMW (ViewControllers/Segues)
#import "TMWSegueUnwindingRules.h"          // TMW (ViewControllers/Segues)
#import "TMWRuleMeasurementsController.h"   // TMW (ViewControllers/Rules)
#import "TMWUIProperties.h"                 // TMW (Views)
#import "TMWRuleTransmitterCellView.h"      // TMW (Views/Rules)

#pragma mark Definitions

#define TMWRuleTransCntrl_RefreshString     @"Querying user's IoTs..."

@interface TMWRuleTransmittersController () <TMWSegueUnwindingRules>
@end

@implementation TMWRuleTransmittersController
{
    NSArray* _transmitters;
}

#pragma mark - Public API

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIRefreshControl* control = (self.refreshControl) ? self.refreshControl : [[UIRefreshControl alloc] init];
    control.tintColor = [UIColor whiteColor];
    [control addTarget:self action:@selector(refreshRequest:) forControlEvents:UIControlEventValueChanged];
    control.attributedTitle = [[NSAttributedString alloc] initWithString:TMWRuleTransCntrl_RefreshString attributes:@{
        NSForegroundColorAttributeName : [UIColor whiteColor],
        NSFontAttributeName : [UIFont fontWithName:TMWFont_NewJuneBook size:14]
    }];
    self.refreshControl = control;
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:TMWStoryboardIDs_SegueFromRulesTransToMeasures])
    {
        [RelayrCloud logMessage:TMWLogging_Creation_Sensor onBehalfOfUser:[TMWStore sharedInstance].relayrUser];
        TMWRule* ruleCopied = _rule.copy;
        _rule.transmitterID = nil;
        ((TMWRuleMeasurementsController*)segue.destinationViewController).rule = ruleCopied;
    }
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    NSSet* transSet = [TMWStore sharedInstance].relayrUser.transmitters;
    if (!transSet.count)
    {
        [self performSegueWithIdentifier:TMWStoryboardIDs_UnwindFromRuleTransmitters sender:self];
        return 0;
    }
    else
    {
        _transmitters = transSet.allObjects;
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _transmitters.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    RelayrTransmitter* transmitter = (RelayrTransmitter*)_transmitters[indexPath.row];
    TMWRuleTransmitterCellView* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TMWRuleTransmitterCellView class])];
    cell.transmitterNameLabel.text = transmitter.name;
    cell.transmitterID = transmitter.uid;
    return cell;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    TMWRuleTransmitterCellView* cell = (TMWRuleTransmitterCellView*)[tableView cellForRowAtIndexPath:indexPath];
    RelayrTransmitter* transmitter = [[TMWStore sharedInstance].relayrUser transmitterWithID:cell.transmitterID];
    if (!transmitter) { return [self performSegueWithIdentifier:TMWStoryboardIDs_UnwindFromRuleTransmitters sender:self]; }
    
    if (!_needsServerModification)
    {
        _rule.transmitterID = transmitter.uid;
        return [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesTransToMeasures sender:self];
    }
    else
    {
        [RelayrCloud logMessage:TMWLogging_Edit_Finished onBehalfOfUser:[TMWStore sharedInstance].relayrUser];
        
        if ([transmitter.uid isEqualToString:_rule.transmitterID])
        {
            return [self performSegueWithIdentifier:TMWStoryboardIDs_UnwindFromRuleTransmitters sender:self];
        }
        
        NSString* previousTransmitterID = _rule.transmitterID;
        NSString* previousDeviceID = _rule.deviceID;
        _rule.transmitterID = transmitter.uid;
        _rule.deviceID = ((RelayrDevice*)[transmitter devicesWithInputMeaning:_rule.condition.meaning].firstObject).uid;
        
        __weak TMWRuleTransmittersController* weakSelf = self;
        [TMWAPIService setRule:_rule completion:^(NSError* error) {
            if (error)
            {
                weakSelf.rule.transmitterID = previousTransmitterID;
                weakSelf.rule.deviceID = previousDeviceID;
            }
            
            [weakSelf performSegueWithIdentifier:TMWStoryboardIDs_UnwindFromRuleTransmitters sender:weakSelf];
        }];
    }
}

#pragma mark - Private functionality

- (void)refreshRequest:(UIRefreshControl*)sender
{
    __weak UITableView* weakTableView = self.tableView;
    return [[TMWStore sharedInstance].relayrUser queryCloudForIoTs:^(NSError* error) {
        [sender endRefreshing];
        if (error) { return; } // TODO: Show text to user...
        [weakTableView reloadData];
    }];
}

- (IBAction)backButtonTapped:(id)sender
{
    if (_needsServerModification) { [RelayrCloud logMessage:TMWLogging_Edit_Cancelled onBehalfOfUser:[TMWStore sharedInstance].relayrUser]; }
    [self performSegueWithIdentifier:TMWStoryboardIDs_UnwindFromRuleTransmitters sender:self];
}

#pragma mark Navigation functionality

- (IBAction)unwindFromRuleMeasurements:(UIStoryboardSegue*)segue
{
    [RelayrCloud logMessage:TMWLogging_Creation_Transmitter onBehalfOfUser:[TMWStore sharedInstance].relayrUser];
}

@end
