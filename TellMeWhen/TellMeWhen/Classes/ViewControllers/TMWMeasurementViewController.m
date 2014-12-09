#import <Relayr/Relayr.h> // relayr

#import "TMWMeasurementViewController.h" // Headers
#import "TMWMeasurementTableViewCell.h"
#import "TMWThresholdDetailsViewController.h"
#import "TMWEditRuleViewController.h"
#import "TMWManager.h"
#import "TMWRuleCondition.h"
#import "TMWAPIService.h"


static NSString *const kMeasurementTableViewCellReuseIdentifier = @"MeasurementsTableViewCell";


@interface TMWMeasurementViewController ()

@property (strong, nonatomic) NSArray *measurementTypes;
@property (strong, nonatomic) NSArray *meanings;
// @property (strong, nonatomic) NSArray *shortMeanings;

@end


@implementation TMWMeasurementViewController


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    // FIXME: Move this to the model
    _measurementTypes = @[@"Temperature", @"Humidity", @"Proximity", @"Brightness", @"Sound"];
    _meanings = @[@"temperature", @"humidity", @"proximity", @"luminosity", @"noise_level"];
    // _shortMeanings = @[@"temp", @"hum", @"prox", @"light", @"snd_level", @"accel"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowValuesDetailsView"]) {
        TMWThresholdDetailsViewController *valueDetailsViewController = segue.destinationViewController;
        valueDetailsViewController.rule = _rule;
        if (self.isEditingRule) {
            valueDetailsViewController.editingMeasurement = YES;
        }
    }
}


#pragma mark - Table View Data Source Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMWMeasurementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMeasurementTableViewCellReuseIdentifier];
    if (indexPath.row == 0) {
        cell.measurementIcon.image = [UIImage imageNamed:@"TemperatureIcon"];
        cell.measurementType.text = [_measurementTypes objectAtIndex:indexPath.row];
    } else if (indexPath.row == 1) {
        cell.measurementIcon.image = [UIImage imageNamed:@"HumidityIcon"];
        cell.measurementType.text = [_measurementTypes objectAtIndex:indexPath.row];
    } else if (indexPath.row == 2) {
        cell.measurementIcon.image = [UIImage imageNamed:@"ProximityIcon"];
        cell.measurementType.text = [_measurementTypes objectAtIndex:indexPath.row];
    } else if (indexPath.row == 3) {
        cell.measurementIcon.image = [UIImage imageNamed:@"LightIcon"];
        cell.measurementType.text = [_measurementTypes objectAtIndex:indexPath.row];
    } else if (indexPath.row == 4) {
        cell.measurementIcon.image = [UIImage imageNamed:@"NoiseIcon"];
        cell.measurementType.text = [_measurementTypes objectAtIndex:indexPath.row];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _measurementTypes.count;
}


#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *measurementType = [_measurementTypes objectAtIndex:indexPath.row];
    // TODO: Refactor this mess
    _rule.type = measurementType;
    NSString *meaning = [_meanings objectAtIndex:indexPath.row];
    TMWRuleCondition *condition = [[TMWRuleCondition alloc] init];
    condition.meaning = meaning;
    _rule.condition = condition;
    _rule.deviceID = [self getDeviceIDForWunderbar:_rule.transmitter];
    if (self.isEditingRule) {
      [self patchRule];
    }
    [self performSegueWithIdentifier:@"ShowValuesDetailsView" sender:_rule];
}


#pragma mark - Private Methods

- (NSString *)getDeviceIDForWunderbar:(RelayrTransmitter *)wunderbar { // TODO: Move out of the view controller.
    NSString *deviceId = @"";
    NSArray *devices = [wunderbar.devices allObjects];
    for (RelayrDevice *device in devices) {
        NSArray *inputs = [device.inputs allObjects];
        for (RelayrInput *input in inputs) {
            if ([_rule.condition.meaning isEqualToString:input.meaning]) {
                deviceId = device.uid;
            }
        }
    }
    return deviceId;
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
