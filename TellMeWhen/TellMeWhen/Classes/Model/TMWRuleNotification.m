#import "TMWRuleNotification.h" // Headers
#import "NSString+Hexadecimal.h" // TMW (Common/Utilities)

#pragma mark Definitions

#define TMWRule_Notif_Type @"type"
#define TMWRule_Notif_Key  @"key"

NSString* const TMWRuleNotificationTypeAPNS  = @"apns";
NSString* const TMWRuleNotificationTypeGCM   = @"gcm";
NSString* const TMWRuleNotificationTypeEmail = @"email";

@implementation TMWRuleNotification

- (instancetype)initWithDeviceToken:(NSData*)deviceToken
{
    if (!deviceToken.length) { return nil; }
    
    self = [super init];
    if (self)
    {
        _type = TMWRuleNotificationTypeAPNS;
        _deviceToken = deviceToken;
    }
    return self;
}

- (instancetype)initWithJSONDictionary:(NSDictionary*)jsonDictionary
{
    if (!jsonDictionary.count) { return nil; }
    
    self = [super init];
    if (self)
    {
        _type = jsonDictionary[TMWRule_Notif_Type];
        NSString *deviceToken = jsonDictionary[TMWRule_Notif_Key];
        if (deviceToken) { _deviceToken = [NSString dataFromHexString:deviceToken]; }
    }
    return self;
}

- (NSDictionary *)compressIntoJSONDictionary
{
    if (!_type) { return nil; }
    
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    result[TMWRule_Notif_Type] = _type;
    if (_deviceToken) { result[TMWRule_Notif_Key] = _deviceToken; }
    return [NSDictionary dictionaryWithDictionary:result];
}

@end
