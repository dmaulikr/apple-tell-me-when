#import "TMWRuleNotification.h" // Headers
#import "NSString+Hexadecimal.h" // TMW (Common/Utilities)

#pragma mark Definitions

#define TMWRule_Notif_Type @"type"
#define TMWRule_Notif_Key  @"key"

NSString* const TMWRuleNotificationTypeAPNS  = @"apns";
NSString* const TMWRuleNotificationTypeGCM   = @"gcm";
NSString* const TMWRuleNotificationTypeEmail = @"email";

static NSString* const kCodingType           = @"typ";
static NSString* const kCodingDeviceToken    = @"devTok";

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
        NSString* deviceToken = jsonDictionary[TMWRule_Notif_Key];
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

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (self)
    {
        _type = [decoder decodeObjectForKey:kCodingType];
        _deviceToken = [decoder decodeObjectForKey:kCodingDeviceToken];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_type forKey:kCodingType];
    [coder encodeObject:_deviceToken forKey:kCodingDeviceToken];
}

@end
