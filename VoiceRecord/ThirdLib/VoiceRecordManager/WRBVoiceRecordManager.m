//
//  dEarRecordManager.m
//  dEarVoiceRecord
//
//  Created by 王茹冰 on 15/12/10.
//  Copyright © 2015年 王茹冰. All rights reserved.
//

#import "WRBVoiceRecordManager.h"

@interface WRBVoiceRecordManager ()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    void (^playEndBlock)();
}
@property (nonatomic, copy) void(^siriWaveViewBlock)(CGFloat power, CGFloat normalizedValue);
@property (nonatomic,strong) AVAudioRecorder *audioRecorder;//音频录音机
@property (nonatomic,strong) NSTimer *timer;//录音声波监控
@property(nonatomic, copy) NSString *recordPath;//录音文件存储路径
@end

@implementation WRBVoiceRecordManager

+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static WRBVoiceRecordManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[WRBVoiceRecordManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setAudioSession];
    }
    return self;
}


#pragma mark - 录音声波监控定制器
/** 录音声波监控定制器 */
-(NSTimer *)timer{
    if (!_timer)
    {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

/** 取得声波幅度值 */
-(void)audioPowerChange{
    [self.audioRecorder updateMeters];//更新测量值
    float power= [self.audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
    //NSLog(@"%lf", power);
    CGFloat normalizedValue = pow (10, power / 100);
    
    //更新音频波浪线幅度
    if (self.siriWaveViewBlock)
    {
        self.siriWaveViewBlock(power, normalizedValue);
    }
}

#pragma mark - 设置音频会话
-(void)setAudioSession{
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [audioSession setActive:YES error:nil];
}

/** 开始录音 */
-(void)start
{
    if (![self.audioRecorder isRecording])
    {
        [self.audioRecorder record];
        self.timer.fireDate=[NSDate distantPast];
    }
}

/** 结束录音 */
-(void)stop
{
    [self.audioRecorder stop];
    _audioRecorder = nil;
    self.timer.fireDate=[NSDate distantFuture];
}

#pragma mark - 录音机对象
/** 录音器 */
-(AVAudioRecorder *)audioRecorder
{
    if (!_audioRecorder)
    {
        NSURL *url = [self getRecordPath];
        NSDictionary *setting = [self getAudioSetting];
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
        if (error)
        {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

/** 录音设置 */
-(NSDictionary *)getAudioSetting
{
    NSMutableDictionary *dicM=[NSMutableDictionary dictionary];
    //设置录音格式
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    //设置录音采样率，8000是电话采样率，对于一般录音已经够了
    [dicM setObject:@(16000.0) forKey:AVSampleRateKey];
    //设置通道,这里采用单声道
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    //每个采样点位数,分为8、16、24、32
    [dicM setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    return dicM;
}

/** 录音文件存储路径 */
-(NSURL *)getRecordPath
{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd_hh-mm-ss";
    NSString *fileName = [NSString stringWithFormat:@"%@.wav", [dateFormatter stringFromDate:now]];
    NSString* documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *recorderPath = [documentsDirectory stringByAppendingPathComponent: fileName];
    self.recordPath = recorderPath;
    return [NSURL fileURLWithPath:recorderPath];
}

/** 播放器 */
//-(AVAudioPlayer *)audioPlayer
//{
//    NSLog(@"%@",self.recordPath);
//    NSURL *url = [NSURL fileURLWithPath:self.recordPath];
//    NSError *error=nil;
//    _audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
//    _audioPlayer.numberOfLoops=0;
//    _audioPlayer.volume = 5;
//    [_audioPlayer prepareToPlay];
//    if (error) {
//        NSLog(@"创建播放器过程中发生错误，错误信息：%@",error.localizedDescription);
//        return nil;
//    }
//    return _audioPlayer;
//}

- (void)playWithPath:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    _audioPlayer.numberOfLoops=0;
    _audioPlayer.volume = 5;
    _audioPlayer.delegate = self;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (playEndBlock) {
        playEndBlock();
    }
}

- (void)playFinishedBlock:(void (^)())playFinishedBlock
{
    playEndBlock = [playFinishedBlock copy];
}

/** 录音完成 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
//    NSLog(@"录音完成!");
}

#pragma mark - 更新音频波浪线幅度
- (void)updateSiriWaveViewBlock:(void (^)(CGFloat, CGFloat))siriWaveViewBlock
{
    self.siriWaveViewBlock = [siriWaveViewBlock copy];
}

#pragma mark - 录音完成
- (void)recordFinishedBlock:(void (^)(NSData *audioData))recordFinishedBlock
{
//    [self.audioPlayer play];
    NSData *data = [NSData dataWithContentsOfFile:self.recordPath];
    recordFinishedBlock(data);
    //每次录音完成之后，直接把文件删了
    [self removeAudioData];
}

#pragma mark - 清除缓存
/** 根据文件路径删除音频文件 */
-(void)removeAudioData
{
    if (self.recordPath)
    {
        NSFileManager *fileManeger = [NSFileManager defaultManager];
        //如果路径下存在音频文件
        if ([fileManeger fileExistsAtPath:self.recordPath])
        {
            NSError *error = nil;
            //删除音频文件
            [fileManeger removeItemAtPath:self.recordPath error:&error];
            //删除音频文件出错
            if (error)
            {
                NSLog(@"除音频文件出错：%@", error.description);
            }
        }
    }
}

@end
