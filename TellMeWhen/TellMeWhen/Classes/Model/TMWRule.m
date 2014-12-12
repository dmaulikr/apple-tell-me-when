#import "TMWRule.h" // Headers
#import "TMWRuleNotification.h"
#import "TMWRuleCondition.h"
#import "NSString+Hexadecimal.h" // TMW (Common/Utilities)
#import "NSData+Hexadecimal.h"
#import "TMWStore.h"

#pragma mark - Definitions

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

#pragma mark - Public API

- (instancetype)initWithUserID:(NSString *)userID
{
    if (!userID.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _userID = userID;
        _active = YES;
    }
    return self;
}

- (instancetype)initWithJSONDictionary:(NSDictionary*)jsonDictionary
{
    if (!jsonDictionary.count) { return nil; }
    
    self = [super init];
    if (self)
    {
        _uid = jsonDictionary[TMWRule_RuleID];
        _revisionString = jsonDictionary[TMWRule_Revision];
        _userID = jsonDictionary[TMWRule_UserID];
        _transmitterID = jsonDictionary[TMWRule_TransmitterID];
        _deviceID = jsonDictionary[TMWRule_DeviceID];
        NSNumber* tmpNumber = jsonDictionary[TMWRule_Active];
        _active = (tmpNumber) ? tmpNumber.boolValue : YES; // Rules are active by default
        
        NSDictionary* tmpDict = jsonDictionary[TMWRule_Details];
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

- (NSDictionary*)compressIntoJSONDictionary
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    if (_uid) { result[TMWRule_RuleID] = _uid; }
    if (_revisionString) { result[TMWRule_Revision] = _revisionString; }
    result[TMWRule_UserID] = _userID;
    result[TMWRule_TransmitterID] = _transmitterID;
    result[TMWRule_DeviceID] = _deviceID;
    result[TMWRule_Active] = [NSNumber numberWithBool:_active];
    result[TMWRule_Details] = @{ TMWRule_Details_Name : _name };
    
    NSDictionary *conditionDictionary = [_condition compressIntoJSONDictionary];
    if (conditionDictionary) { result[TMWRule_Condition] = conditionDictionary; }
    NSArray *notificationsArray = [self compressRuleIntoJSONArray];
    if (notificationsArray) { result[TMWRule_Notifications] = notificationsArray; }
    return (result.count) ? [NSDictionary dictionaryWithDictionary:result] : nil;
}

- (NSArray*)setupNotificationsWithDeviceToken:(NSData *)deviceToken
{
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

#pragma mark Generator methods (readonly)

- (NSString*)type
{
    if (!_condition) { return nil; }
    return  ([_condition.meaning isEqualToString:@"temperature"]) ? @"Temperature"  :
            ([_condition.meaning isEqualToString:@"humidity"])    ? @"Humidity"     :
            ([_condition.meaning isEqualToString:@"proximity"])   ? @"Proximity"    :
            ([_condition.meaning isEqualToString:@"luminosity"])  ? @"Brightness"   :
            ([_condition.meaning isEqualToString:@"noise_level"]) ? @"Sound"        : nil;
}

- (UIImage*)icon
{
    if (!_condition) { return nil; }
    return  ([_condition.meaning isEqualToString:@"temperature"]) ? [UIImage imageNamed:@"IconTemperature"] :
            ([_condition.meaning isEqualToString:@"humidity"])    ? [UIImage imageNamed:@"IconHumidity"]    :
            ([_condition.meaning isEqualToString:@"proximity"])   ? [UIImage imageNamed:@"IconProximity"]   :
            ([_condition.meaning isEqualToString:@"luminosity"])  ? [UIImage imageNamed:@"IconLight"]       :
            ([_condition.meaning isEqualToString:@"noise_level"]) ? [UIImage imageNamed:@"IconNoise"]       : nil;
}

- (NSString*)thresholdDescription
{
    if (!_condition || ![_condition.value isKindOfClass:[NSNumber class]]) { return nil; }
    
    float const value = [_condition.value floatValue];
    // FIXME: (proximity) Add text to indicate "closeness"?
    return  ([_condition.meaning isEqualToString:@"temperature"]) ? [NSString stringWithFormat:@"%@ %.f °C", _condition.operation, value]           :
            ([_condition.meaning isEqualToString:@"humidity"])    ? [NSString stringWithFormat:@"%@ %.f %%", _condition.operation, value]           :
            ([_condition.meaning isEqualToString:@"luminosity"])  ? [NSString stringWithFormat:@"%@ %.f %%", _condition.operation, value / 40.96]   :
            ([_condition.meaning isEqualToString:@"proximity"])   ? [NSString stringWithFormat:@"%@ %.f %%", _condition.operation, value / 20.48]   :
            ([_condition.meaning isEqualToString:@"noise_level"]) ? [NSString stringWithFormat:@"%@ %.f", _condition.operation, value / 102.4]      : nil;
}

- (RelayrTransmitter*)transmitter
{
    for (RelayrTransmitter *transmitter in [TMWStore sharedInstance].relayrUser.transmitters)
    {
        if ([transmitter.uid isEqualToString:_transmitterID]) { return transmitter; }
    }
    return nil;
}

#pragma mark Class Methods

+ (TMWRule*)ruleForID:(NSString *)ruleID withinRulesArray:(NSArray*)rules
{
    if (!ruleID.length || !rules.count) { return nil; }
    
    TMWRule *result;
    for (TMWRule *rule in rules)
    {
        if ([ruleID isEqualToString:rule.uid]) { result = rule; break; }
    }
    return result;
}

+ (BOOL)synchronizeStoredRules:(NSMutableArray*)coreRules withNewlyArrivedRules:(NSMutableArray*)serverRules resultingInCellsIndexPathsToAdd:(NSArray**)addingCellIndexPaths cellsIndexPathsToRemove:(NSArray**)removingCellsIndexPaths cellsIndexPathsToReload:(NSArray**)reloadingCellIndexPaths
{
    if (!serverRules.count)
    {
        *addingCellIndexPaths = nil;
        *removingCellsIndexPaths = [TMWRule arrayIndexPaths:coreRules inSection:0];
        *reloadingCellIndexPaths = nil;
        [coreRules removeAllObjects];
        return (*removingCellsIndexPaths) ? YES : NO;
    }
    else if (!coreRules.count)
    {
        *addingCellIndexPaths = [TMWRule arrayIndexPaths:serverRules inSection:0];
        *removingCellsIndexPaths = nil;
        *reloadingCellIndexPaths = nil;
        [coreRules addObjectsFromArray:serverRules];
        return (*addingCellIndexPaths) ? YES : NO;
    }
    
    __block NSMutableArray* rulesToRemove;
    __block NSMutableArray* indexPathsToRemove;
    __block NSMutableArray* indexPathsToReplace;
    [coreRules enumerateObjectsUsingBlock:^(TMWRule* cRule, NSUInteger idx, BOOL* stop) {
        TMWRule* toReplace;
        
        for (TMWRule* sRule in serverRules)
        {
            if ([cRule.uid isEqualToString:sRule.uid])
            {
                toReplace = sRule;
                
                cRule.revisionString = sRule.revisionString;
                cRule.transmitterID = sRule.transmitterID;
                cRule.deviceID = sRule.deviceID;
                if (![cRule.name isEqualToString:sRule.name] || ![cRule.condition isEqual:sRule.condition] || cRule.active!=sRule.active)
                {
                    cRule.name = sRule.name;
                    cRule.condition = sRule.condition;
                    cRule.active = sRule.active;
                    if (!indexPathsToReplace) { indexPathsToReplace = [[NSMutableArray alloc] init]; }
                    [indexPathsToReplace addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                }
                cRule.notifications = sRule.notifications;
                break;
            }
        }
        
        if (!toReplace)
        {
            if (!indexPathsToRemove) { indexPathsToRemove = [[NSMutableArray alloc] init]; }
            [indexPathsToRemove addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            
            if (!rulesToRemove) { rulesToRemove = [[NSMutableArray alloc] init]; }
            [rulesToRemove addObject:cRule];
        }
        else { [serverRules removeObject:toReplace]; }
    }];
    
    [coreRules removeObjectsInArray:rulesToRemove];
    *removingCellsIndexPaths = (indexPathsToRemove.count) ? indexPathsToRemove.copy : nil;
    *reloadingCellIndexPaths = (indexPathsToReplace.count) ? indexPathsToReplace.copy : nil;
    
    NSUInteger const remainingRules = serverRules.count;
    if (remainingRules)
    {
        NSMutableArray* indexPathsToAdd = [[NSMutableArray alloc] initWithCapacity:remainingRules];
        NSUInteger const alreadyStoredRules = coreRules.count;
        for (NSUInteger i=coreRules.count; i<alreadyStoredRules+remainingRules; ++i)
        {
            [indexPathsToAdd addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        [coreRules addObjectsFromArray:serverRules];
    }
    
    return ((*reloadingCellIndexPaths).count || (*addingCellIndexPaths).count || (*removingCellsIndexPaths).count) ? YES : NO;
}

#pragma mark - Private Methods

- (NSArray*)compressRuleIntoJSONArray
{
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

+ (NSArray*)arrayIndexPaths:(NSArray*)array inSection:(NSInteger const)section
{
    NSUInteger const count = array.count;
    if (!count) { return nil; }
    
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:count];
    for (NSUInteger i=0; i<count; ++i) { [result addObject:[NSIndexPath indexPathForRow:i inSection:section]]; }
    return result;
}

@end
