#import <Relayr/Relayr.h>

#import "SignInViewController.h" // Headers
#import "TMWManager.h"
#import "TMWCredentials.h"

static NSString *const kWebHostURI = @"https://api.relayr.io";
static NSString *const kReachabilityAlertTitle = @"The relayr cloud is not reachable";
static NSString *const kReachabilityAlertMessage = @"It has not been possible to connect with the relayr cloud. Please check that your device is connected to the internet and try again. If you are connected to the internet please contact relayr support as there may be a problem with the cloud.";
static NSString *const kReachabilityAlertTryAgainActionTitle = @"Try Again";
static NSString *const kSignInErrorAlertTitle = @"An error has occurred";
static NSString *const kSignInErrorAlertOkActionTitle = @"OK";
static NSString *const kReachabilityLabelTextWhenReachable = @"The relayr cloud is reachable\nPlease sign in";


@interface SignInViewController ()
@property (strong, nonatomic) IBOutlet UIButton *signIn;
@property (strong, nonatomic) IBOutlet UILabel *reachabilityStatus;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *checkingReachability;
- (IBAction)signInPressed:(id)sender;
- (IBAction)unwindToSignInView:(UIStoryboardSegue *)segue;
@end


@implementation SignInViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - View Management

- (void)viewWillAppear:(BOOL)animated {
    _signIn.userInteractionEnabled = NO; // Disabled by default.
    _signIn.enabled = NO;
    
    SignInViewController* weakSelf = self;
    [RelayrCloud isReachable:^(NSError* error, NSNumber* isReachable) {
        SignInViewController* strongSelf = weakSelf;    if (!strongSelf) { return; }
        if (!isReachable.boolValue) { [strongSelf showReachabilityErrorAlert]; }
        
        if ([TMWManager sharedInstance].relayrApp)
        {
            if ([TMWManager sharedInstance].relayrUser)
            {
                [[TMWManager sharedInstance] fetchUsersWunderbars];
                return [self performSegueWithIdentifier:@"ShowTabView" sender:self];
            }
            else
            {
                [strongSelf.checkingReachability stopAnimating];
                strongSelf.signIn.userInteractionEnabled = YES;
                strongSelf.signIn.enabled = YES;
                strongSelf.reachabilityStatus.text = kReachabilityLabelTextWhenReachable;
            }
        }

        [RelayrApp appWithID:TMWCredentials_RelayrAppID OAuthClientSecret:TMWCredentials_ClientSecret redirectURI:TMWCredentials_RedirectURI completion:^(NSError *error, RelayrApp *app) {
            if (error) { return [self viewWillAppear:NO]; }     // TODO: Decide how to best handle this error
            [TMWManager sharedInstance].relayrApp = app;
            
            RelayrUser* user = [TMWManager sharedInstance].relayrApp.loggedUsers.firstObject;
            if (!user)
            {
                [strongSelf.checkingReachability stopAnimating];
                strongSelf.signIn.userInteractionEnabled = YES;
                strongSelf.signIn.enabled = YES;
                strongSelf.reachabilityStatus.text = kReachabilityLabelTextWhenReachable;
            }
            else
            {
                [TMWManager sharedInstance].relayrUser = user;
                [[TMWManager sharedInstance] fetchUsersWunderbars];
                [self performSegueWithIdentifier:@"ShowTabView" sender:self];
            }
        }];
    }];
}

- (IBAction)unwindToSignInView:(UIStoryboardSegue *)segue {
    NSLog(@"Unwind To Sign In View Called.");
}


#pragma mark - Actions

- (IBAction)signInPressed:(id)sender {
    _signIn.userInteractionEnabled = NO; // Prevent further presses
    [[TMWManager sharedInstance].relayrApp signInUser:^(NSError *error, RelayrUser *user) {
        if (!error) {
            [TMWManager sharedInstance].relayrUser = user;
            [[TMWManager sharedInstance] fetchUsersWunderbars];
            [self performSegueWithIdentifier:@"ShowTabView" sender:self];
        } else {
            UIAlertController* signInEerrorAlert = [UIAlertController alertControllerWithTitle:kSignInErrorAlertTitle message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:kSignInErrorAlertOkActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [signInEerrorAlert dismissViewControllerAnimated:YES completion:nil];
                _signIn.userInteractionEnabled = YES;
            }];
            [signInEerrorAlert addAction:ok];
            [self presentViewController:signInEerrorAlert animated:YES completion:nil];
        }
    }];
}


#pragma mark - Private Methods

- (void)showReachabilityErrorAlert {
    UIAlertController* reachabilityAlert = [UIAlertController alertControllerWithTitle:kReachabilityAlertTitle message:kReachabilityAlertMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* tryAgain = [UIAlertAction actionWithTitle:kReachabilityAlertTryAgainActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [reachabilityAlert dismissViewControllerAnimated:YES completion:nil];
        [self viewWillAppear:NO];
    }];
    [reachabilityAlert addAction:tryAgain];
    [self presentViewController:reachabilityAlert animated:YES completion:nil];
}

@end
