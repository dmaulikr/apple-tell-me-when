@import Foundation;     // Apple

@protocol TMWActions <NSObject>

@required
- (void)deviceTokenChangedFromData:(NSData*)fromData toData:(NSData*)toData;

@required
- (void)notificationDidArrived:(NSDictionary*)userInfo;

@optional
- (void)loadIoTsWithCompletion:(void (^)(NSError*))completion;

@optional
- (void)setupRulesAndNotifications;

@optional
- (IBAction)signoutFromSender:(id)sender;

@end
