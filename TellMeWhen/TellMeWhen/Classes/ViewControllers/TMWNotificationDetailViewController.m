#import "TMWNotificationDetailViewController.h"
#import "TMWRule.h"
#import "TMWManager.h"

@interface TMWNotificationDetailViewController ()

@property (strong, nonatomic) TMWRule *rule;
@property (strong, nonatomic) IBOutlet UILabel *notificationNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *notificationDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *thresholdTimestampMetLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentSensorValueLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *fetchingSensorData;

@end


@implementation TMWNotificationDetailViewController {
    RelayrDevice *_device;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    for (TMWRule *rule in [TMWManager sharedInstance].rules) {
        if ([rule.uid isEqualToString:_notification.ruleID]) {
            _rule = rule;
        }
    }
    _notificationNameLabel.text = _rule.name.uppercaseString;
    _notificationDescriptionLabel.text = [NSString stringWithFormat:@"%@ %@", _rule.type, _rule.thresholdDescription];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.calendar = [NSCalendar currentCalendar];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _thresholdTimestampMetLabel.text = [dateFormatter stringFromDate:_notification.timestamp];
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
            _currentSensorValueLabel.text = [NSString stringWithFormat:@"Current sensor value: %.f°C", temperatureValue.floatValue];
        } else if ([_rule.type isEqualToString:@"Humidity"]) {
            NSNumber *humidityValue = (NSNumber *)input.value;
            _currentSensorValueLabel.text = [NSString stringWithFormat:@"Current sensor value: %.f%%", humidityValue.floatValue];
        } else if ([_rule.type isEqualToString:@"Proximity"] && [input.meaning isEqualToString:@"proximity"]) {
            NSNumber *proximityValue = (NSNumber *)input.value;
            _currentSensorValueLabel.text = [NSString stringWithFormat:@"Current sensor value: %.f%%", proximityValue.floatValue / 20.48];
        } else if ([_rule.type isEqualToString:@"Brightness"] && [input.meaning isEqualToString:@"luminosity"]) {
            NSNumber *luminosityValue = (NSNumber *)input.value;
            _currentSensorValueLabel.text = [NSString stringWithFormat:@"Current sensor value: %.f%%", luminosityValue.floatValue / 40.96];
        } else if ([_rule.type isEqualToString:@"Sound"]) {
            NSNumber *noiseLevelValue = (NSNumber *)input.value;
            _currentSensorValueLabel.text = [NSString stringWithFormat:@"Current sensor value: %.f", noiseLevelValue.floatValue / 102.4];
        }
        [_fetchingSensorData stopAnimating];
    } error:^(NSError *error) {
        _currentSensorValueLabel.text = @"Error subscribing";
        // TODO: Back off and try to fetch sensor data again.
        NSLog(@"Error subscribing");
    }];
}

@end
