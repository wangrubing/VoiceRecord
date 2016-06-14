//
//  WRBAlertViewTool.h
//  AlertViewTool
//
//  Created by 王茹冰 on 16/5/13.
//  Copyright © 2016年 王茹冰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WRBAlertViewTool : NSObject

+ (instancetype)sharedInstance;
/**
 *  普通提示弹窗
 *
 *  @param controller 弹窗所属控制器对象
 *  @param title      弹窗标题
 *  @param message    弹窗信息
 *  @param tag        弹窗标号
 *  @param operation  点击弹窗按钮后触发的操作
 */
- (void)showAlertViewInViewController:(UIViewController *)controller title:(NSString *)title message:(NSString *)message operation:(void(^)(WRBAlertViewTool *alertViewTool))operation;
/**
 *  带提示按钮的弹窗
 *
 *  @param controller 弹窗所属控制器对象
 *  @param title      弹窗标题
 *  @param message    弹窗信息
 *  @param tag        弹窗标号
 *  @param operation  点击弹窗按钮后触发的操作
 */
- (void)showCancelAlertViewInViewController:(UIViewController *)controller title:(NSString *)title message:(NSString *)message operation:(void(^)(WRBAlertViewTool *alertViewTool))operation;
/**
 *  带输入框的弹窗
 *
 *  @param controller 弹窗所属控制器对象
 *  @param title      弹窗标题
 *  @param message    弹窗信息
 *  @param tag        弹窗标号
 *  @param operation  点击弹窗按钮后触发的操作
 */
- (void)showTextAlertViewInViewController:(UIViewController *)controller title:(NSString *)title message:(NSString *)message operation:(void(^)(WRBAlertViewTool *alertViewTool, NSString *alertViewText))operation;

/**
 *  退出
 *
 *  @param controller       弹窗所属控制器对象
 *  @param signOutOperation 退出登陆
 */
- (void)showSignOutAlertViewInViewController:(UIViewController *)controller signOutOperation:(void(^)(WRBAlertViewTool *alertViewTool))signOutOperation;

/**
 *  弹出拍照弹窗
 *
 *  @param controller      弹窗所属控制器对象
 *  @param cameraOperation 拍照操作
 *  @param albumOperation  相册操作
 */
- (void)showCameraAlertViewInViewController:(UIViewController *)controller cameraOperation:(void(^)(WRBAlertViewTool *alertViewTool, UIImage *image))cameraOperation albumOperation:(void(^)(WRBAlertViewTool *alertViewTool, UIImage *image))albumOperation;
@end
