#import "TMWStore.h"      // Header
#import "TMWCredentials.h"

#define RelayrTMW_FSFolder                  @"/io.relayr.tmw"

@interface TMWStore () <NSCoding>
@end

static NSString* kPersistanceLocation;
static NSString* const kCodingNotifications = @"notif";
static NSString* const kCodingDeviceToken = @"devTo";

@implementation TMWStore

+ (instancetype)sharedInstance {
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
        else { sharedInstance = [[self alloc] init]; }
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _rules = [NSMutableArray array];
        _notifications = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public Methods

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
    self = [self init];
    if (self)
    {
        _deviceToken = [decoder decodeObjectForKey:kCodingDeviceToken];
        NSArray* notifications = [decoder decodeObjectForKey:kCodingNotifications];
        if (notifications.count) { [_notifications addObjectsFromArray:notifications]; }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_deviceToken forKey:kCodingDeviceToken];
    if (_notifications) { [coder encodeObject:[NSArray arrayWithArray:_notifications] forKey:kCodingNotifications]; }
}

@end
