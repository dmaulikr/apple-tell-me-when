#import "TMWStore.h"      // Header
#import "TMWCredentials.h"

#define RelayrTMW_FSFolder                  @"/io.relayr.tmw"

@interface TMWStore () <NSCoding>
@end

static NSString* kPersistanceLocation;
static NSString* const kCodingDeviceToken   = @"devTo";
static NSString* const kCodingRules         = @"rul";
static NSString* const kCodingNotifications = @"notif";

@implementation TMWStore

+ (instancetype)sharedInstance
{
    static TMWStore* sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        kPersistanceLocation = [(NSString*)paths.firstObject stringByAppendingPathComponent:RelayrTMW_FSFolder];
        
        sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithFile:kPersistanceLocation];
        if (sharedInstance)
        {
            RelayrApp* app = [RelayrApp retrieveAppWithIDFromFileSystem:TMWCredentials_RelayrAppID];
            if (app)
            {
                sharedInstance.relayrApp = app;
                sharedInstance.relayrUser = sharedInstance.relayrApp.loggedUsers.firstObject;
            }
        }
        else { sharedInstance = [[self alloc] initPrivately]; }
    });
    return sharedInstance;
}

+ (RelayrTransmitter*)transmitterWithID:(NSString*)transmitterID
{
    if (!transmitterID.length) { return nil; }
    
    RelayrTransmitter* result;
    for (RelayrTransmitter* transmitter in [TMWStore sharedInstance].relayrUser.transmitters)
    {
        if ([transmitterID isEqualToString:transmitter.uid]) { result = transmitter; break; }
    }
    return result;
}

#pragma mark - Public Methods

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)persistInFileSystem
{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
    if (!data) { return NO; }
    
    [RelayrApp persistAppInFileSystem:_relayrApp];
    return [[NSFileManager defaultManager] createFileAtPath:kPersistanceLocation contents:data attributes:nil];
}

- (BOOL)removeFromFileSystem
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ( ![manager fileExistsAtPath:kPersistanceLocation] ) { return YES; }
    return [manager removeItemAtPath:kPersistanceLocation error:nil];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [self initPrivately];
    if (self)
    {
        _deviceToken = [decoder decodeObjectForKey:kCodingDeviceToken];
        NSArray* tmp = [decoder decodeObjectForKey:kCodingRules];
        if (tmp.count) { [_rules addObjectsFromArray:tmp]; }
        tmp = [decoder decodeObjectForKey:kCodingNotifications];
        if (tmp.count) { [_notifications addObjectsFromArray:tmp]; }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_deviceToken forKey:kCodingDeviceToken];
    if (_rules.count) { [coder encodeObject:_rules.copy forKey:kCodingRules]; }
    if (_notifications.count) { [coder encodeObject:_notifications.copy forKey:kCodingNotifications]; }
}

#pragma mark - Private functionality

- (instancetype)initPrivately
{
    self = [super init];
    if (self) {
        _rules = [NSMutableArray array];
        _notifications = [NSMutableArray array];
    }
    return self;
}

@end
