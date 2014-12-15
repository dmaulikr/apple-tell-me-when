#import "TMWRuleTransmittersController.h"   // Header

#import "TMWStore.h"                        // TMW (Model)
#import "TMWAPIService.h"                   // TMW (Model)
#import "TMWRule.h"                         // TMW (Model)
#import "TMWStoryboardIDs.h"                // TMW (ViewControllers/Segues)
#import "TMWSegueUnwindingRules.h"          // TMW (ViewControllers/Segues)
#import "TMWRuleMeasurementsController.h"   // TMW (ViewControllers/Rules)
#import "TMWUIProperties.h"                 // TMW (Views)
#import "TMWRuleTransmitterCellView.h"      // TMW (Views/Rules)

#pragma mark Definitions

#define TMWRuleTransCntrl_RefreshString     @"Querying user's IoTs..."

@interface TMWRuleTransmittersController () <TMWSegueUnwindingRules>
@property (readonly,nonatomic) NSString* segueIdentifierForUnwind;
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
        ((TMWRuleMeasurementsController*)segue.destinationViewController).rule = _rule;
    }
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    NSSet* transSet = [TMWStore sharedInstance].relayrUser.transmitters;
    if (!transSet.count)
    {
        _transmitters = nil;
        [self performSegueWithIdentifier:self.segueIdentifierForUnwind sender:self];
        return 0;
    }
    _transmitters = transSet.allObjects;
    return 1;
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
    if (!_needsServerModification)
    {
        return [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesTransToMeasures sender:self];
    }
    
    TMWRuleTransmitterCellView* cell = (TMWRuleTransmitterCellView*)[tableView cellForRowAtIndexPath:indexPath];
    RelayrTransmitter* transmitter = [TMWStore transmitterWithID:cell.transmitterID];
    if (!transmitter.uid.length || [transmitter.uid isEqualToString:_rule.transmitterID])
    {
        return [self performSegueWithIdentifier:TMWStoryboardIDs_UnwindFromRuleTransToSum sender:self];
    }
    
    _rule.transmitterID = transmitter.uid;
    
    __weak TMWRuleTransmittersController* weakSelf = self;
    [TMWAPIService setRule:_rule completion:^(NSError* error) {
        [weakSelf performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesTransToMeasures sender:weakSelf];
    }];
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
    [self performSegueWithIdentifier:self.segueIdentifierForUnwind sender:self];
}

#pragma mark Navigation functionality

- (NSString*)segueIdentifierForUnwind
{
    return (!_needsServerModification) ? TMWStoryboardIDs_UnwindFromRuleTransToList : TMWStoryboardIDs_UnwindFromRuleTransToSum;
}

- (IBAction)unwindFromRuleMeasurements:(UIStoryboardSegue*)segue { }

@end
