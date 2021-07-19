//
//  AppDelegate.m
//  Redshift
//
//  Created by srivatsa s pobbathi on 22/10/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsVC.h"
#import "HomeVC.h"
#import "SetBeaconManager.h"
#import "GetBeaconManager.h"
//#import "Header.h"

@interface AppDelegate ()
{
    float stopAdvertiseValue;
    NSUUID *lastUUIDl;
    NSNumber *lastMajor;
    NSNumber *lastMinor;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString * strResponse = [self hexToBinary:@"14"];
    NSMutableArray * onArr = [[NSMutableArray alloc] init];
    for (int i=0; i<[strResponse length]; i++)
    {
        NSRange range71 = NSMakeRange(i,1);
        NSString * strCheck = [strResponse substringWithRange:range71];
        if ([strCheck isEqualToString:@"1"])
        {
            [onArr addObject:[NSString stringWithFormat:@"%d",8-i]];
        }
    }
    NSLog(@"ON Arr =%@",onArr);
    
    if (IS_IPHONE_6plus)
    {
        approaxSize = 1.29;
    }
    else if (IS_IPHONE_6 || IS_IPHONE_X)
    {
        approaxSize = 1.17;
    }
    else
    {
        approaxSize = 1;
    }
    
    if (IS_IPHONE_X)
    {
        statusHeight = 88;
    }
    else
    {
        statusHeight = 64;
    }
    
    txtSize = 16;
    if (IS_IPHONE_4 || IS_IPHONE_5)
    {
        txtSize = 15;
    }
    
    [self checkPredefinedvalues];
    
    self.window = [[UIWindow alloc]init];
    self.window.frame = self.window.bounds;
    [self setUpFrames];
    [self.window makeKeyAndVisible];
    [self createAllUUIDs];
    // Override point for customization after application launch.
    return YES;
}
-(void)checkPredefinedvalues
{
    if ([[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"unitType"]] isEqualToString:@"NA"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"English-SAE" forKey:@"unitType"];
    }
    
    if ([[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"odometer1"]] isEqualToString:@"NA"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"Unit" forKey:@"odometer1"];
    }
    
    if ([[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"odometer2"]] isEqualToString:@"NA"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"Unit" forKey:@"odometer2"];
    }
    
    if ([[self checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"ignitiontime"]] isEqualToString:@"NA"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:@"5" forKey:@"ignitiontime"];
    }
    
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"isRelayValueSet"] isEqualToString:@"YES"])
    {
        
    }
    else
    {
        NSArray * arrAssign = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6", nil];
        for (int i =0; i<6; i++)
        {
            NSString * strRelay = [NSString stringWithFormat:@"Relay%d",i+1];
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSString stringWithFormat:@"%d",i+1] forKey:strRelay];
            [dict setObject:[NSString stringWithFormat:@"Latch On-Off"] forKey:@"switchtype"];
            [dict setObject:[NSString stringWithFormat:@"%d",i+1] forKey:@"name"];
            [dict setObject:[arrAssign objectAtIndex:i] forKey:@"assigned"];
            [dict setObject:@"NA" forKey:@"elapsedtime"];
            [dict setObject:@"NA" forKey:@"morespeed"];
            [dict setObject:@"NA" forKey:@"lessspeed"];
            [dict setObject:@"NA" forKey:@"distance"];
            [dict setObject:@"YES" forKey:@"isActive"];
            [[NSUserDefaults standardUserDefaults] setValue:dict forKey:strRelay];
        }
        [[NSUserDefaults standardUserDefaults]setValue:@"YES" forKey:@"isRelayValueSet"];
        NSString * strEncryptKey = [NSString stringWithFormat:@"0x52, 0x65, 0x64, 0x72, 0x16, 0x39, 0x22, 0x67,0x53, 0x68, 0x69, 0x66, 0x74, 0x74, 0x66, 0x23"];
        [[NSUserDefaults standardUserDefaults]setValue:strEncryptKey forKey:@"defaultEncryptKey"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - SetUp Frames
-(void) setUpFrames
{
    HomeVC *rootView = [[HomeVC alloc]init];
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:rootView];
    navigation.navigationBarHidden = YES;
    
    self.window.rootViewController = navigation;

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (BOOL) shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationMaskPortrait;
}
-(NSString *)checkforValidString:(NSString *)strRequest
{
    NSString * strValid;
    if (![strRequest isEqual:[NSNull null]])
    {
        if (strRequest != nil && strRequest != NULL && ![strRequest isEqualToString:@""])
        {
            strValid = strRequest;
        }
        else
        {
            strValid = @"NA";
        }
    }
    else
    {
        strValid = @"NA";
    }
    strValid = [strValid stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    return strValid;
}

-(void)startAdvertisingBeacons
{
    [[SetBeaconManager sharedManager] initializeDeviceAsBeaconService];//kp812
}

-(void)stopAdvertisingBaecons
{
    [[SetBeaconManager sharedManager] stopService];//kp812
}

-(void)createAllUUIDs
{
    //Create Global UUID
    NSString * strGlobUUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"globalUUID"];
    if ([strGlobUUID isEqual:[NSNull null]] || [strGlobUUID length]==0 || strGlobUUID == nil)
    {
        CFUUIDRef udid = CFUUIDCreate(NULL);
        NSString *udidString = (NSString *) CFBridgingRelease(CFUUIDCreateString(NULL, udid));
        [[NSUserDefaults standardUserDefaults] setValue:udidString forKey:@"globalUUID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    /*-----------Start Location Manager----------*/
//    [self getLocationMethod];
    /*-------------------------------------------*/
    
    //Create Relay State Change UUID
    NSString * strRelayStateChange = [[NSUserDefaults standardUserDefaults] valueForKey:@"RelayStateChange"];
    if ([strRelayStateChange isEqual:[NSNull null]] || [strRelayStateChange length]==0 || strRelayStateChange == nil)
    {
        [self generateUUIDforAdvertising:@"0" withOpcode:@"3"];
    }
    
    //Create ignitionOffTime UUID
    NSString * strignitionOffTime = [[NSUserDefaults standardUserDefaults] valueForKey:@"ignitionOffTime"];
    if ([strignitionOffTime isEqual:[NSNull null]] || [strignitionOffTime length]==0 || strignitionOffTime == nil)
    {
        [self generateUUIDforAdvertising:@"0" withOpcode:@"4"];
    }
    
    //Create RelayTypeConfig UUID
    NSString * strRelayTypeConfig = [[NSUserDefaults standardUserDefaults] valueForKey:@"RelayTypeConfig"];
    if ([strRelayTypeConfig isEqual:[NSNull null]] || [strRelayTypeConfig length]==0 || strRelayTypeConfig == nil)
    {
        [self generateUUIDforAdvertising:@"0" withOpcode:@"5"];
    }
    
    //Create GearKnobAssignment UUID
    NSString * strGearKnobAssignment = [[NSUserDefaults standardUserDefaults] valueForKey:@"GearKnobAssignment"];
    if ([strGearKnobAssignment isEqual:[NSNull null]] || [strGearKnobAssignment length]==0 || strGearKnobAssignment == nil)
    {
        [self generateUUIDforAdvertising:@"0" withOpcode:@"6"];
    }
}

-(void)generateUUIDforAdvertising:(NSString * )deviceID withOpcode:(NSString *)strOpcode
{
    NSInteger first = [@"00" integerValue];
    NSData *dTTL = [[NSData alloc] initWithBytes:&first length:1];
    
    NSInteger second = [@"89" integerValue];
    NSData *dSqnce = [[NSData alloc] initWithBytes:&second length:1];
    
    NSInteger third = [@"82" integerValue];
    NSData * dDeviceID = [[NSData alloc] initWithBytes:&third length:1];
    
    NSInteger fourth = [@"115" integerValue];;
    NSData * dDestID = [[NSData alloc] initWithBytes:&fourth length:1];
    
    NSInteger fifth = [@"102" integerValue];
    NSData * dCRC = [[NSData alloc] initWithBytes:&fifth length:1];
    
    NSInteger sixth = [@"116" integerValue];
    NSData * dSix = [[NSData alloc] initWithBytes:&sixth length:1];
    
    NSInteger seven = [strOpcode integerValue];
    NSData * dSeven = [[NSData alloc] initWithBytes:&seven length:1];
    
    NSInteger eight = [@"0" integerValue];

    NSData * d8 = [[NSData alloc] initWithBytes:&eight length:2];
    
    NSData * d9 = [[NSData alloc] initWithBytes:&eight length:2];
    
    NSData * d10 = [[NSData alloc] initWithBytes:&eight length:2];
    
    NSData * d11 = [[NSData alloc] initWithBytes:&eight length:1];

    NSMutableString *nameString = [[NSMutableString alloc]initWithCapacity:0];
    
    [nameString appendString:[NSString stringWithFormat:@"%@",dTTL]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dSqnce]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dDeviceID]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dDestID]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dCRC]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dSix]];
    [nameString appendString:[NSString stringWithFormat:@"%@",dSeven]];
    [nameString appendString:[NSString stringWithFormat:@"%@",d8]];
    [nameString appendString:[NSString stringWithFormat:@"%@",d9]];
    [nameString appendString:[NSString stringWithFormat:@"%@",d10]];
    [nameString appendString:[NSString stringWithFormat:@"%@",d10]];//14
    [nameString appendString:[NSString stringWithFormat:@"%@",d11]];//15
    
    NSString * strFinal = [NSString stringWithFormat:@"%@",nameString];
    strFinal = [strFinal stringByReplacingOccurrencesOfString:@" " withString:@""];
    strFinal = [strFinal stringByReplacingOccurrencesOfString:@">" withString:@""];
    strFinal = [strFinal stringByReplacingOccurrencesOfString:@"<" withString:@""];
    strFinal = [strFinal uppercaseString];
    
    // Append - for iBacon UUID for Raw Data
    NSMutableString * strRawUUID = [[NSMutableString alloc] initWithString:strFinal];
    [strRawUUID insertString:@"-" atIndex:8];
    [strRawUUID insertString:@"-" atIndex:13];
    [strRawUUID insertString:@"-" atIndex:18];
    [strRawUUID insertString:@"-" atIndex:23];
    
//    NSLog(@"Final UUID=%@",strRawUUID);
    if ([strOpcode isEqualToString:@"3"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"RelayStateChange"];
    }
    else if ([strOpcode isEqualToString:@"4"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"ignitionOffTime"];
    }
    else if ([strOpcode isEqualToString:@"5"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"RelayTypeConfig"];
    }
    else if ([strOpcode isEqualToString:@"6"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strRawUUID forKey:@"GearKnobAssignment"];
    }
}


#pragma mark -----------------------
#pragma mark Method to send signal to Peripheral VIS iBeacon
#pragma mark -----------------------
-(void)sendSignalViaScan:(NSString *)strType withDeviceID:(NSString *)strRelayNumber withValue:(NSString *)strTriggerValue withStatus:(NSString *)strStatus
{
    isStopUpdate = YES;
    if ([strType isEqualToString:@"RelayStateChange"])
    {
        int intMajor = 0;
        NSInteger relayNo = [strRelayNumber integerValue];
        relayNo <<= 8;

        NSInteger triggerValue = [strTriggerValue intValue];
        intMajor |= relayNo;
        intMajor |= triggerValue;
        
        NSInteger statusInt = [strStatus intValue];
        int intMinor = 0;
        statusInt <<= 8;
        intMinor |= statusInt;

        if ([strStatus isEqualToString:@"0"])
        {
            stopAdvertiseValue = 1.5;
        }
        else
        {
            stopAdvertiseValue = 1.5;
        }
        lastMajor = [NSNumber numberWithInt:intMajor];
        lastMinor = [NSNumber numberWithInt:intMinor];
        lastUUIDl = [[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"RelayStateChange"]];
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:intMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:intMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"RelayStateChange"]]];
        
        NSLog(@"RelayStateChange UUID=%@  Major==%@   Minor ==%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"RelayStateChange"],[NSNumber numberWithInt:intMajor],[NSNumber numberWithInt:intMinor]);
    }
    else if ([strType isEqualToString:@"ignitionOffTime"])
    {
        int intMajor = 0;
        NSInteger relayNo = [strRelayNumber integerValue];
        relayNo <<= 8;
        intMajor |= relayNo;

        int intMinor = 0;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:intMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:intMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"ignitionOffTime"]]];
        
        NSLog(@" ignitionOffTime UUID=%@  Major==%@   Minor ==%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"ignitionOffTime"],[NSNumber numberWithInt:intMajor],[NSNumber numberWithInt:intMinor]);
    }
    else if ([strType isEqualToString:@"RelayTypeConfig"])
    {
        int intMajor = 0;
        NSInteger relayNo = [strRelayNumber integerValue];
        relayNo <<= 8;
        
        NSInteger triggerValue = [strTriggerValue intValue];
        intMajor |= relayNo;
        intMajor |= triggerValue;
        
        int intMinor = 0;

        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:intMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:intMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"RelayTypeConfig"]]];
        
        NSLog(@" RelayTypeConfig UUID=%@  Major==%@   Minor ==%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"RelayTypeConfig"],[NSNumber numberWithInt:intMajor],[NSNumber numberWithInt:intMinor]);
    }
    else if ([strType isEqualToString:@"GearKnobAssignment"])
    {
        int intMajor = 0;
        NSInteger relayNo = [strRelayNumber integerValue];
        relayNo <<= 8;
        
        NSInteger triggerValue = [strTriggerValue intValue];
        intMajor |= relayNo;
        intMajor |= triggerValue;
        
        int intMinor = 0;
        
        [[SetBeaconManager sharedManager] setMajor:[NSNumber numberWithInt:intMajor]];
        [[SetBeaconManager sharedManager] setMinor:[NSNumber numberWithInt:intMinor]];
        [[SetBeaconManager sharedManager] setUuid:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] valueForKey:@"GearKnobAssignment"]]];
        
        NSLog(@"GearKnobAssignment UUID=%@  Major==%@   Minor ==%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"GearKnobAssignment"],[NSNumber numberWithInt:intMajor],[NSNumber numberWithInt:intMinor]);
    }
    [[SetBeaconManager sharedManager] updateAdvertisedRegion];
//    [self performSelector:@selector(stopAdvertiseiBacons) withObject:nil afterDelay:stopAdvertiseValue];
    timeOutTimer = nil;
    [timeOutTimer invalidate];
    timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:stopAdvertiseValue target:self selector:@selector(stopAdvertiseiBacons) userInfo:nil repeats:NO];

//   [self performSelector:@selector(stopIndicator) withObject:nil afterDelay:1.5];
    isStopUpdate = NO;
    if (isFromMOM)
    {
//        timeOutTimer = nil;
//        timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(udateAgainAdvertisement) userInfo:nil repeats:NO];

    }
    
  //  isStopUpdate = YES;

}
-(void)udateAgainAdvertisement
{
    [[SetBeaconManager sharedManager] setMajor:lastMinor];
    [[SetBeaconManager sharedManager] setMinor:lastMinor];
    [[SetBeaconManager sharedManager] setUuid:lastUUIDl];
    [[SetBeaconManager sharedManager] updateAdvertisedRegion];
    [[SetBeaconManager sharedManager] updateAdvertisedRegion];
    [self performSelector:@selector(stopAdvertiseiBacons) withObject:nil afterDelay:1];
}
-(void)stopIndicator
{
    isStopUpdate = NO;

}
-(void)timeOutMethodClick
{
    [self endHudProcess];
}
-(void)stopAdvertiseiBacons
{
    [[SetBeaconManager sharedManager] stopAdv];
//    [self endHudProcess];

}
- (NSString*)hexToBinary:(NSString*)hexString
{
    NSMutableString *retnString = [NSMutableString string];
    for(int i = 0; i < [hexString length]; i++) {
        char c = [[hexString lowercaseString] characterAtIndex:i];
        
        switch(c) {
            case '0': [retnString appendString:@"0000"]; break;
            case '1': [retnString appendString:@"0001"]; break;
            case '2': [retnString appendString:@"0010"]; break;
            case '3': [retnString appendString:@"0011"]; break;
            case '4': [retnString appendString:@"0100"]; break;
            case '5': [retnString appendString:@"0101"]; break;
            case '6': [retnString appendString:@"0110"]; break;
            case '7': [retnString appendString:@"0111"]; break;
            case '8': [retnString appendString:@"1000"]; break;
            case '9': [retnString appendString:@"1001"]; break;
            case 'a': [retnString appendString:@"1010"]; break;
            case 'b': [retnString appendString:@"1011"]; break;
            case 'c': [retnString appendString:@"1100"]; break;
            case 'd': [retnString appendString:@"1101"]; break;
            case 'e': [retnString appendString:@"1110"]; break;
            case 'f': [retnString appendString:@"1111"]; break;
            default : break;
        }
    }
    
    return retnString;
}
#pragma mark - CentralManager Ble delegate Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
}
-(NSString*)stringFroHex:(NSString *)hexStr
{
    unsigned long long startlong;
    NSScanner* scanner1 = [NSScanner scannerWithString:hexStr];
    [scanner1 scanHexLongLong:&startlong];
    double unixStart = startlong;
    NSNumber * startNumber = [[NSNumber alloc] initWithDouble:unixStart];
    return [startNumber stringValue];
}

#pragma mark Hud Method
-(void)startHudProcess:(NSString *)text
{
    [HUD removeFromSuperview];
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    HUD.labelText = text;
    [self.window addSubview:HUD];
    [HUD show:YES];
}
-(void)endHudProcess
{
    [HUD hide:YES];
}
-(void)startHudProcessForSettingScreen:(NSString *)text
{
    [HUD1 removeFromSuperview];
    HUD1 = [[MBProgressHUD alloc] initWithView:self.window];
    HUD1.labelText = text;
    [self.window addSubview:HUD1];
    [HUD1 show:YES];

    
}
-(void)endHudProcessForSettingScreen
{
    [HUD1 hide:YES];
}
-(void)tick
{
    
}

#pragma mark - For Decrypting Data

//-(NSData *)GetDecrypedDataKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength
//{
//    strKey = [NSString stringWithFormat:@"0x52 0x65 0x64 0x72 0x16 0x39 0x22 0x67 0x53 0x68 0x69 0x66 0x74 0x74 0x66 0x23"];
//
//    //RAW Data of 16 bytes
//    NSScanner *scanner = [NSScanner scannerWithString: strData];
//    unsigned char strrRawData[16];
//    unsigned index = 0;
//    while (![scanner isAtEnd])
//    {
//        unsigned value = 0;
//        if (![scanner scanHexInt: &value])
//        {
//            // invalid value
//            break;
//        }
//        strrRawData[index++] = value;
//    }
//    
//    //Password encrypted Key 16 bytes
//    NSScanner *scannerKey = [NSScanner scannerWithString: strKey];
//    unsigned char strrDataKey[16];
//    unsigned indexKey = 0;
//    while (![scannerKey isAtEnd])
//    {
//        unsigned value = 0;
//        if (![scannerKey scanHexInt: &value])
//        {
//            // invalid value
//            break;
//        }
//        strrDataKey[indexKey++] = value;
//    }
//    unsigned char  tempResultOp[16];
//    Header_h AES_ECB(strrRawData, strrDataKey, tempResultOp, 0);
//
//    NSUInteger size = dataLength;
//    NSData* data = [NSData dataWithBytes:(const void *)tempResultOp length:sizeof(unsigned char)*size];
////    NSLog(@"Data=%@",data);
//    return data;
//}
//-(NSString *)getStringConvertedinUnsigned:(NSString *)strNormal
//{
//    NSString * strKey = strNormal;
//    long ketLength = [strKey length]/2;
//    NSString * strVal;
//    for (int i=0; i<ketLength; i++)
//    {
//        NSRange range73 = NSMakeRange(i*2, 2);
//        NSString * str3 = [strKey substringWithRange:range73];
//        if ([strVal length]==0)
//        {
//            strVal = [NSString stringWithFormat:@" 0x%@",str3];
//        }
//        else
//        {
//            strVal = [strVal stringByAppendingString:[NSString stringWithFormat:@" 0x%@",str3]];
//        }
//    }
//    return strVal;
//}
@end
//0x52, 0x65, 0x64, 0x72, 0x16, 0x39, 0x22, 0x67,0x53, 0x68, 0x69, 0x66, 0x74, 0x74, 0x66, 0x23

