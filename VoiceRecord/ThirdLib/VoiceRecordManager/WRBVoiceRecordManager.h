//
//  dEarRecordManager.h
//  dEarVoiceRecord
//
//  Created by 王茹冰 on 15/12/10.
//  Copyright © 2015年 王茹冰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface WRBVoiceRecordManager : NSObject
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;//播放器

+ (instancetype)sharedInstance;
/** 开始录音 */
- (void)start;
/** 结束录音 */
- (void)stop;
/** 播放语音 */
- (void)playWithPath:(NSString *)path;
/** 更新音频波浪线幅度 */
- (void)updateSiriWaveViewBlock:(void (^)(CGFloat power, CGFloat normalizedValue))siriWaveViewBlock;
/** 录音完成 */
- (void)recordFinishedBlock:(void (^)(NSData *audioData))recordFinishedBlock;
/** 播放完成 */
- (void)playFinishedBlock:(void (^)())playFinishedBlock;
@end
