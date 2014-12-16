#import "TMWRuleNamingController.h"

#import "TMWStore.h"                        // TMW (Model)
#import "TMWRule.h"                         // TMW (Model)
#import "TMWAPIService.h"                   // TMW (Model)
#import "TMWStoryboardIDs.h"                // TMW (ViewControllers/Segues)
#import "TMWSegueUnwindingRules.h"          // TMW (ViewControllers/Segues)
#import "TMWButton.h"                       // TMW (Views)

@interface TMWRuleNamingController () <TMWSegueUnwindingRules,UITextFieldDelegate>
@property (strong,nonatomic) IBOutlet UITextField* textField;
- (IBAction)doneButtonTapped:(TMWButton*)sender;
@end

@implementation TMWRuleNamingController

#pragma mark - Public API

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_rule.name) { _textField.text = _rule.name; }
    [_textField becomeFirstResponder];
}

#pragma mark UIViewController methods

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [self doneButtonTapped:nil];
    return NO;
}

#pragma mark - Private functionality

- (IBAction)backButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:TWMStoryboardIDs_UnwindFromRuleNaming sender:self];
}

#pragma mark Navigation functionality

- (IBAction)doneButtonTapped:(TMWButton*)sender
{
    if (!_textField.text.length) { return; }
    
    if (!_needsServerModification)
    {
        _rule.name = _textField.text;
        _rule.active = YES;
        
        NSData* deviceToken = [TMWStore sharedInstance].deviceToken;
        [_rule setNotificationsWithDeviceToken:deviceToken previousDeviceToken:deviceToken];
        
        [TMWAPIService registerRule:_rule completion:^(NSError* error) {
            if (error) { return; }
            
            [_textField resignFirstResponder];
            [self performSegueWithIdentifier:TMWStoryboardIDs_UnwindFromRuleNamingToList sender:self];
        }];
    }
    else
    {
        if ([_rule.name isEqualToString:_textField.text]) { [self performSegueWithIdentifier:TWMStoryboardIDs_UnwindFromRuleNaming sender:self]; }
        
        NSString* previousName = _rule.name;
        _rule.name = _textField.text;
        
        __weak TMWRuleNamingController* weakSelf = self;
        [TMWAPIService setRule:_rule completion:^(NSError* error) {
            if (error) { weakSelf.rule.name = previousName; return; }
            
            [weakSelf.textField resignFirstResponder];
            [weakSelf performSegueWithIdentifier:TWMStoryboardIDs_UnwindFromRuleNaming sender:weakSelf];
        }];
    }
}
@end
