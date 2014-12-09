#import "TMWThresholdDetailsViewController.h" // Headers
#import "TMWRuleNameViewController.h"
#import "TMWEditRuleViewController.h"
#import "TMWRule.h"
#import "TMWRuleCondition.h"
#import "TMWAPIService.h"
#import "TMWManager.h"

@interface TMWThresholdDetailsViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *measurementIcon;
@property (strong, nonatomic) IBOutlet UILabel *wunderbarName;
@property (strong, nonatomic) IBOutlet UILabel *measurementType;
@property (strong, nonatomic) IBOutlet UIButton *lessThanButton;
@property (strong, nonatomic) IBOutlet UIButton *greaterthanButton;
@property (strong, nonatomic) IBOutlet UISlider *thresholdValueSlider;
@property (strong, nonatomic) IBOutlet UILabel *thresholdValueLabel;
@property (strong, nonatomic) NSDictionary *measurementRanges;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (assign, nonatomic, getter=isGreaterThan) BOOL greaterThan;
@property (strong, nonatomic) NSNumber *thresholdValue;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *fetchingSensorData;
@property (strong, nonatomic) IBOutlet UILabel *senorDataLabel;

- (IBAction)lessThanPressed:(id)sender;
- (IBAction)greaterThanPressed:(id)sender;
- (IBAction)updateThresholdValueLabel:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

@end


@implementation TMWThresholdDetailsViewController {
    RelayrDevice *_device;
}


#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // TODO: Refactor this into a normalised value method to be called whenever the normalised value is required in this class
    if ([_rule.type isEqualToString:@"Temperature"]) {
        _thresholdValue = (NSNumber *)_rule.condition.value;
    } else if ([_rule.type isEqualToString:@"Humidity"]) {
        _thresholdValue = (NSNumber *)_rule.condition.value;
    } else if ([_rule.type isEqualToString:@"Proximity"]) {
        NSNumber *proximityValue = (NSNumber *)_rule.condition.value;
        float normalisedProximityValue = proximityValue.floatValue / 20.48;
        _thresholdValue = [NSNumber numberWithFloat:normalisedProximityValue];
    } else if ([_rule.type isEqualToString:@"Brightness"]) {
        NSNumber *luminosityValue = (NSNumber *)_rule.condition.value;
        float normalisedLuminosityValue = luminosityValue.floatValue / 40.96;
        _thresholdValue = [NSNumber numberWithFloat:normalisedLuminosityValue];
    } else if ([_rule.type isEqualToString:@"Sound"]) {
        NSNumber *soundValue = (NSNumber *)_rule.condition.value;
        float normalisedSoundValue = soundValue.floatValue / 102.4;
        _thresholdValue = [NSNumber numberWithFloat:normalisedSoundValue];
    }
    [self setUpThresholdValue];
    [self setUpThresholdOperator];
    if (self.isEditingRule || self.isEditingMeasurement) {
        [_doneButton setTitle:@"done" forState:UIControlStateNormal];
    }
    _wunderbarName.text = _rule.transmitter.name;
    _measurementType.text = _rule.type;
    [self setMeasurementIcon];
}

- (void)viewDidAppear:(BOOL)animated
{
    RelayrUser *user = [TMWManager sharedInstance].relayrUser;
    if (!user || !_rule.deviceID.length) {
        return;
    }
    RelayrTransmitter *transmitter;
    for (RelayrTransmitter *trans in user.transmitters) {
        if ([trans.uid isEqualToString:_rule.transmitterID]) {
            transmitter = trans; break;
        }
    }
    if (!transmitter) {
        return;
    }
    for (RelayrDevice *dev in transmitter.devices) {
        if ([dev.uid isEqualToString:_rule.deviceID]) {
            _device = dev;
            break;
        }
    }
    if (!_device) {
        return;
    }
    NSLog(@"Subscribe to sensor data");
    [_device subscribeToAllInputsWithBlock:^(RelayrDevice *device, RelayrInput *input, BOOL *unsubscribe) {
        NSLog(@"Data received!");
        if ([_rule.type isEqualToString:@"Temperature"]) {
            NSNumber *temperatureValue = (NSNumber *)input.value;
            _senorDataLabel.text = [NSString stringWithFormat:@"Current sensor value: %.f°C", temperatureValue.floatValue];
        } else if ([_rule.type isEqualToString:@"Humidity"]) {
            NSNumber *humidityValue = (NSNumber *)input.value;
            _senorDataLabel.text = [NSString stringWithFormat:@"Current sensor value: %.f%%", humidityValue.floatValue];
        } else if ([_rule.type isEqualToString:@"Proximity"] && [input.meaning isEqualToString:@"proximity"]) {
            NSNumber *proximityValue = (NSNumber *)input.value;
            _senorDataLabel.text = [NSString stringWithFormat:@"Current sensor value: %.f%%", proximityValue.floatValue / 20.48];
        } else if ([_rule.type isEqualToString:@"Brightness"] && [input.meaning isEqualToString:@"luminosity"]) {
            NSNumber *luminosityValue = (NSNumber *)input.value;
            _senorDataLabel.text = [NSString stringWithFormat:@"Current sensor value: %.f%%", luminosityValue.floatValue / 40.96];
        } else if ([_rule.type isEqualToString:@"Sound"]) {
            NSNumber *noiseLevelValue = (NSNumber *)input.value;
            _senorDataLabel.text = [NSString stringWithFormat:@"Current sensor value: %.f", noiseLevelValue.floatValue / 102.4];
        }
        [_fetchingSensorData stopAnimating];
    } error:^(NSError *error) {
        _senorDataLabel.text = @"Error subscribing";
        // TODO: Back off and try to fetch sensor data again.
        NSLog(@"Error subscribing");
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _measurementRanges = @{ @"Temperature" : @[@-40.0f, @120.0f], @"Humidity" : @[@0.0f, @100.0f], @"Proximity" : @[@0.0f, @100.0f], @"Brightness" : @[@0.0f, @100.0f], @"Sound" : @[@0.0f, @10.0f] };
}

- (void)viewWillDisappear:(BOOL)animated {
    if (!_device) {
        return;
    }
    [_device removeAllSubscriptions];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowRuleNameView"]) {
        TMWRuleNameViewController *ruleNameViewController = segue.destinationViewController;
        ruleNameViewController.rule = _rule;
    }
    if ([segue.identifier isEqualToString:@"UnwindToEditRuleView"]) {
        TMWEditRuleViewController *editRuleView = segue.destinationViewController;
        editRuleView.rule = _rule;
    }
}


#pragma mark - IBActions

- (IBAction)lessThanPressed:(UIButton *)sender {
    if (!sender.isSelected) {
        _lessThanButton.selected = YES;
        _greaterthanButton.selected = NO;
        _greaterThan = NO;
        _rule.condition.operation = @"<";
    }
}

- (IBAction)greaterThanPressed:(UIButton *)sender {
    if (!sender.isSelected) {
        _greaterthanButton.selected = YES;
        _lessThanButton.selected = NO;
        _greaterThan = YES;
        _rule.condition.operation = @">";
    }
}

- (IBAction)updateThresholdValueLabel:(id)sender {
     [self setThresholdValueLabel];
}

- (IBAction)doneButtonPressed:(id)sender {
    if (_greaterThan) {
        _rule.condition.operation = @">";
    } else {
        _rule.condition.operation = @"<";
    }
    _rule.condition.value = _thresholdValue;
    if (self.isEditingRule || self.isEditingMeasurement) {
        [self patchRule];
        [self performSegueWithIdentifier:@"UnwindToEditRuleView" sender:self];
    } else {
        [self performSegueWithIdentifier:@"ShowRuleNameView" sender:self];    
    }
}


#pragma mark - Private Methods

- (void)setMeasurementIcon {
    if ([_rule.type isEqualToString:@"Temperature"]) {
        _measurementIcon.image = [UIImage imageNamed:@"TemperatureIcon"];
    } else if ([_rule.type isEqualToString:@"Humidity"]) {
        _measurementIcon.image = [UIImage imageNamed:@"HumidityIcon"];
    } else if ([_rule.type isEqualToString:@"Proximity"]) {
        _measurementIcon.image = [UIImage imageNamed:@"ProximityIcon"];
    } else if ([_rule.type isEqualToString:@"Brightness"]) {
        _measurementIcon.image = [UIImage imageNamed:@"LightIcon"];
    } else if ([_rule.type isEqualToString:@"Sound"]) {
        _measurementIcon.image = [UIImage imageNamed:@"NoiseIcon"];
    }
    _rule.typeImage =  _measurementIcon.image;
}

- (void)setUpThresholdValue {
    NSArray *range = [_measurementRanges objectForKey:_rule.type];
    NSNumber *minimumValue = [range objectAtIndex:0];
    NSNumber *maximumValue = [range objectAtIndex:1];
    _thresholdValueSlider.minimumValue = minimumValue.floatValue;
    _thresholdValueSlider.maximumValue = maximumValue.floatValue;
    if (self.isEditingRule) {
        _thresholdValueSlider.value = [_thresholdValue floatValue];
    } else {
        _thresholdValueSlider.value = (minimumValue.floatValue + maximumValue.floatValue) * 0.5;
    }
    [self setThresholdValueLabel];
}

- (void)setThresholdValueLabel {
    if ([_rule.type isEqualToString:@"Temperature"]) {
        _thresholdValueLabel.text = [NSString stringWithFormat:@"%.f °C", _thresholdValueSlider.value];
    } else if ([_rule.type isEqualToString:@"Humidity"] || [_rule.type isEqualToString:@"Proximity"] || [_rule.type isEqualToString:@"Brightness"]) {
        _thresholdValueLabel.text = [NSString stringWithFormat:@"%.f %%", _thresholdValueSlider.value];
    } else if ([_rule.type isEqualToString:@"Sound"]) {
        _thresholdValueLabel.text = [NSString stringWithFormat:@"%.f", _thresholdValueSlider.value];
    }
    
    if ([_rule.type isEqualToString:@"Sound"]) {
         _thresholdValue = [NSNumber numberWithFloat:_thresholdValueSlider.value * 102.4];
    } else if ([_rule.type isEqualToString:@"Proximity"]) {
         _thresholdValue = [NSNumber numberWithFloat:_thresholdValueSlider.value * 20.48];
    } else if ([_rule.type isEqualToString:@"Brightness"]) {
         _thresholdValue = [NSNumber numberWithFloat:_thresholdValueSlider.value * 40.96];
    } else {
        _thresholdValue = [NSNumber numberWithFloat:_thresholdValueSlider.value];
    }
}

- (void)setUpThresholdOperator {
    if ([_rule.condition.operation isEqualToString:@">"]) {
        _greaterthanButton.selected = YES;
        _lessThanButton.selected = NO;
    } else {
        _lessThanButton.selected = YES;
        _greaterthanButton.selected = NO;
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
