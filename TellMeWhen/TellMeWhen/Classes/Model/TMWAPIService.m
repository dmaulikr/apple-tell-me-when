#import <Relayr/Relayr.h>   // Relayr.framework

#import "TMWAPIService.h"   // Header
#import "TMWRule.h"         // TMW (Common/Models)
#import "TMWNotification.h" // TMW (Common/Models)


#define TMWAPIService_Rules_Username @"relayr"
#define TMWAPIService_Rules_Password @"1derBar_CL"
//#define TMWAPIService_Rules_Username @"onsiondishisferieverinki"
//#define TMWAPIService_Rules_Password @"suxme2tPBNUVF4ChaSAytDHr"

#define TMWAPIService_Notifications_Username @"relayr"
#define TMWAPIService_Notifications_Password @"1derBar_CL"
//#define TMWAPIService_Notifications_Username @"inglestonnothosespardste"
//#define TMWAPIService_Notifications_Password @"t1CcnnGVU2mD6ucVCbXtYqvQ"

#define TMWAPIService_HeaderField_Authorization @"Authorization"
#define TMWAPIService_HeaderField_Content @"Content-Type"
#define TMWAPIService_HeaderField_Content_JSON @"application/json"

//#define TMWAPIService_Host_Rules @"https://relayr.cloudant.com/marcos_rules"
#define TMWAPIService_Host_Rules @"https://relayr.cloudant.com/tellmewhen_rules"
#define TMWAPIService_Relative_RulesGet @"/_find"
#define TMWAPIService_Relative_RulesModify(ruleID, revisionID) [NSString stringWithFormat:@"/%@?rev=%@", ruleID, revisionID]
#define TMWAPIService_Relative_RulesDelete(ruleID, revisionID) [NSString stringWithFormat:@"/%@?rev=%@", ruleID, revisionID]

//#define TMWAPIService_Host_Notifications @"https://relayr.cloudant.com/marcos_notifications"
#define TMWAPIService_Host_Notifications @"https://relayr.cloudant.com/tellmewhen_notifications"
#define TMWAPIService_Relative_NotifGet @"/_find"
#define TMWAPIService_Relative_NotifDelete @"/_bulk_docs"

#define TMWAPI_RulesCreate_ResponseOK @"ok"
#define TMWAPI_RulesCreate_ResponseID @"id"
#define TMWAPI_RulesCreate_ResponseRevision @"rev"
#define TMWAPI_RulesGet_ResponseDoc @"docs"

#define TMWAPI_NotificationsGet_ResponseDocs TMWAPI_RulesGet_ResponseDoc
#define TMWAPI_NotificationsDelete_RequestDocs TMWAPI_RulesGet_ResponseDoc
#define TMWAPI_NotificationsDelete_RequestID @"_id"
#define TMWAPI_NotificationsDelete_RequestRev @"_rev"
#define TMWAPI_NotificationsDelete_RequestDelet @"_deleted"


// WebRequests methods
NSString *const kTMWAPIRequestModeGET = @"GET";
NSString *const kTMWAPIRequestModePOST = @"POST";
NSString *const kTMWAPIRequestModePUT = @"PUT";
NSString *const kTMWAPIRequestModeDELETE = @"DELETE";

NSString *kTMWAPIAuthorizationRules;
NSString *kTMWAPIAuthorizationNotifications;


@implementation TMWAPIService


#pragma mark - Public API

+ (void)initialize
{
    NSString *authRules = [NSString stringWithFormat:@"%@:%@", TMWAPIService_Rules_Username, TMWAPIService_Rules_Password];
    kTMWAPIAuthorizationRules = [NSString stringWithFormat:@"Basic %@", [[authRules dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    
    NSString *authNotif = [NSString stringWithFormat:@"%@:%@", TMWAPIService_Notifications_Username, TMWAPIService_Notifications_Password];
    kTMWAPIAuthorizationNotifications = [NSString stringWithFormat:@"Basic %@", [[authNotif dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
}

+ (void)registerRule:(TMWRule *)rule completion:(void (^)(NSError *error))completion
{
    NSDictionary *bodyDict = [rule compressIntoJSONDictionary];
    if (!bodyDict) {
        if (completion) {
            completion(RelayrErrorMissingArgument);
        } return;
    }
    
    __autoreleasing NSError *error;
    NSData *bodyData = [NSJSONSerialization  dataWithJSONObject:bodyDict options:kNilOptions error:&error];
    if (error || !bodyData) {
        if (completion) {
            completion((error) ? error : RelayrErrorUnknwon);
        } return;
    }
    
    NSURL *absoluteURL = [NSURL URLWithString:TMWAPIService_Host_Rules];
    NSMutableURLRequest *request = [TMWAPIService requestForURL:absoluteURL HTTPMethod:kTMWAPIRequestModePOST];
    [request setValue:kTMWAPIAuthorizationRules forHTTPHeaderField:TMWAPIService_HeaderField_Authorization];
    [request setValue:TMWAPIService_HeaderField_Content_JSON forHTTPHeaderField:TMWAPIService_HeaderField_Content];
    request.HTTPBody = bodyData;
    
    NSURLSessionDataTask *task = [[TMWAPIService sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = (!error && ((NSHTTPURLResponse *)response).statusCode == 201 && data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (!json) {
            if (completion) {
                completion((error) ? error : RelayrErrorWebRequestFailure);
            }
            return;
        }
        if ( !((NSNumber *)json[TMWAPI_RulesCreate_ResponseOK]).boolValue ) {
            if (completion) {
                completion((error) ? error : RelayrErrorUnknwon);
            }
            return;
        }
        
        rule.uid = json[TMWAPI_RulesCreate_ResponseID];
        rule.revisionString = json[TMWAPI_RulesCreate_ResponseRevision];
        if (completion) {
            completion(nil);
        }
    }];
    [task resume];
}

+ (void)requestRulesForUserID:(NSString *)userID completion:(void (^)(NSError *error, NSArray *rules))completion
{
    if (!completion) { return; }
    if (!userID.length) { return completion(RelayrErrorMissingArgument, nil); }
    
    __autoreleasing NSError *error;
    NSData* bodyData = [NSJSONSerialization dataWithJSONObject:@{ @"selector" : @{ @"user_id" : userID } } options:kNilOptions error:&error];
    if (error) { return completion(error, nil); }
    
    NSURL *absoluteURL = [TMWAPIService buildAbsoluteURLFromHost:TMWAPIService_Host_Rules relativeString:TMWAPIService_Relative_RulesGet];
    NSMutableURLRequest *request = [TMWAPIService requestForURL:absoluteURL HTTPMethod:kTMWAPIRequestModePOST];
    [request setValue:kTMWAPIAuthorizationRules forHTTPHeaderField:TMWAPIService_HeaderField_Authorization];
    [request setValue:TMWAPIService_HeaderField_Content_JSON forHTTPHeaderField:TMWAPIService_HeaderField_Content];
    request.HTTPBody = bodyData;
    
    NSURLSessionDataTask *task = [[TMWAPIService sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = (!error && ((NSHTTPURLResponse *)response).statusCode == 200 && data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (!json) {
            return completion((error) ? error : RelayrErrorWebRequestFailure, nil);
        }
        
        NSArray *jsonRules = json[TMWAPI_RulesGet_ResponseDoc];
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:jsonRules.count];
        for (NSDictionary *dict in jsonRules) {
            TMWRule *rule = [[TMWRule alloc] initWithJSONDictionary:dict];
            if (rule) { [result addObject:rule]; }
        }
        
        completion(nil, [NSArray arrayWithArray:result]);
    }];
    [task resume];
}

+ (void)setRule:(TMWRule *)rule completion:(void (^)(NSError *error))completion
{
    NSDictionary* bodyDict = [rule compressIntoJSONDictionary];
    if (!bodyDict || !rule.uid.length || !rule.revisionString.length) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    __autoreleasing NSError *error;
    NSData* bodyData = [NSJSONSerialization  dataWithJSONObject:bodyDict options:kNilOptions error:&error];
    if (error || !bodyData) { if (completion) { completion((error) ? error : RelayrErrorUnknwon); } return; }
    
    NSURL* absoluteURL = [TMWAPIService buildAbsoluteURLFromHost:TMWAPIService_Host_Rules relativeString:TMWAPIService_Relative_RulesModify(rule.uid, rule.revisionString)];
    NSMutableURLRequest* request = [TMWAPIService requestForURL:absoluteURL HTTPMethod:kTMWAPIRequestModePUT];
    [request setValue:kTMWAPIAuthorizationRules forHTTPHeaderField:TMWAPIService_HeaderField_Authorization];
    [request setValue:TMWAPIService_HeaderField_Content_JSON forHTTPHeaderField:TMWAPIService_HeaderField_Content];
    request.HTTPBody = bodyData;
    
    NSURLSessionDataTask* task = [[TMWAPIService sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary* json = (!error && ((NSHTTPURLResponse *)response).statusCode == 201 && data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (!json) { if (completion) { completion((error) ? error : RelayrErrorWebRequestFailure); } return; }
        if ( !((NSNumber *)json[TMWAPI_RulesCreate_ResponseOK]).boolValue ) { if (completion) { completion((error) ? error : RelayrErrorUnknwon); } return; }
        
        rule.uid = json[TMWAPI_RulesCreate_ResponseID];
        rule.revisionString = json[TMWAPI_RulesCreate_ResponseRevision];
        if (completion) { completion(nil); }
    }];
    [task resume];
}

+ (void)deleteRule:(TMWRule *)rule completion:(void (^)(NSError * error))completion
{
    if (!rule) { if (completion) { completion(RelayrErrorMissingArgument); } return; }
    
    NSURL *absoluteURL = [TMWAPIService buildAbsoluteURLFromHost:TMWAPIService_Host_Rules relativeString:TMWAPIService_Relative_RulesDelete(rule.uid, rule.revisionString)];
    NSMutableURLRequest *request = [TMWAPIService requestForURL:absoluteURL HTTPMethod:kTMWAPIRequestModeDELETE];
    [request setValue:kTMWAPIAuthorizationRules forHTTPHeaderField:TMWAPIService_HeaderField_Authorization];
    
    NSURLSessionDataTask *task = [[TMWAPIService sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = (!error && ((NSHTTPURLResponse *)response).statusCode == 200 && data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (!json) {
            if (completion) {
                completion((error) ? error : RelayrErrorWebRequestFailure);
            }
            return;
        }
        if ( !((NSNumber *)json[TMWAPI_RulesCreate_ResponseOK]).boolValue ) {
            if (completion) {
                completion((error) ? error : RelayrErrorUnknwon);
            }
            return;
        }
        
        if (completion) {
            completion(nil);
        }
    }];
    [task resume];
}

+ (void)requestNotificationsForRuleID:(NSString *)ruleID completion:(void (^)(NSError *error, NSArray *notifications))completion
{
    if (!completion) {
        return;
    }
    if (!ruleID.length) {
        return completion(RelayrErrorMissingArgument, nil);
    }
    
    __autoreleasing NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:@{ @"selector" : @{ @"rule_id" : ruleID } } options:kNilOptions error:&error];
    if (error) {
        return completion(error, nil);
    }
    
    NSURL *absoluteURL = [TMWAPIService buildAbsoluteURLFromHost:TMWAPIService_Host_Notifications relativeString:TMWAPIService_Relative_NotifGet];
    NSMutableURLRequest *request = [TMWAPIService requestForURL:absoluteURL HTTPMethod:kTMWAPIRequestModePOST];
    [request setValue:kTMWAPIAuthorizationRules forHTTPHeaderField:TMWAPIService_HeaderField_Authorization];
    [request setValue:TMWAPIService_HeaderField_Content_JSON forHTTPHeaderField:TMWAPIService_HeaderField_Content];
    request.HTTPBody = bodyData;
    
    NSURLSessionDataTask *task = [[TMWAPIService sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = (!error && ((NSHTTPURLResponse *)response).statusCode==200 && data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (!json) {
            return completion((error) ? error : RelayrErrorWebRequestFailure, nil);
        }
        
        NSArray *jsonRules = json[TMWAPI_NotificationsGet_ResponseDocs];
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:jsonRules.count];
        for (NSDictionary *dict in jsonRules) {
            TMWNotification *notif = [[TMWNotification alloc] initWithJSONDictionary:dict];
            if (notif) {
                [result addObject:notif];
            }
        }
        
        completion(nil, [NSArray arrayWithArray:result]);
    }];
    [task resume];
}

+ (void)requestNotificationsForUserID:(NSString *)userID completion:(void (^)(NSError *error, NSArray *notifications))completion
{
    if (!completion) {
        return;
    }
    if (!userID.length) {
        return completion(RelayrErrorMissingArgument, nil);
    }
    
    __autoreleasing NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:@{ @"selector" : @{ @"user_id" : userID } } options:kNilOptions error:&error];
    if (error) {
        return completion(error, nil);
    }
    
    NSURL *absoluteURL = [TMWAPIService buildAbsoluteURLFromHost:TMWAPIService_Host_Notifications relativeString:TMWAPIService_Relative_NotifGet];
    NSMutableURLRequest *request = [TMWAPIService requestForURL:absoluteURL HTTPMethod:kTMWAPIRequestModePOST];
    [request setValue:kTMWAPIAuthorizationRules forHTTPHeaderField:TMWAPIService_HeaderField_Authorization];
    [request setValue:TMWAPIService_HeaderField_Content_JSON forHTTPHeaderField:TMWAPIService_HeaderField_Content];
    request.HTTPBody = bodyData;
    
    NSURLSessionDataTask *task = [[TMWAPIService sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *json = (!error && ((NSHTTPURLResponse *)response).statusCode==200 && data) ? [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] : nil;
        if (!json) {
            return completion((error) ? error : RelayrErrorWebRequestFailure, nil);
        }
        
        NSArray *jsonRules = json[TMWAPI_NotificationsGet_ResponseDocs];
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:jsonRules.count];
        for (NSDictionary *dict in jsonRules) {
            TMWNotification *notif = [[TMWNotification alloc] initWithJSONDictionary:dict];
            if (notif) {
                [result addObject:notif];
            }
        }
        
        completion(nil, [NSArray arrayWithArray:result]);
    }];
    [task resume];
}

+ (void)deleteNotifications:(NSArray *)notifications completion:(void (^)(NSError *))completion
{
    if (!notifications.count) {
        if (completion) {
            completion(RelayrErrorMissingArgument);
        }
        return;
    }
    
    NSMutableArray *docs = [[NSMutableArray alloc] initWithCapacity:notifications.count];
    for (TMWNotification *notif in notifications) {
        if (!notif.uid.length || !notif.revisionString.length) {
            continue;
        }
        [docs addObject:@{ TMWAPI_NotificationsDelete_RequestID  : notif.uid, TMWAPI_NotificationsDelete_RequestRev   : notif.revisionString,TMWAPI_NotificationsDelete_RequestDelet : [NSNumber numberWithBool:YES]
        }];
    }
    
    __autoreleasing NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:@{ TMWAPI_NotificationsDelete_RequestDocs : docs } options:kNilOptions error:&error];
    if (error) {
        if (completion) {
            completion(error);
        }
        return;
    }
    
    NSURL *absoluteURL = [TMWAPIService buildAbsoluteURLFromHost:TMWAPIService_Host_Notifications relativeString:TMWAPIService_Relative_NotifDelete];
    NSMutableURLRequest *request = [TMWAPIService requestForURL:absoluteURL HTTPMethod:kTMWAPIRequestModePOST];
    [request setValue:kTMWAPIAuthorizationRules forHTTPHeaderField:TMWAPIService_HeaderField_Authorization];
    [request setValue:TMWAPIService_HeaderField_Content_JSON forHTTPHeaderField:TMWAPIService_HeaderField_Content];
    request.HTTPBody = bodyData;
    
    NSURLSessionDataTask *task = [[TMWAPIService sharedSession] dataTaskWithRequest:request completionHandler:(!completion) ? nil : ^(NSData *data, NSURLResponse *response, NSError *error) {
        completion( (((NSHTTPURLResponse *)response).statusCode==201) ? nil : RelayrErrorWebRequestFailure);
    }];
    [task resume];
}


#pragma mark - Private functionality

+ (NSURLSession*)sharedSession
{
    static NSURLSession* session;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration* sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfiguration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
        sessionConfiguration.HTTPCookieStorage = nil;
        sessionConfiguration.HTTPShouldSetCookies = NO;
        // sessionConfiguration.TLSMinimumSupportedProtocol = kTLSProtocol12;
        sessionConfiguration.networkServiceType = NSURLNetworkServiceTypeDefault;
        sessionConfiguration.allowsCellularAccess = YES;
        sessionConfiguration.HTTPShouldUsePipelining = YES;
        session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    });
    
    return session;
}

+ (NSURL *)buildAbsoluteURLFromHost:(NSString*)hostString relativeString:(NSString*)relativePath
{
    NSString* result = (hostString) // FIXME: Don't nest the ternery operator: it's not particularly readable
        ? (relativePath.length) ? [hostString stringByAppendingString:relativePath] : hostString
        : (relativePath.length) ? relativePath : nil;
    return [NSURL URLWithString:[result stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSMutableURLRequest *)requestForURL:(NSURL*)absoluteURL HTTPMethod:(NSString*)httpMode
{
    if (!absoluteURL || !httpMode.length) {
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:absoluteURL];
    if (!request) {
        return nil;
    }
    
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    request.HTTPShouldHandleCookies = NO;
    request.HTTPMethod = httpMode;
    return request;
}

@end
