@import Foundation;     // Apple
#import "TMWRule.h"     // TMW (Common/Models)

@interface TMWAPIService : NSObject

/*!
 *  @abstract It creates a rule in Cloudant database.
 *
 *  @param rule <code>TMWRule</code> object specifying the attributes to write on the database.
 *  @param completion Block indicating the result of the server query.
 */
+ (void)registerRule:(TMWRule*)rule completion:(void (^)(NSError* error))completion;

/*!
 *  @abstract It returns on the completion block all the rules of a specific Relayr User.
 *  @discussion The completion parameter is required for this message to perform any work.
 *
 *  @param user Relayr Identifier specifying a Relayr User.
 *  @param completion Block indicating the result of the server query.
 */
+ (void)requestRulesForUserID:(NSString*)userID completion:(void (^)(NSError* error, NSArray* rules))completion;

/*!
 *  @abstract It modifies an existing rule on the Cloudant database.
 *
 *  @param rule <code>TMWRule</code> object specifying the attributes to modify on the database.
 *  @param completion Block indicating the result of the server query.
 */
+ (void)setRule:(TMWRule*)rule completion:(void (^)(NSError* error))completion;

/*!
 *  @abstract It removes an existing rule on the Cloudant database.
 *
 *  @param rule <code>TMWRule</code> to delete. The only attribute needed is the RuleID.
 *  @param completion Block indicating the result of the server query.
 */
+ (void)deleteRule:(TMWRule*)rule completion:(void (^)(NSError* error))completion;

/*!
 *  @abstract It returns on the completion block all the notifications of a specific Rule.
 *
 *  @param ruleID <code>NSString</code> representing a Rule ID.
 *  @param completion Block indicating the result of the server query.
 */
+ (void)requestNotificationsForRuleID:(NSString*)ruleID completion:(void (^)(NSError* error, NSArray* notifications))completion;

/*!
 *  @abstract It returns on the completion block all the notifications of a specific User.
 *
 *  @param userID <code>NSString</code> representing a User ID.
 *  @param completion Block indicating the result of the server query.
 */
+ (void)requestNotificationsForUserID:(NSString *)userID completion:(void (^)(NSError *error, NSArray *notifications))completion;

/*!
 *  @abstract It removes all the notifications passed on the array.
 *
 *  @param Array with <code>TMWNotification</code> objects. The rules must contain an <code>uid</code> and a <code>revisionString</code> or they won't be deleted.
 *  @param completion Block indicating the result of the server query.
 */
+ (void)deleteNotifications:(NSArray*)notifications completion:(void (^)(NSError* error))completion;

@end
