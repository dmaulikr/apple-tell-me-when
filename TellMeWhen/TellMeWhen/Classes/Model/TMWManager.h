#import <Foundation/Foundation.h> // Apple
#import <Relayr/Relayr.h> // relayr

#import "TMWRule.h"


@interface TMWManager : NSObject

@property (strong, nonatomic) RelayrApp *relayrApp;
@property (strong, nonatomic) RelayrUser *relayrUser;
@property (strong, nonatomic) NSMutableArray *rules;
@property (strong, nonatomic) NSMutableArray *notifications;

@property (strong, nonatomic) TMWRule *ruleBeingEdited;
@property (strong, nonatomic) NSArray *wunderbars;
@property (strong, nonatomic) NSData *apnsToken;

+ (instancetype)sharedInstance;

- (void)signOut;
- (void)fetchUsersWunderbars;

- (BOOL)persistInFileSystem;

@end
