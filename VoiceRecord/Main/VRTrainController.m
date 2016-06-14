//
//  VRTrainController.m
//  VoiceRecord
//
//  Created by 王茹冰 on 16/6/8.
//  Copyright © 2016年 王茹冰. All rights reserved.
//

#import "VRTrainController.h"
#import "WRBScreenAdaptaionMacro.h"
#import "WRBScreenAdaptation.h"
#import "WRBAlertViewTool.h"
#import "WRBVoiceRecordManager.h"

@interface VRTrainController ()
@property (nonatomic, weak) UIButton *startButton;
@property (nonatomic, strong) NSMutableArray *textLabelArray;
@property (nonatomic, strong) NSArray *textArray;
@property (nonatomic, strong) NSMutableArray *digitalArray;
@property (nonatomic, strong) NSTimer *timer;
@end

static NSInteger currentIndex = 0;

@implementation VRTrainController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createData];
    [self createUI];
    [self configNav];
}

- (void)configNav
{
    [self setTitle:@"录音"];
    UIButton *returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    returnButton.frame = CGRectMake(0, 0, 50, 36);
    [returnButton setTitle:@"返回" forState:UIControlStateNormal];
    [returnButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    returnButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [returnButton addTarget:self action:@selector(returnButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:returnButton];
}

- (void)returnButtonTouched:(UIButton *)sender
{
    [[WRBVoiceRecordManager sharedInstance] stop];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    currentIndex = 0;
}

- (void)updateText
{
    if (currentIndex >= self.textArray.count) {
        currentIndex = 0;
        [self.timer invalidate];
        self.timer = nil;
        self.timer = [[NSTimer alloc] initWithFireDate:[NSDate distantPast] interval:1.0 target:self selector:@selector(updataDigital) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop]addTimer:_timer forMode:NSDefaultRunLoopMode];
    } else {
        NSString *text = self.textArray[currentIndex];
        NSArray *texts = [text componentsSeparatedByString:@" "];
        for (NSInteger i=0; i<texts.count; i++) {
            [self.textLabelArray[i] setText:texts[i]];
        }
        currentIndex ++;
    }
}

- (void)updataDigital
{
    if (currentIndex >= self.digitalArray.count) {
        [self.timer invalidate];
        self.timer = nil;
        [[WRBVoiceRecordManager sharedInstance] stop];
        [[WRBVoiceRecordManager sharedInstance] recordFinishedBlock:^(NSData *audioData) {
            NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
            NSString *fileName = [[NSUserDefaults standardUserDefaults] objectForKey:@"fileName"];
            NSString *filePath = [path stringByAppendingPathComponent:fileName];
            [self saveVoice:fileName];
            [audioData writeToFile:filePath atomically:YES];
            [[WRBAlertViewTool sharedInstance] showAlertViewInViewController:self title:@"语音录制完毕" message:@"感谢您的使用" operation:^(WRBAlertViewTool *alertViewTool) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }];
    } else {
        [self.textLabelArray[0] setText:self.digitalArray[currentIndex]];
        [self.textLabelArray[1] setText:nil];
        currentIndex ++;
    }
}

- (void)saveVoice:(NSString *)voiceName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"list.txt"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:nil attributes:nil];
    }
    
    NSMutableArray *arrM = [[NSArray arrayWithContentsOfFile:path] mutableCopy];
    if(!arrM){
        arrM = [NSMutableArray array];
    }
    [arrM addObject:voiceName];
    [arrM writeToFile:path atomically:YES];
}

- (NSString *)listPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"list.txt"];
    return path;
}

- (void)createUI
{
    //动态口令
    CGRect textFrame = CGRectZero;
    self.textLabelArray = [NSMutableArray arrayWithCapacity:2];
    for (NSInteger i=0; i<2; i++) {
        textFrame = CGRectMake(20, 80+50*i, 280, 50);
        UILabel *textLabel = [[UILabel alloc] initWithFrame:textFrame];
        textLabel.font = [UIFont boldSystemFontOfSize:30*autoSizeScale];
        textLabel.textColor = [UIColor darkGrayColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.text = @"0000";
        [self.view addSubview:textLabel];
        [self.textLabelArray addObject:textLabel];
    }
    
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.frame = CGRectMake(50, 260, 220, 220);
    [startButton setTitle:@"开始" forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startButton.titleLabel.font = [UIFont boldSystemFontOfSize:30*autoSizeScale];
    startButton.backgroundColor = [UIColor lightGrayColor];
    startButton.layer.cornerRadius = 5;
    startButton.clipsToBounds = YES;
    [self.view addSubview:startButton];
    [startButton addTarget:self action:@selector(startButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.startButton = startButton;
}

- (void)startButtonTouched:(UIButton *)sender
{
    if (self.timer == nil) {
        [[WRBVoiceRecordManager sharedInstance] start];
        self.timer = [[NSTimer alloc] initWithFireDate:[NSDate distantPast] interval:4.0 target:self selector:@selector(updateText) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop]addTimer:_timer forMode:NSDefaultRunLoopMode];
        self.startButton.userInteractionEnabled = NO;
    }
}

- (void)createData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Text.plist" ofType:nil];
    self.textArray = [[NSArray alloc] initWithContentsOfFile:path];
    NSArray *digitalArray = @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
    self.digitalArray = [NSMutableArray array];
    for (NSInteger i=0; i<6; i++) {
        for (NSInteger j=0; j<digitalArray.count; j++) {
            [self.digitalArray addObject:digitalArray[j]];
        }
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
