#pragma mark once

// Rule creation
#define TMWLogging_Creation_Transmitter @"TMW: CREATE rule - transmitter screen"
#define TMWLogging_Creation_Sensor      @"TMW: CREATE rule - sensor screen"
#define TMWLogging_Creation_Threshold   @"TMW: CREATE rule - threshold screen"
#define TMWLogging_Creation_Name        @"TMW: CREATE rule - name screen"
#define TMWLogging_Creation_Cancelled   @"TMW: CREATE rule - cancelled"
#define TMWLogging_Creation_Finished    @"TMW: CREATE rule - finished"
#define TMWLogging_Creation_Saved(sensor, threshold)    [NSString stringWithFormat:@"TMW: CREATED rule - sensor: %@, threshold: %@", sensor, threshold]

// Edit rule
#define TMWLogging_Edit_Switch(boolValue)               [NSString stringWithFormat:@"TMW: EDIT rule - notifications: %@", (boolValue) ? @"YES" : @"NO"]
#define TMWLogging_Edit_Transmitter     @"TMW: EDIT rule - changing transmitter"
#define TMWLogging_Edit_Sensor          @"TMW: EDIT rule - changing sensor"
#define TMWLogging_Edit_Threshold       @"TMW: EDIT rule - changing threshold"
#define TMWLogging_Edit_Name            @"TMW: EDIT rule - changing name"
#define TMWLogging_Edit_Cancelled       @"TMW: EDIT rule - cancelled"
#define TMWLogging_Edit_Finished        @"TMW: EDIT rule - finished"

// Deletion from rules and notifications
#define TMWLogging_Delete_Rule(sensor)  [NSString stringWithFormat:@"TMW: DELETED rule - sensor: %@", sensor]
#define TMWLogging_Delete_Notification  @"TMW: DELETED notification"
#define TMWLogging_Delete_Notifications(numDeleted)     [NSString stringWithFormat:@"TMW: DELETED all %@ notifications", numDeleted]

// Viewing rule
#define TMWLogging_View_AppOpenned      @"TMW: VIEW app"
#define TMWLogging_View_AppNotified     @"TMW: VIEW push notification"
