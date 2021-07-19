//
//  HomeVC.h
//  Redshift
//
//  Created by srivatsa s pobbathi on 22/10/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGRadioButtonsView.h"
#import "FCAlertView.h"

@interface HomeVC : UIViewController<UIGestureRecognizerDelegate>
{
    UIButton *btn1,*btn2,*btnSettings,*btn3,*btn4,*btn5,*btn6;
    UIImageView *imgSettings,*imgAppIcon,*imgLock;
    UILabel *lblTime,*lblSpeed,*lblHeadings,*lblAltitude,*lblVoltage,*lblOdometer1,*lblOdometer2,*lblTimeView,*lblSpeedView,*lblVoltageView,*lblHeadingsView,*lblAltitudeView,*lblOdometersView,*lblTimeLbl,*lblSpeedValue,*lblHeadingsLbl,*lblAltitudeLbl,*lblOdometerLbl,*lblVoltageLbl,*lblBatteryView,*lblBatteryDisplay,*lblBatteryLbl;
    int yy;
    UIButton *btnReset1,*btnReset2;
    CAShapeLayer *yourViewBorder;
    int selectedRelayBtn, relayDashedSelected;
    FCAlertView *alert;
    UILongPressGestureRecognizer*gestureRecognizer;
    CGFloat speedValue;
    NSMutableArray * arrStatusActive, * arrConnectedRelay;
    NSMutableDictionary * dictActive;
    
    UILabel * lblMom1, * lblMom2, * lblMom3, * lblMom4, * lblMom5, * lblMom6;
    UILongPressGestureRecognizer * longpress1, * longpress2, * longpress3, * longpress4, * longpress5, * longpress6;
    UITapGestureRecognizer * tapGesture1, * tapGesture2, * tapGesture3, * tapGesture4, * tapGesture5 , * tapGesture6;
    NSTimer *timeOutTimer;
    NSString * strBatteryValue;
    
    BOOL isIgnitionON;
    UILabel * lblLong1, * lblLong2, * lblLong3, * lblLong4, * lblLong5, * lblLong6;

}

@end

