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
#define TMWRule_Details_Modify  @"modified"
#define TMWRule_Condition       @"condition"
#define TMWRule_Notifications   @"notifications"
#define TMWRule_Notif_Type      @"type"
#define TMWRule_Notif_Key       @"key"
#define TMWRule_Notif_Type_APNS @"apns"

static NSString* const kCodingID        = @"uid";
static NSString* const kCodingRevision  = @"rev";
static NSString* const kCodingUserID    = @"uID";
static NSString* const kCodingTransID   = @"trID";
static NSString* const kCodingDevID     = @"devID";
static NSString* const kCodingName      = @"name";
static NSString* const kCodingModified  = @"mod";
static NSString* const kCodingCondition = @"cond";
static NSString* const kCodingNotifs    = @"nots";
static NSString* const kCodingActive    = @"act";

@implementation TMWRule

#pragma mark - Public API

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithUserID:(NSString*)userID
{
    if (!userID.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _userID = userID;
        _notifications = [[NSMutableArray alloc] init];
        _active = YES;
    }
    return self;
}

- (instancetype)initWithJSONDictionary:(NSDictionary*)jsonDictionary
{
    if (!jsonDictionary.count) { return nil; }
    
    self = [self initWithUserID:jsonDictionary[TMWRule_UserID]];
    if (self)
    {
        _uid = jsonDictionary[TMWRule_RuleID];
        _revisionString = jsonDictionary[TMWRule_Revision];
        _transmitterID = jsonDictionary[TMWRule_TransmitterID];
        _deviceID = jsonDictionary[TMWRule_DeviceID];
        NSNumber* tmpNumber = jsonDictionary[TMWRule_Active];
        _active = (tmpNumber) ? tmpNumber.boolValue : YES;
        NSDictionary* tmpDict = jsonDictionary[TMWRule_Details];
        _name = tmpDict[TMWRule_Details_Name];
        NSNumber* timestamp = jsonDictionary[TMWRule_Details_Modify];
        _modified = (!timestamp) ? [NSDate date] : [NSDate dateWithTimeIntervalSince1970:timestamp.doubleValue / 1000.0];
        _condition = [[TMWRuleCondition alloc] initWithJSONDictionary:jsonDictionary[TMWRule_Condition]];
        for (NSDictionary* dict in jsonDictionary[TMWRule_Notifications])
        {
            TMWRuleNotification* notif = [[TMWRuleNotification alloc] initWithJSONDictionary:dict];
            if (notif) { [_notifications addObject:notif]; }
        }
    }
    return self;
}

- (BOOL)isEqualDeeplyTo:(TMWRule*)rule
{
    if (!rule) { return NO; }
    
    if ( ![_uid isEqualToString:rule.uid] ||
         ![_revisionString isEqualToString:rule.revisionString] ||
         ![_userID isEqualToString:rule.userID] ||
         ![_transmitterID isEqualToString:rule.transmitterID] ||
         ![_deviceID isEqualToString:rule.deviceID] ||
         ![_name isEqualToString:rule.name] ||
         _active != rule.active ||
         ![_condition isEqual:rule.condition]) { return NO; }
    
    for (TMWRuleNotification* notif in _notifications)
    {
        if (![rule.notifications containsObject:notif]) { return NO; }
    }
    return YES;
}

- (NSDictionary*)compressIntoJSONDictionary
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    if (_uid) { result[TMWRule_RuleID] = _uid; }
    if (_revisionString) { result[TMWRule_Revision] = _revisionString; }
    result[TMWRule_UserID] = _userID;
    result[TMWRule_TransmitterID] = _transmitterID;
    result[TMWRule_DeviceID] = _deviceID;
    result[TMWRule_Active] = [NSNumber numberWithBool:_active];
    
    NSMutableDictionary* details = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (_name) { details[TMWRule_Details_Name] = _name; }
    if (_modified) { details[TMWRule_Details_Modify] = [NSNumber numberWithDouble:floor(_modified.timeIntervalSince1970 * 1000.0)]; }
    result[TMWRule_Details] = [NSDictionary dictionaryWithDictionary:details];
    
    NSDictionary* conditionDictionary = [_condition compressIntoJSONDictionary];
    if (conditionDictionary) { result[TMWRule_Condition] = conditionDictionary; }
    NSArray *notificationsArray = [self compressNotificationsIntoJSONArray];
    if (notificationsArray) { result[TMWRule_Notifications] = notificationsArray; }
    return [NSDictionary dictionaryWithDictionary:result];
}

- (void)setWith:(TMWRule*)rule
{
    if (!rule) { return; }
    
    if (rule.uid.length) { _uid = rule.uid; }
    if (rule.revisionString.length) { _revisionString = rule.revisionString; }
    if (rule.transmitterID.length) { _transmitterID = rule.transmitterID; }
    if (rule.deviceID.length) { _deviceID = rule.deviceID; }
    if (rule.name.length) { _name = rule.name; }
    if (rule.modified) { _modified = rule.modified; }
    if (rule.condition) { _condition = rule.condition; }
    if (rule.notifications) { _notifications = rule.notifications; }
}

- (BOOL)setNotificationsWithDeviceToken:(NSData*)data previousDeviceToken:(NSData*)previousData
{
    if (!previousData.length)
    {   // Case to add a new notification deviceToken
        TMWRuleNotification* notif = [[TMWRuleNotification alloc] initWithDeviceToken:data];
        if (!notif || [_notifications containsObject:notif]) { return NO; }
        [_notifications addObject:notif];
        return YES;
    }
    else if (!data)
    {   // Case to remove a previous notification deviceToken
        TMWRuleNotification* notif = [[TMWRuleNotification alloc] initWithDeviceToken:previousData];
        NSUInteger const index = [_notifications indexOfObject:notif];
        if (index == NSNotFound) { return NO; }
        [_notifications removeObjectAtIndex:index];
        return YES;
    }
    else if ([data isEqualToData:previousData])
    {   // Case to add a notification deviceToken in case it is not there.
        TMWRuleNotification* notif = [[TMWRuleNotification alloc] initWithDeviceToken:data];
        NSUInteger const index = [_notifications indexOfObject:notif];
        if (index != NSNotFound) { return NO; }
        [_notifications addObject:notif];
        return YES;
    }
    else
    {   // Case to set with a new deviceToken a previous notification
        TMWRuleNotification* notif = [[TMWRuleNotification alloc] initWithDeviceToken:previousData];
        NSUInteger const index = [_notifications indexOfObject:notif];
        if (index != NSNotFound)
        {
            TMWRuleNotification* cNotif = [_notifications objectAtIndex:index];
            cNotif.deviceToken = data;
        }
        else { [_notifications addObject:notif]; }
        return YES;
    }
}

#pragma mark Generator methods (readonly)

- (NSString*)type
{
    if (!_condition) { return nil; }
    return  ([_condition.meaning isEqualToString:[TMWRuleCondition meaningForTemperature]]) ? @"Temperature"  :
            ([_condition.meaning isEqualToString:[TMWRuleCondition meaningForHumidity]])    ? @"Humidity"     :
            ([_condition.meaning isEqualToString:[TMWRuleCondition meaningForProximity]])   ? @"Proximity"    :
            ([_condition.meaning isEqualToString:[TMWRuleCondition meaningForLight]])       ? @"Brightness"   :
            ([_condition.meaning isEqualToString:[TMWRuleCondition meaningForNoise]])       ? @"Noise"        : nil;
}

- (UIImage*)icon
{
    if (!_condition) { return nil; }
    return  ([_condition.meaning isEqualToString:[TMWRuleCondition meaningForTemperature]]) ? [UIImage imageNamed:@"IconTemperature"] :
            ([_condition.meaning isEqualToString:[TMWRuleCondition meaningForHumidity]])    ? [UIImage imageNamed:@"IconHumidity"]    :
            ([_condition.meaning isEqualToString:[TMWRuleCondition meaningForProximity]])   ? [UIImage imageNamed:@"IconProximity"]   :
            ([_condition.meaning isEqualToString:[TMWRuleCondition meaningForLight]])       ? [UIImage imageNamed:@"IconLight"]       :
            ([_condition.meaning isEqualToString:[TMWRuleCondition meaningForNoise]])       ? [UIImage imageNamed:@"IconNoise"]       : nil;
}

- (NSString*)thresholdDescription
{
    NSNumber* value = _condition.valueConverted;
    if (!value) { return @"N/A"; }
    return [NSString stringWithFormat:@"%@ %@ %.1f %@", self.type, _condition.operation, value.floatValue, _condition.unit];
}

- (RelayrTransmitter*)transmitter
{
    if (!_transmitterID.length) { return nil; }
    
    RelayrTransmitter* result;
    for (RelayrTransmitter* transmitter in [TMWStore sharedInstance].relayrUser.transmitters)
    {
        if ([transmitter.uid isEqualToString:_transmitterID]) { result = transmitter; break; }
    }
    return result;
}

- (RelayrDevice*)device
{
    RelayrTransmitter* transmitter = self.transmitter;
    if (!transmitter) { return nil; }
    
    RelayrDevice* matchedDevice;
    for (RelayrDevice* device in transmitter.devices)
    {
        if ([device.uid isEqualToString:_deviceID]) {  matchedDevice = device; break; }
    }
    
    return matchedDevice;
}

#pragma mark NSObject

- (NSString*)description
{
    return [NSString stringWithFormat:@"\n{\n\tID: %@\n\tRevision: %@\n\tUserID: %@\n\tTransmitterID: %@\n\tDeviceID: %@\n\tName: %@\n\tLast modified: %@\n\tCondition: %@\n\tNum devices receiving push notifications: %lu\n\tActive: %@\n}\n", _uid, _revisionString, _userID, _transmitterID, _deviceID, _name, _modified, _condition, (unsigned long)_notifications.count, (_active) ? @"Yes" : @"No"];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initWithUserID:[decoder decodeObjectForKey:kCodingUserID]];
    if (self)
    {
        _uid = [decoder decodeObjectForKey:kCodingID];
        _revisionString = [decoder decodeObjectForKey:kCodingRevision];
        _transmitterID = [decoder decodeObjectForKey:kCodingTransID];
        _deviceID = [decoder decodeObjectForKey:kCodingDevID];
        _name = [decoder decodeObjectForKey:kCodingName];
        _modified = [decoder decodeObjectForKey:kCodingModified];
        _condition = [decoder decodeObjectForKey:kCodingCondition];
        NSArray* tmpNotifs = [decoder decodeObjectForKey:kCodingNotifs];
        if (tmpNotifs.count) { [_notifications addObjectsFromArray:tmpNotifs]; }
        _active = [decoder decodeBoolForKey:kCodingActive];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_userID forKey:kCodingUserID];
    [coder encodeObject:_uid forKey:kCodingID];
    [coder encodeObject:_revisionString forKey:kCodingRevision];
    [coder encodeObject:_transmitterID forKey:kCodingTransID];
    [coder encodeObject:_deviceID forKey:kCodingDevID];
    [coder encodeObject:_name forKey:kCodingName];
    [coder encodeObject:_modified forKey:kCodingModified];
    [coder encodeObject:_condition forKey:kCodingCondition];
    [coder encodeObject:[NSArray arrayWithArray:_notifications] forKey:kCodingNotifs];
    [coder encodeBool:_active forKey:kCodingActive];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone*)zone
{
    TMWRule* rule = [[TMWRule alloc] initWithUserID:_userID];
    rule.uid = _uid;
    rule.revisionString = _revisionString;
    rule.transmitterID = _transmitterID;
    rule.deviceID = _deviceID;
    rule.name = _name;
    rule.modified = _modified.copy;
    rule.condition = _condition.copy;
    rule.notifications = _notifications.mutableCopy;
    rule.active = _active;
    return rule;
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

+ (BOOL)synchronizeStoredRules:(NSMutableArray*)coreRules withNewlyArrivedRules:(NSArray*)rules resultingInCellsIndexPathsToAdd:(NSArray**)addingCellIndexPaths cellsIndexPathsToRemove:(NSArray**)removingCellsIndexPaths cellsIndexPathsToReload:(NSArray**)reloadingCellIndexPaths
{
    if (!rules.count)
    {
        *addingCellIndexPaths = nil;
        *removingCellsIndexPaths = [TMWRule arrayIndexPaths:coreRules inSection:0];
        *reloadingCellIndexPaths = nil;
        [coreRules removeAllObjects];
        return (*removingCellsIndexPaths) ? YES : NO;
    }
    else if (!coreRules.count)
    {
        [coreRules addObjectsFromArray:rules];
        *addingCellIndexPaths = [TMWRule arrayIndexPaths:rules inSection:0];
        *removingCellsIndexPaths = nil;
        *reloadingCellIndexPaths = nil;
        return (*addingCellIndexPaths) ? YES : NO;
    }
    
    __block NSMutableArray* coreRulesToRemove;
    __block NSMutableArray* indexPathsToRemove;
    __block NSMutableArray* indexPathsToReplace;
    NSMutableArray* serverRules = [NSMutableArray arrayWithArray:rules];
    [coreRules enumerateObjectsUsingBlock:^(TMWRule* cRule, NSUInteger idx, BOOL* stop) {
        TMWRule* matchedRule;
        for (TMWRule* sRule in serverRules)
        {
            if ([cRule.uid isEqualToString:sRule.uid])
            {
                matchedRule = sRule;
                if (![cRule isEqualDeeplyTo:sRule])
                {
                    [cRule setWith:sRule];
                    if (!indexPathsToReplace) { indexPathsToReplace = [[NSMutableArray alloc] init]; }
                    [indexPathsToReplace addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                }
                break;
            }
        }
        
        if (!matchedRule)
        {
            if (!indexPathsToRemove) { indexPathsToRemove = [[NSMutableArray alloc] init]; }
            [indexPathsToRemove addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
            
            if (!coreRulesToRemove) { coreRulesToRemove = [[NSMutableArray alloc] init]; }
            [coreRulesToRemove addObject:cRule];
        }
        else { [serverRules removeObject:matchedRule]; }
    }];
    
    [coreRules removeObjectsInArray:coreRulesToRemove];
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
        *addingCellIndexPaths = (indexPathsToAdd.count) ? indexPathsToAdd.copy : nil;
    }
    
    return ((*reloadingCellIndexPaths).count || (*addingCellIndexPaths).count || (*removingCellsIndexPaths).count) ? YES : NO;
}

#pragma mark - Private Methods

- (NSArray*)compressNotificationsIntoJSONArray
{
    if (!_notifications.count) { return nil; }
    
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:_notifications.count];
    for (TMWRuleNotification *notification in _notifications)
    {
        NSString* hexString = [notification.deviceToken hexadecimalString];
        if (!notification.type.length || !hexString) { continue; }
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
    return [NSArray arrayWithArray:result];
}

@end
