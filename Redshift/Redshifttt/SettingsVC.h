//
//  SettingsVC.h
//  Redshift
//
//  Created by srivatsa s pobbathi on 23/10/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGRadioButtonsView.h"
#import "ORBSwitch.h"

@interface SettingsVC : UIViewController<ORBSwitchDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIScrollViewDelegate,UITextFieldDelegate,FCAlertViewDelegate>
{
    UIButton *btn1,*btn2,*btnSettings,*btn3,*btn4,*btn5,*btn6,*btnPickerView;
    int yy;
    UIView *ViewPicker,*viewBelowSwitch,*viewUnit,*viewOdometer, * backShadowView;
    UIScrollView *viewSettings,*viewRelay;
    UIPickerView *pickerMainSettings,*datePicker,*relayPicker;
    NSMutableArray *dataArray;
    NSString * strBtnTitle,*strAlertViewText,*strRelayAssigned;
    UIImageView*imgArrow;
    UILabel*lblPicker,*lblChannelNumber,*lblTfieldNameLine,*lblBtnLessSpeedLine,*lbltnMoreSpeedLine,*lblSettingsHeader,*lblInfo,*lblSwitchTypeLbl,*lblEditlbl,*lblOperation,*lblMoreSpeed,*lblLessSpeed,*lblDistStaticlbl,*lblBtnDistLine,*lblTimelbl,*lblTimeValueLine,*lblUnitlbl,*lblOdo1,*lblOdo2,*lblAssigned,*lblAssignBtnLine;
    UITextField *tfieldLandscapeDisplay;
    NSString*strTimeValue,*strElapsedTimeValueHH,*strElapsedTimeValueMM,*strElapsedTimeValueSS,*strElapsedTimeValue;
    int intSelectedTfield;
    UIButton * btnEnglish, * btnMetric, * btnUnitOdo1, * btnUnitOdo2, * btnTenthsOd1, * btnTenthsOd2;
    UIButton * btnLatch, * btnMom,*btnElapsedTime,*btnSpeed,*btnDistance,*btnNone,*btnTimeValue,*btnValueDistance;
    UIButton *btnMoreSpeedValue,*btnLessSpeedValue,*btnName,*btnDone,*btnRelayAssign;
    NSMutableArray *arrDatePickerHH,*arrDatePickerMM,*arrDatePickerSS,*arrRelayAssign;
    ORBSwitch *switchEditButton;
    BOOL isSwitchOn;
    NSInteger selectedRelayBtn;
    CAShapeLayer *yourViewBorder;
    NSMutableDictionary * dictSelected;
    FCAlertView *alert;
    NSString *strSelectedOperation;
    NSMutableDictionary * dictRelayAssign;
    NSString * strDefaltAssigned;
    NSString * strPrevAss ;
    int intSelectedIndex;

}
@property (strong, nonatomic) LGRadioButtonsView    * unitRadioBtn;
@property (strong, nonatomic) LGRadioButtonsView    * odo1RadioBtn;
@property (strong, nonatomic) LGRadioButtonsView    * odo2RadioBtn;

@end
