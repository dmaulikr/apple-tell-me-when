#import "TMWNavRulesController.h"   // Header

#import "TMWStore.h"                // TMW (Model)
#import "TMWRule.h"                 // TMW (Model)
#import "TMWRuleNotification.h"     // TMW (Model)
#import "TMWAPIService.h"           // TMW (Model)
#import "TMWRulesController.h"      // TMW (ViewControllers/Rules)

@interface TMWNavRulesController ()
@property (readonly,nonatomic) TMWRulesController* rulesController;
@end

@implementation TMWNavRulesController

#pragma mark - Public API

- (void)queryRulesWithCompletion:(void (^)(NSError*))completion
{
    [self.rulesController queryRulesWithCompletion:completion];
}

- (void)deviceTokenChangedFromData:(NSData*)fromData toData:(NSData*)toData
{
    if ( (!toData && !fromData) || [toData isEqualToData:fromData]) { return; }
    
    TMWStore* store = [TMWStore sharedInstance];
    store.deviceToken = nil;
    
    for (TMWRule* rule in store.rules)
    {
        BOOL const needsCommitToServer = [rule setNotificationsWithDeviceToken:fromData previousDeviceToken:toData];
        if (!needsCommitToServer) { continue; }
        
        [TMWAPIService setRule:rule completion:^(NSError* error) {
            if (error) { NSLog(@"Error when trying to set up server rules' notifs with new device token."); }
            // TODO: Handle errors
        }];
    }
}

#pragma mark - Private functionality

- (TMWRulesController*)rulesController
{
    TMWRulesController* result;
    for (UIViewController* cntrll in self.childViewControllers)
    {
        if ([cntrll isKindOfClass:[TMWRulesController class]]) { result = (TMWRulesController*)cntrll; break; }
    }
    return result;
}

@end
