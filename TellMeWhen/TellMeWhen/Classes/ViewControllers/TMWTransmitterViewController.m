#import <Relayr/Relayr.h> // relayr

#import "TMWTransmitterViewController.h" // Headers
#import "TMWTransmittersTableViewCell.h"
#import "TMWRule.h"
#import "TMWMeasurementViewController.h"
#import "TMWEditRuleViewController.h"
#import "TMWStore.h"


static NSString *const kTransmittersTableViewCellReuseIdentifier = @"TransmittersTableViewCell";


@interface TMWTransmitterViewController ()

@property (strong, nonatomic) IBOutlet UITableView *transmittersTableView;
@property (strong, nonatomic) NSArray *transmittersTableViewDataSource;
@property (strong, nonatomic) IBOutlet UIView *noTransmittersView;

@end


@implementation TMWTransmitterViewController


#pragma mark - View Controller Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    _transmittersTableViewDataSource = [[TMWStore sharedInstance].relayrUser.transmitters allObjects];
    [self showOrHideTransmitterTableView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowMeasurementView"]) {
        TMWMeasurementViewController *measurementViewController = segue.destinationViewController;
        measurementViewController.rule = sender;
    }
    if ([segue.identifier isEqualToString:@"UnwindToEditRuleView"]) {
        TMWEditRuleViewController *editRulesViewController = segue.destinationViewController;
        editRulesViewController.rule.transmitter = sender;
    }
}


#pragma mark - Table View Data Source Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMWTransmittersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTransmittersTableViewCellReuseIdentifier];
    RelayrTransmitter *cellTransmitter = [_transmittersTableViewDataSource objectAtIndex:indexPath.row];
    cell.transmitterName.text = cellTransmitter.name;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _transmittersTableViewDataSource.count;
}


#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RelayrTransmitter *transmitter = [_transmittersTableViewDataSource objectAtIndex:indexPath.row];
    if (self.isEditingRule) {
        // Make "patch" rule API call
        [self performSegueWithIdentifier:@"UnwindToEditRuleView" sender:transmitter];
    } else {
        TMWRule *newRule = [[TMWRule alloc] initWithUserID:[TMWStore sharedInstance].relayrUser.uid];
        newRule.transmitterID = transmitter.uid;
        newRule.transmitter = transmitter; // TODO: Refactor me please!
        [self performSegueWithIdentifier:@"ShowMeasurementView" sender:newRule];
    }
}


#pragma mark - Private Methods

- (void)showOrHideTransmitterTableView {
    if ([_transmittersTableViewDataSource count] == 0) {
        _noTransmittersView.hidden = NO;
        _transmittersTableView.hidden = YES;
    } else {
        _transmittersTableView.hidden = NO;
        _noTransmittersView.hidden = YES;
    }
}

@end
