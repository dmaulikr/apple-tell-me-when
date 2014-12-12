@import Foundation;         // Apple
#import <Relayr/Relayr.h>   // Relayr

@class TMWRuleCondition;

/*!
 *  @abstract A rule is a condition to be met by a stream of data (usually MQTT).
 */
@interface TMWRule : NSObject

- (instancetype)initWithUserID:(NSString *)userID;
- (instancetype)initWithJSONDictionary:(NSDictionary *)jsonDictionary;
- (NSDictionary *)compressIntoJSONDictionary;
- (NSArray*)setupNotificationsWithDeviceToken:(NSData*)deviceToken;

@property (strong, nonatomic) NSString* uid;
@property (strong, nonatomic) NSString* revisionString;
@property (readonly, nonatomic) NSString* userID;
@property (strong, nonatomic) NSString* transmitterID;
@property (strong, nonatomic) NSString* deviceID;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) TMWRuleCondition* condition;
@property (strong, nonatomic) NSArray* notifications;
@property (nonatomic) BOOL active;

@property (readonly, nonatomic) NSString* type;
@property (readonly, nonatomic) UIImage* icon;
@property (readonly, nonatomic) NSString* thresholdDescription;
@property (readonly, nonatomic) RelayrTransmitter* transmitter;

+ (TMWRule*)ruleForID:(NSString*)ruleID withinRulesArray:(NSArray*)rules;

+ (BOOL)synchronizeStoredRules:(NSMutableArray*)coreRules
         withNewlyArrivedRules:(NSMutableArray*)serverRules
resultingInCellsIndexPathsToAdd:(NSArray**)addingCellIndexPaths
       cellsIndexPathsToRemove:(NSArray**)removingCellsIndexPaths
       cellsIndexPathsToReload:(NSArray**)reloadingCellIndexPaths;

@end
