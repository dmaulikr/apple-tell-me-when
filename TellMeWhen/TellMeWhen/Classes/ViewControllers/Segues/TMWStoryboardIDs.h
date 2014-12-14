#pragma once

#define TMWStoryboard                                   @"Main"

#define TMWStoryboardIDs_ControllerInitial              @"TMWInitialController"
#define TMWStoryboardIDs_ControllerMain                 @"TMWMainController"

#pragma mark - Segues
// Main segues
#define TMWStoryboardIDs_SegueFromSignToMain            @"TMWSegueSwapWindowRootVCs"
#define TMWStoryboardIDs_SegueFromMainToSign            TMWStoryboardIDs_SegueFromSignToMain
// Rule segues
#define TMWStoryboardIDs_SegueFromRulesToOnboarding     @"TMWSegueFromRulesToOnboarding"
#define TMWStoryboardIDs_SegueFromRulesToNoRules        @"TMWSegueFromRulesToNoRules"
#define TMWStoryboardIDs_SegueFromRulesToSummary        @"TMWSegueFromRulesToSummary"
#define TMWStoryboardIDs_SegueFromRulesToNew            @"TMWSegueFromRulesToNew"
#define TMWStoryboardIDs_SegueFromRulesTransToMeasures  @"TMWSegueFromRuleTransToMeasurements"

#define TMWStoryboardIDs_SegueFromRulesSummaryToTransm  @"TMWSegueFromRuleSummaryToTransmitters"
// Notification segues
#define TMWStoryboardIDs_SegueFromNotifsToNoNotifs      @"TMWSegueFromNotifsToNoNotifs"
#define TMWStoryboardIDs_SegueFromNoNotifsToNotifs      @"TMWSegueFromNoNotifsToNotifs"
#define TMWStoryboardIDs_SegueFromNotifsToDetails       @"TMWSegueFromNotifsToDetails"
