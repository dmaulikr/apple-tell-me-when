#import "TMWRule.h" // Headers
#import "TMWRuleNotification.h"
#import "TMWRuleCondition.h"
#import "NSString+Hexadecimal.h" // TMW (Common/Utilities)
#import "NSData+Hexadecimal.h"
#import "TMWManager.h"


#define TMWRule_RuleID          @"_id"
#define TMWRule_Revision        @"_rev"
#define TMWRule_UserID          @"user_id"
#define TMWRule_TransmitterID   @"tx_id"
#define TMWRule_DeviceID        @"dev_id"
#define TMWRule_Active          @"active"
#define TMWRule_Details         @"details"
#define TMWRule_Details_Name    @"name"
#define TMWRule_Condition       @"condition"
#define TMWRule_Notifications   @"notifications"
#define TMWRule_Notif_Type      @"type"
#define TMWRule_Notif_Key       @"key"
#define TMWRule_Notif_Type_APNS @"apns"


@implementation TMWRule


#pragma mark - Class Methods

+ (TMWRule *)ruleForID:(NSString *)ruleID withinRulesArray:(NSArray *)rules {
    if (!ruleID.length || !rules.count) {
        return nil;
    }
    
    TMWRule *result;
    for (TMWRule *rule in rules) {
        if ([ruleID isEqualToString:rule.uid]) {
            result = rule; break;
        }
    }
    return result;
}


#pragma mark - Public API

- (instancetype)initWithUserID:(NSString *)userID {
    if (!userID.length) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _userID = userID;
        _active = YES;
    }
    return self;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary {
    if (!jsonDictionary.count) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _uid = jsonDictionary[TMWRule_RuleID];
        _revisionString = jsonDictionary[TMWRule_Revision];
        _userID = jsonDictionary[TMWRule_UserID];
        _transmitterID = jsonDictionary[TMWRule_TransmitterID];
        _deviceID = jsonDictionary[TMWRule_DeviceID];
        NSNumber *tmpNumber = jsonDictionary[TMWRule_Active];
        _active = (tmpNumber) ? tmpNumber.boolValue : YES; // Rules are active by default
        
        NSDictionary *tmpDict = jsonDictionary[TMWRule_Details];
        _name = tmpDict[TMWRule_Details_Name];
        _condition = [[TMWRuleCondition alloc] initWithJSONDictionary:jsonDictionary[TMWRule_Condition]];
        
        NSMutableArray *notifications = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in jsonDictionary[TMWRule_Notifications]) {
            TMWRuleNotification* notification = [[TMWRuleNotification alloc] initWithJSONDictionary:dict];
            if (notification) {
                [notifications addObject:notification];
            }
        }
        _notifications = [[NSMutableArray alloc] initWithArray:notifications];
    }
    return self;
}

- (NSDictionary *)compressIntoJSONDictionary {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    if (_uid) {
        result[TMWRule_RuleID] = _uid;
    }
    if (_revisionString) {
        result[TMWRule_Revision] = _revisionString;
    }
    result[TMWRule_UserID] = _userID;
    result[TMWRule_TransmitterID] = _transmitterID;
    result[TMWRule_DeviceID] = _deviceID;
    result[TMWRule_Active] = [NSNumber numberWithBool:_active];
    result[TMWRule_Details] = @{ TMWRule_Details_Name : _name };
    
    NSDictionary *conditionDictionary = [_condition compressIntoJSONDictionary];
    if (conditionDictionary) {
        result[TMWRule_Condition] = conditionDictionary;
    }
    NSArray *notificationsArray = [self compressNotificationsIntoJSONArray];
    if (notificationsArray) {
        result[TMWRule_Notifications] = notificationsArray;
    }
    return (result.count) ? [NSDictionary dictionaryWithDictionary:result] : nil;
}

- (NSString *)thresholdDescription {
    NSString *description = @"";
    if (_condition) {
        NSNumber *value = _condition.value;
        float floatVlaue = [value floatValue];
        if ([_condition.meaning isEqualToString:@"temperature"]) {
            description = [NSString stringWithFormat:@"%@ %.f °C", _condition.operation, floatVlaue];
        } else if ([_condition.meaning isEqualToString:@"humidity"]) {
            description = [NSString stringWithFormat:@"%@ %.f %%", _condition.operation, floatVlaue];
        } else if([_condition.meaning isEqualToString:@"luminosity"]) {
            description = [NSString stringWithFormat:@"%@ %.f %%", _condition.operation, floatVlaue / 40.96];
        } else if ([_condition.meaning isEqualToString:@"proximity"]) {
            description = [NSString stringWithFormat:@"%@ %.f %%", _condition.operation, floatVlaue / 20.48]; // FIXME: Add text to indicate "closeness"?
        } else if ([_condition.meaning isEqualToString:@"noise_level"]) {
            description = [NSString stringWithFormat:@"%@ %.f", _condition.operation, floatVlaue / 102.4];
        }
    }
    return description;
}

- (NSString *)type {
    NSString *type = @"";
    if (_condition) {
        if ([_condition.meaning isEqualToString:@"temperature"]) {
            type =  @"Temperature";
        } else if ([_condition.meaning isEqualToString:@"humidity"]) {
            type = @"Humidity";
        } else if ([_condition.meaning isEqualToString:@"proximity"]) {
            type = @"Proximity";
        } else if ([_condition.meaning isEqualToString:@"luminosity"]) {
            type = @"Brightness";
        } else if ([_condition.meaning isEqualToString:@"noise_level"]) {
            type = @"Sound";
        }
    }
    return  type;
}

- (RelayrTransmitter *)transmitter {
    for (RelayrTransmitter *transmitter in [TMWManager sharedInstance].wunderbars) {
        if ([transmitter.uid isEqualToString:_transmitterID]) {
            return transmitter;
        }
    }
    return nil;
}

- (UIImage *)typeImage {
    UIImage *image = nil;
    if (_condition) {
        if ([_condition.meaning isEqualToString:@"temperature"]) {
            image = [UIImage imageNamed:@"TemperatureIcon"];
        } else if ([_condition.meaning isEqualToString:@"humidity"]) {
            image = [UIImage imageNamed:@"HumidityIcon"];
        } else if ([_condition.meaning isEqualToString:@"proximity"]) {
            image = [UIImage imageNamed:@"ProximityIcon"];
        } else if ([_condition.meaning isEqualToString:@"luminosity"]) {
            image = [UIImage imageNamed:@"LightIcon"];
        } else if ([_condition.meaning isEqualToString:@"noise_level"]) {
            image = [UIImage imageNamed:@"NoiseIcon"];
        }
    }
    return image;
}


- (NSArray *)setupNotificationsWithDeviceToken:(NSData *)deviceToken {
    TMWRuleNotification* notification = [[TMWRuleNotification alloc] initWithDeviceToken:deviceToken];
    if (!notification) { return _notifications; }
    
    if (!_notifications.count) { return [NSArray arrayWithObject:notification]; }
    
    for (TMWRuleNotification* tmp in _notifications)
    {
        if ([tmp.type isEqualToString:TMWRule_Notif_Type_APNS] && [tmp.deviceToken isEqualToData:deviceToken]) { return _notifications; }
    }
    
    NSMutableArray* result = [NSMutableArray arrayWithArray:_notifications];
    [result addObject:notification];
    return [NSArray arrayWithArray:result];
}


#pragma mark - Private Methods

- (NSArray *)compressNotificationsIntoJSONArray {
    if (!_notifications.count) {
        return nil;
    }
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:_notifications.count];
    for (TMWRuleNotification *notification in _notifications) {
        NSString *hexString = [notification.deviceToken hexadecimalString];
        if (!notification.type.length || !hexString) {
            continue;
        }
        [result addObject:@{ TMWRule_Notif_Type : notification.type, TMWRule_Notif_Key : hexString }];
    }
    return (result.count) ? [NSArray arrayWithArray:result] : nil;
}

@end
