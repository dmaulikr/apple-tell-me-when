#import "TMWInitialController.h"    // Headers

#import "TMWStore.h"                // TMW (Model)
#import "TMWCredentials.h"          // TMW (Model)
#import "TMWMainController.h"       // TMW (ViewControllers)
#import "TMWStoryboardIDs.h"        // TMW (ViewControllers/Segues)

#pragma mark - Definitions

#define TMWInitialCntrll_Button_SignInText          @"sign in"
#define TMWInitialCntrll_Button_CheckReachability   @"check connection"

#define TMWInitialCntrll_Text_CheckingReach         @"Checking Relayr Servers reachability..."
#define TMWInitialCntrll_Text_Unreachable           @"It has not been possible to connect with the relayr cloud.\nPlease check that your device is connected to the internet and try again."
#define TMWInitialCntrll_Text_SignInAvailable       @"The relayr cloud is reachable.\nPlease sign in."
#define TMWInitialCntrll_Text_SigningIn             @"Signing in..."
#define TMWInitialCntrll_Text_SignInFailure         @"An error occurred when signing in. Please, try again..."

#define TMWInitialCntrll_ArtificialDelay            0.8
#define TMWInitialCntrll_TextToButton_Minimum       30.0
#define TMWInitialCntrll_TextToButton_Maximum       70.0

@interface TMWInitialController ()
@property (weak,nonatomic) IBOutlet UIButton* multipurposeButton;
@property (weak,nonatomic) IBOutlet UILabel* explanationLabel;
@property (weak,nonatomic) IBOutlet UIActivityIndicatorView* spinner;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *textToButtonConstraint;
@end

@implementation TMWInitialController

#pragma mark - Public API

- (void)deviceTokenChangedFromData:(NSData*)fromData toData:(NSData*)toData
{
    if (!toData) { return; }
    
    // TODO: Something must be done if the deviceToken change. Maybe, try to call the API.
    [TMWStore sharedInstance].deviceToken = toData;
}

- (void)notificationDidArrived:(NSDictionary*)userInfo
{
    // TODO: (Not important) Maybe show an indication that a notification has arrived.
}

#pragma mark UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reachabilityCheck];
}

- (void)updateViewConstraints
{
    _textToButtonConstraint.constant = (_spinner.hidden) ? TMWInitialCntrll_TextToButton_Minimum : TMWInitialCntrll_TextToButton_Maximum;
    [super updateViewConstraints];
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:TMWStoryboardIDs_SegueFromSignToMain])
    {
        TMWMainController* mainCntrll = ((TMWMainController*)segue.destinationViewController);
        [mainCntrll loadIoTsWithCompletion:^(NSError* error) {
            if (!error) { [mainCntrll loadRulesWithCompletion:nil]; }
        }];
    }
}

#pragma mark - Private functionality

- (IBAction)buttonPressed:(id)sender
{
    // Check first whether we want to check reachability again or we want to sign in (and hence we have internet).
    if ([_multipurposeButton.titleLabel.text isEqualToString:TMWInitialCntrll_Button_CheckReachability]) {
        [self reachabilityCheck];
    } else {
        [self signIn];
    }
}

- (void)reachabilityCheck
{
    _explanationLabel.text = TMWInitialCntrll_Text_CheckingReach;
    [_multipurposeButton setTitle:TMWInitialCntrll_Button_CheckReachability forState:UIControlStateNormal];
    _multipurposeButton.enabled = NO;
    [self hiddeSpinner:NO];
    
    TMWInitialController* weakSelf = self;
    [RelayrCloud isReachable:^(NSError* error, NSNumber* isReachable) {
        TMWInitialController* strongSelf = weakSelf; if (!strongSelf) { return; }
        if (!isReachable.boolValue)
        {
            return dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TMWInitialCntrll_ArtificialDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                strongSelf.explanationLabel.text = TMWInitialCntrll_Text_Unreachable;
                [_multipurposeButton setTitle:TMWInitialCntrll_Button_CheckReachability forState:UIControlStateNormal];
                strongSelf.multipurposeButton.enabled = YES;
                [strongSelf hiddeSpinner:YES];
            });
        }
        
        TMWStore* store = [TMWStore sharedInstance];
        if (store.relayrApp)
        {
            if (store.relayrUser) { return [strongSelf performSegueWithIdentifier:TMWStoryboardIDs_SegueFromSignToMain sender:strongSelf]; }
            
            strongSelf.explanationLabel.text = TMWInitialCntrll_Text_SignInAvailable;
            [_multipurposeButton setTitle:TMWInitialCntrll_Button_SignInText forState:UIControlStateNormal];
            strongSelf.multipurposeButton.enabled = YES;
            return [strongSelf hiddeSpinner:YES];
        }
        
        [RelayrApp appWithID:TMWCredentials_RelayrAppID OAuthClientSecret:TMWCredentials_ClientSecret redirectURI:TMWCredentials_RedirectURI completion:^(NSError* error, RelayrApp* app) {
            [strongSelf hiddeSpinner:YES];
            
            if (error)
            {
                strongSelf.explanationLabel.text = TMWInitialCntrll_Text_Unreachable;
                [_multipurposeButton setTitle:TMWInitialCntrll_Button_CheckReachability forState:UIControlStateNormal];
                strongSelf.multipurposeButton.enabled = YES;
                return;
            }
            
            store.relayrApp = app;
            strongSelf.explanationLabel.text = TMWInitialCntrll_Text_SignInAvailable;
            [_multipurposeButton setTitle:TMWInitialCntrll_Button_SignInText forState:UIControlStateNormal];
            strongSelf.multipurposeButton.enabled = YES;
        }];
    }];
}

- (void)signIn
{
    _explanationLabel.text = TMWInitialCntrll_Text_SigningIn;
    _multipurposeButton.enabled = NO;
    [self hiddeSpinner:NO];
    
    TMWInitialController* weakSelf = self;
    [[TMWStore sharedInstance].relayrApp signInUser:^(NSError* error, RelayrUser* user) {
        TMWInitialController* strongSelf = weakSelf;    if (!strongSelf) { return; }
        [strongSelf hiddeSpinner:YES];
        
        if (error)
        {
            strongSelf.explanationLabel.text = TMWInitialCntrll_Text_SignInFailure;
            [_multipurposeButton setTitle:TMWInitialCntrll_Button_SignInText forState:UIControlStateNormal];
            strongSelf.multipurposeButton.enabled = YES;
            return;
        }
        
        [TMWStore sharedInstance].relayrUser = user;
        [strongSelf performSegueWithIdentifier:TMWStoryboardIDs_SegueFromSignToMain sender:self];
    }];
}

- (void)hiddeSpinner:(BOOL)willHidden
{
    if (willHidden)
    {
        if (_spinner.hidden) { return; }
        [_spinner stopAnimating];
    }
    else
    {
        if (!_spinner.hidden) { return; }
        [_spinner startAnimating];
    }
    
    _spinner.hidden = willHidden;
    [self.view setNeedsUpdateConstraints];
}

@end
