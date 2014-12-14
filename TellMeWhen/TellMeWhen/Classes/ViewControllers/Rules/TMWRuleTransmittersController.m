#import "TMWRuleTransmittersController.h"   // Header

#import "TMWStore.h"                        // TMW (Model)
#import "TMWRule.h"                         // TMW (Model)
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

#pragma mark UIViewController methods

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    // TODO:
}

#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    NSSet* transSet = [TMWStore sharedInstance].relayrUser.transmitters;
    if (!transSet.count)
    {
        // TODO: If there are no transmitters, unwind to rules... <#TODO#>
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
    TMWRuleTransmitterCellView* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TMWRuleTransmitterCellView class])];
    cell.transmitterNameLabel.text = ((RelayrTransmitter*)_transmitters[indexPath.row]).name;
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [self performSegueWithIdentifier:TMWStoryboardIDs_SegueFromRulesTransToMeasures sender:self];
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

@end
