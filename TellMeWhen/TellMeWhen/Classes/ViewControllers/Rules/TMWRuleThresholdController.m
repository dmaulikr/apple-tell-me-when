#import "TMWRuleThresholdController.h"      // Header

#import "TMWStore.h"                        // TMW (Model)
#import "TMWRule.h"                         // TMW (Model)
#import "TMWStoryboardIDs.h"                // TMW (ViewControllers/Segues)
#import "TMWSegueUnwindingRules.h"          // TMW (ViewControllers/Segues)
#import "TMWRuleNamingController.h"         // TMW (ViewControllers/Rules)

@interface TMWRuleThresholdController () <TMWSegueUnwindingRules>
@property (readonly,nonatomic) NSString* segueIdentifierForUnwind;
@end

@implementation TMWRuleThresholdController

#pragma mark - Public API

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark UIViewController methods

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:TMWStoryboardIDs_SegueFromRulesThreshToNaming])
    {
        ((TMWRuleNamingController*)segue.destinationViewController).rule = _rule;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (IBAction)backButtonTapped:(id)sender
{
    [self performSegueWithIdentifier:self.segueIdentifierForUnwind sender:self];
}

#pragma mark Navigation functionality

- (NSString*)segueIdentifierForUnwind
{
    return (!_needsServerModification) ? TMWStoryboardIDs_UnwindFromRuleThreshToMeasur : TMWStoryboardIDs_UnwindFromRuleThreshToSum;
}

- (IBAction)unwindFromRuleName:(UIStoryboardSegue*)segue { }

@end
