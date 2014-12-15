@import Foundation;         // Apple
#import "TMWRule.h"
#import <Relayr/Relayr.h>   // Relayr.framework

@interface TMWStore : NSObject

+ (instancetype)sharedInstance;

@property (strong,nonatomic) RelayrApp* relayrApp;
@property (weak,nonatomic) RelayrUser* relayrUser;
@property (strong,nonatomic) NSData* deviceToken;
@property (strong,nonatomic) NSMutableArray* rules;
@property (strong,nonatomic) NSMutableArray* notifications;

- (BOOL)persistInFileSystem;
- (BOOL)removeFromFileSystem;

@end
