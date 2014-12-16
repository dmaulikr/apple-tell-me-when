#import "TMWRuleNamingController.h"

#import "TMWStore.h"                        // TMW (Model)
#import "TMWRule.h"                         // TMW (Model)
#import "TMWStoryboardIDs.h"                // TMW (ViewControllers/Segues)
#import "TMWSegueUnwindingRules.h"          // TMW (ViewControllers/Segues)
#import "TMWButton.h"                       // TMW (Views)

@interface TMWRuleNamingController () <TMWSegueUnwindingRules,UITextFieldDelegate>
@property (readonly,nonatomic) NSString* segueIdentifierForUnwind;
@property (strong, nonatomic) IBOutlet UITextField* textField;
- (IBAction)doneButtonTapped:(TMWButton*)sender;
@end

@implementation TMWRuleNamingController

#pragma mark - Public API

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [self doneButtonTapped:nil];
    return NO;
}

#pragma mark - Private functionality

- (IBAction)backButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:self.segueIdentifierForUnwind sender:self];
}

#pragma mark Navigation functionality

- (NSString*)segueIdentifierForUnwind
{
    return (!_needsServerModification) ? TMWStoryboardIDs_UnwindFromRuleNamingToThresh : TMWStoryboardIDs_UnwindFromRuleNamingToSum;
}

- (IBAction)doneButtonTapped:(TMWButton*)sender
{
    if (!_textField.text.length) { return; }
    
    [_textField resignFirstResponder];
    [self performSegueWithIdentifier:TMWStoryboardIDs_UnwindFromRuleNamingToList sender:self];
}
@end
