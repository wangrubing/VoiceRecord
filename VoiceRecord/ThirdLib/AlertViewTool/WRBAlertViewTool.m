//
//  WRBAlertViewTool.m
//  AlertViewTool
//
//  Created by 王茹冰 on 16/5/13.
//  Copyright © 2016年 王茹冰. All rights reserved.
//

#import "WRBAlertViewTool.h"

typedef enum : NSUInteger {
    AlertViewStyle_default = 0,
    AlertViewStyle_cancel,
    AlertViewStyle_text,
    AlertViewStyle_camera
} AlertViewStyle;

@interface WRBAlertViewTool ()<UIAlertViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>
{
    void (^alertViewBlock)(WRBAlertViewTool *alertViewTool);
    void (^textAlertViewBlock)(WRBAlertViewTool *alertViewTool, NSString *text);
    void (^cameraAlertViewBlock)(WRBAlertViewTool *alertViewTool, UIImage *image);
    AlertViewStyle alertViewStyle;
}
@property (nonatomic, strong) UIViewController *viewController;
@end

@implementation WRBAlertViewTool
+ (instancetype)sharedInstance {
    static WRBAlertViewTool *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertViewStyle == AlertViewStyle_default) {
        if (alertViewBlock) {
            alertViewBlock(self);
        }
    } else if (alertViewStyle == AlertViewStyle_cancel) {
        if (buttonIndex == 1) {
            if (alertViewBlock) {
                alertViewBlock(self);
            }
        }
    } else if (alertViewStyle == AlertViewStyle_text) {
        if (textAlertViewBlock) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            textAlertViewBlock(self, textField.text);
        }
    }
    return;
}

- (void)showAlertViewInViewController:(UIViewController *)controller title:(NSString *)title message:(NSString *)message operation:(void(^)(WRBAlertViewTool *alertViewTool))operation;
{
    id obj=NSClassFromString(@"UIAlertController");
    if (obj != nil) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction: [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (operation) {
                operation(self);
            }
        }]];
        [controller presentViewController: alertController animated: YES completion: nil];
    } else {
        alertViewStyle = AlertViewStyle_default;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        alertViewBlock = [operation copy];
        [alertView show];
    }
}

- (void)showCancelAlertViewInViewController:(UIViewController *)controller title:(NSString *)title message:(NSString *)message operation:(void(^)(WRBAlertViewTool *alertViewTool))operation;
{
    id obj=NSClassFromString(@"UIAlertController");
    if (obj != nil) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction: [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (operation) {
                operation(self);
            }
        }]];
        [alertController addAction: [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [controller presentViewController: alertController animated: YES completion: nil];
    } else {
        alertViewStyle = AlertViewStyle_cancel;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertViewBlock = [operation copy];
        [alertView show];
    }
}

- (void)showTextAlertViewInViewController:(UIViewController *)controller title:(NSString *)title message:(NSString *)message operation:(void(^)(WRBAlertViewTool *alertViewTool, NSString *alertViewText))operation;
{
    id obj=NSClassFromString(@"UIAlertController");
    if (obj != nil) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        }];
        [alertController addAction: [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (operation) {
                UITextField *textFeild = alertController.textFields[0];
                operation(self, textFeild.text);
            }
        }]];
        [controller presentViewController: alertController animated: YES completion: nil];
    } else {
        alertViewStyle = AlertViewStyle_text;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        textAlertViewBlock = [operation copy];
        [alertView show];
    }
}

- (void)showSignOutAlertViewInViewController:(UIViewController *)controller signOutOperation:(void(^)(WRBAlertViewTool *alertViewTool))signOutOperation
{
    self.viewController = controller;
    id obj=NSClassFromString(@"UIAlertController");
    if (obj != nil) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"是否确定退出登登录？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction: [UIAlertAction actionWithTitle: @"退出登录" style: UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            if (signOutOperation) {
                signOutOperation(self);
            }
        }]];
        [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
        [controller presentViewController: alertController animated: YES completion: nil];
    } else {
        alertViewStyle = AlertViewStyle_camera;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选取", nil];
        [actionSheet showInView:controller.view];
        alertViewBlock = [signOutOperation copy];
    }
}

- (void)showCameraAlertViewInViewController:(UIViewController *)controller cameraOperation:(void(^)(WRBAlertViewTool *alertViewTool, UIImage *image))cameraOperation albumOperation:(void(^)(WRBAlertViewTool *alertViewTool, UIImage *image))albumOperation
{
    self.viewController = controller;
    id obj=NSClassFromString(@"UIAlertController");
    if (obj != nil) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction: [UIAlertAction actionWithTitle: @"拍照" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            cameraAlertViewBlock = [cameraOperation copy];
            [self camera];
        }]];
        [alertController addAction: [UIAlertAction actionWithTitle: @"从相册选取" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            cameraAlertViewBlock = [albumOperation copy];
            [self album];
        }]];
        [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
        [controller presentViewController: alertController animated: YES completion: nil];
    } else {
        alertViewStyle = AlertViewStyle_camera;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选取", nil];
        [actionSheet showInView:controller.view];
        if (cameraOperation) {
            cameraAlertViewBlock = [cameraOperation copy];
        }
        if (albumOperation) {
            cameraAlertViewBlock = [albumOperation copy];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertViewStyle == AlertViewStyle_camera) {
        if (buttonIndex == 0) {
            [self camera];
        }
        if (buttonIndex == 1) {
            [self album];
        }
    }
}

#pragma mark - 拍照
- (void)camera
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    [self.viewController presentViewController:pickerController animated:YES completion:nil];
}

- (void)album
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerController.sourceType];
    [self.viewController presentViewController:pickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [aPicker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (image && cameraAlertViewBlock) {
//        UIImage *imageToDisplay = [self fixOrientation:image];
        cameraAlertViewBlock(self, image);
    }  
    return;  
}

#pragma mark - 旋转照片
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end
