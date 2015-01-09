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

/*!
 *  @abstract It removes the notifications that doesn't have a matching rule.
 *  @discussion If there are changes into the notifications array, the returning boolean value will be marked as YES.
 *
 *	@return YES if there were changes on the notifications array. NO otherwise.
 */
- (BOOL)removeUnlinkedNotifications;

- (BOOL)persistInFileSystem;
- (BOOL)removeFromFileSystem;

@end
