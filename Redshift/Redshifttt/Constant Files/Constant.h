//
//  Constant.h
//  ibeacon stores
//
//  Created by One Click IT Consultancy  on 5/14/14.
//  Copyright (c) 2014 One Click IT Consultancy . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@protocol Constant <NSObject>

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;


//#define global_color  global_color
#define global_color  [UIColor colorWithRed:41.0/255.0f green:128.0/255.0f blue:185.0/255.0f alpha:1.0]

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6plus (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0f)
#define IS_IPHONE_X (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 812.0f)

#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


#define DEVICE_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define DEVICE_WIDTH [[UIScreen mainScreen] bounds].size.width


#define iPhone6_Ratio 1.17
#define iPhone6_Plus_Ratio 1.29

#define customErrorCodeForMessage 123456

#define kEmptyString @""

#define kClientID  @"430187968129-kb4ooajaas29g21l20a036mipvukjnpi.apps.googleusercontent.com"

//#define Alert_Animation_Type URBAlertAnimationTumble
#define Alert_Animation_Type URBAlertAnimationTopToBottom

#define APP_DELEGATE (AppDelegate*)[[UIApplication sharedApplication]delegate]


//#define WEB_SERVICE_URL @"http://192.168.0.7:3000/"
//#define WEB_STORAGE_URL @"http://192.168.0.7:3000"

//#define WEB_SERVICE_URL @"https://test.advisortlc.com/"
//#define WEB_STORAGE_URL @"https://test.advisortlc.com"


//#define WEB_SERVICE_URL @"http://35.164.29.245/"
//#define WEB_STORAGE_URL @"http://35.164.29.245"



#define ALERT_TITLE @"Succorfish Fisherman App"

#define OK_BTN @"OK"
#define ALERT_CANCEL  @"Cancel"
#define ALERT_DELETE  @"Delete"
#define ALERT_EDIT  @"Edit"
#define ALERT_PUSH_TO_ACCOUNT  @"Push to Accounts"
#define ACTION_TAKE_PHOTO      @"Take Photo"
#define ACTION_LIBRARY_PHOTO   @"Photo From Library"
#define ACTION_RECORD_VIDEO    @"Record Video"
#define ACTION_LIBRARY_VIDEO   @"Video From Library"
#define ACTION_RECORD_AUDIO    @"Record Audio"
#define ACTION_LIBRARY_AUDIO   @"Audio From Library"
#define ACTION_UPLOAD_ICLOUDE_DOC    @"From iCloud"
#define ACTION_UPLOAD_DROPBOX_DOC    @"From DropBox"

#define CONNECTION_FAILED      @"Please check internet connection"



#pragma mark User Credential-----------------------------------------



#define WEB_SERVICE_URL [[NSUserDefaults standardUserDefaults] valueForKey:@"WEB_SERVICE_URL"]
#define WEB_STORAGE_URL [[NSUserDefaults standardUserDefaults] valueForKey:@"WEB_STORAGE_URL"]



#define CURRENT_USER_ID [[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_ID"]
#define CURRENT_USER_ACCOUNT_ID [[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_ACCOUNT_ID"]
#define IS_CURRENT_USER_ENTERPRISE_ADMIN [[NSUserDefaults standardUserDefaults] valueForKey:@"IS_CURRENT_USER_ENTERPRISE_ADMIN"]

#define CURRENT_USER_EMAIL [[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_EMAIL"]
#define CURRENT_USER_ACCESS_TOKEN [[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_ACCESS_TOKEN"]
#define IS_USER_LOGGED [[NSUserDefaults standardUserDefaults] valueForKey:@"IS_LOGGEDIN"]
#define CURRENT_USER_PASS [[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_PASS"]

#define CURRENT_USER_CLIENT_ID [[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_CLIENT_ID"]
#define CURRENT_USER_CLIENT_SECRET [[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_CLIENT_SECRET"]
#define CURRENT_USER_REFRESH_TOKEN [[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_REFRESH_TOKEN"]

#define CURRENT_USER_FIRST_NAME [[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_FIRST_NAME"]
#define CURRENT_USER_LAST_NAME [[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_LAST_NAME"]
#define CURRENT_USER_LOGO_IMAGE [[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_LOGO_IMAGE"]
#define CURRENT_USER_IMAGE [[NSUserDefaults standardUserDefaults] valueForKey:@"CURRENT_USER_IMAGE"]


#pragma mark - Color Codes------------------------------
#define dark_gray_color @"4d4d4d"
#define light_gray_bg_color @"d3d3d3"

#define dark_red_color @"ae0125"
#define dark_blue_color @"175181"
#define dark_green_color @"3C905A"
#define light_green_color @"2dce28"
#define orange_color @"dd8836"

#define App_Background_color @"d3d3d3"
#define App_Header_Color @"175181"
#define header_font_color @"FFFFFF"
//#define header_font_color @"175181"

//#define color_search_bar_textfield_bg @"4a5473"
#define color_search_bar_textfield_bg @"FFFFFF"



#pragma mark - Images------------------------------------
#define Image_App_Background @""

#define Icon_Stats @"icon_stats.png"
//#define Icon_Stats @"icon_stats_blue.png"

#define Icon_Back_Button @"back-btn.png"
//#define Icon_Back_Button @"btn_back_blue.png"

#define Icon_Close_Button @"icon_close.png"


#define Icon_Search @"search_icon.png"


//#define PlaceHolderImage @"defaultProfilePic.png"
#define PlaceHolderImage @"profile_thumb.png"



#pragma mark - Contact Colors-------
#define gray_color @"bdbdbd"
#define dark_yellow_color @"b2b200"
#define magenta_color @"FF00FF"
#define maroon_color @"800000"
#define olive_color @"808000"

#define globalAppColor [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0]

#define CGRegular @"CenturyGothic"
#define CGBold @"CenturyGothic-Bold"
#define CGBoldItalic @"CenturyGothic-BoldItalic"
#define CGRegularItalic @"CenturyGothic-Italic"

@end
