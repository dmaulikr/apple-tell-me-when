#import "TMWManager.h"      // Header
#import "TMWCredentials.h"

#define RelayrTMW_FSFolder                  @"/io.relayr.tmw"

@interface TMWManager () <NSCoding>
@end

static NSString* kPersistanceLocation;
static NSString* const kCodingNotifications = @"notif";
static NSString* const kCodingDeviceToken = @"devTo";

@implementation TMWManager

+ (instancetype)sharedInstance {
    static TMWManager* sharedInstance;
    
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

- (void)signOut {
    _relayrUser = nil;
    [_relayrApp signOutUser:_relayrUser];
}

- (void)fetchUsersWunderbars {
    [_relayrUser queryCloudForIoTs:^(NSError *error) {
        if (!error) {
            self.wunderbars = [_relayrUser.transmitters allObjects];
        }
    }];
}

- (BOOL)persistInFileSystem
{
    [RelayrApp persistAppInFileSystem:_relayrApp];
    
    TMWManager* tmwManager = [TMWManager sharedInstance];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* path = kPersistanceLocation;
    if (!tmwManager || !fileManager || !path.length) { return NO; }
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
    if (!data) { return NO; }
    
    return [fileManager createFileAtPath:path contents:data attributes:nil];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (self)
    {
        _apnsToken = [decoder decodeObjectForKey:kCodingDeviceToken];
        NSArray* notifications = [decoder decodeObjectForKey:kCodingNotifications];
        if (notifications) { _notifications = [NSMutableArray arrayWithArray:notifications]; }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:_apnsToken forKey:kCodingDeviceToken];
    if (_notifications) { [coder encodeObject:[NSArray arrayWithArray:_notifications] forKey:kCodingNotifications]; }
}

@end
