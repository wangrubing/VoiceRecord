//
//  VRLoginController.m
//  VoiceRecord
//
//  Created by 王茹冰 on 16/6/8.
//  Copyright © 2016年 王茹冰. All rights reserved.
//

#import "VRLoginController.h"
#import "VRTrainController.h"
#import "VRListController.h"
#import "WRBScreenAdaptaionMacro.h"
#import "WRBScreenAdaptation.h"
#import "WRBAlertViewTool.h"

@interface VRLoginController ()<UITextFieldDelegate>
@property (nonatomic, weak) UITextField *userTextField;
@property (nonatomic, weak) UITextField *recordTextField;
@property (nonatomic, strong) NSMutableArray *textFieldArray;
@end

@implementation VRLoginController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    [self configNav];
}

- (void)configNav
{
    [self setTitle:@"登录"];
    UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    voiceButton.frame = CGRectMake(0, 0, 50, 36);
    [voiceButton setTitle:@"播放" forState:UIControlStateNormal];
    [voiceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    voiceButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [voiceButton addTarget:self action:@selector(voiceButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:voiceButton];
}

- (void)createUI
{
    CGRect textFrame = CGRectZero;
    NSArray *textArray = @[@"请输入用户名", @"请输入录制手机编号", @"请输入播放手机编号"];
    NSArray *texts = @[@"王茹冰", @"1", @"2"];
    self.textFieldArray = [NSMutableArray arrayWithCapacity:textArray.count];
    for (NSInteger i=0; i<3; i++) {
        textFrame = CGRectMake(20, 80+40*i, 280, 30);
        UITextField *textField = [[UITextField alloc] initWithFrame:textFrame];
        textField.placeholder = textArray[i];
        textField.delegate = self;
        textField.layer.borderWidth = 1;
        textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        textField.layer.cornerRadius = 5;
        textField.clipsToBounds = YES;
        textField.textColor = [UIColor darkGrayColor];
//        textField.text = texts[i];
        [self.view addSubview:textField];
        [self.textFieldArray addObject:textField];
    }
    
    //登录按钮
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(20, 200, 280, 36);
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:14*autoSizeScale];
    loginButton.backgroundColor = [UIColor lightGrayColor];
    loginButton.layer.cornerRadius = 5;
    loginButton.clipsToBounds = YES;
    [self.view addSubview:loginButton];
    [loginButton addTarget:self action:@selector(loginButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)voiceButtonTouched:(UIButton *)sender
{
    VRListController *listController = [[VRListController alloc] init];
    [self.navigationController pushViewController:listController animated:YES];
}

- (void)loginButtonTouched:(UIButton *)sender
{
    NSString *user = [self.textFieldArray[0] text];
    NSString *record = [self.textFieldArray[1] text];
    NSString *play = [self.textFieldArray[2] text];
    if (user.length==0 || record==0 || play==0) {
        [[WRBAlertViewTool sharedInstance] showAlertViewInViewController:self title:@"用户名或手机编号不能为空" message:nil operation:nil];
        return;
    }
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@.wav", user, record, play];
    [[NSUserDefaults standardUserDefaults] setObject:fileName forKey:@"fileName"];
    VRTrainController *trainController = [[VRTrainController alloc] init];
    [self.navigationController pushViewController:trainController animated:YES];
}

#pragma mark - 键盘收回
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    for (UITextField *textField in self.textFieldArray) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITextField *textField in self.textFieldArray) {
        [textField resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
