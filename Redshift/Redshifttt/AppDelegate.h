//
//  AppDelegate.h
//  Redshift
//
//  Created by srivatsa s pobbathi on 22/10/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeVC.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "MBProgressHUD.h"

int txtSize;
CGFloat approaxSize;
int statusHeight;
int globalCount;
CLLocationManager * locationManager;
CBCentralManager  *centralManager;
BOOL isStopUpdate, isLowBtryPopupShown;
NSTimer *timeOutTimer,*timerSettings;
BOOL isKnobAdvertising;
BOOL isFromMOM;
UIDeviceOrientation  orinetationCount;
NSString * strFirmVersion;
BOOL isCentralAssigned;

@interface AppDelegate : UIResponder <UIApplicationDelegate,CBCentralManagerDelegate>
{
    MBProgressHUD * HUD;
    MBProgressHUD * HUD1;
}
@property (strong, nonatomic) UIWindow *window;

-(NSString *)checkforValidString:(NSString *)strRequest;
-(void)sendSignalViaScan:(NSString *)strType withDeviceID:(NSString *)strRelayNumber withValue:(NSString *)strTriggerValue withStatus:(NSString *)strStatus;
- (NSString*)hexToBinary:(NSString*)hexString;
-(NSString*)stringFroHex:(NSString *)hexStr;
-(void)startHudProcess:(NSString *)text;
-(void)endHudProcess;
-(void)startHudProcessForSettingScreen:(NSString *)text;
-(void)endHudProcessForSettingScreen;
-(NSString *)getStringConvertedinUnsigned:(NSString *)strNormal;
-(NSData *)GetDecrypedDataKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength;

@end

