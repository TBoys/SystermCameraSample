//
//  ViewController.m
//  SystemCameraSample
//
//  Created by golang on 2021/8/24.
//  Copyright © 2021 golang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic, weak)UIImageView *showImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initView];
}

- (void)initView{

    UIImageView *showView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4, 90, self.view.frame.size.width/2, self.view.frame.size.width/3*2)];
    showView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:showView];
    self.showImage = showView;
    
    UIButton *takeButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/4, CGRectGetMaxY(showView.frame) + 64, self.view.frame.size.width/2, 44)];
    takeButton.backgroundColor = [UIColor grayColor];
    [takeButton setTitle:@"开始拍照" forState:UIControlStateNormal];
    [takeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [takeButton setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [takeButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takeButton];
    
}

- (void)takePhoto{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = NO;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }else{
        NSLog(@"system camera is invalid");
    }
}

#pragma mark - image picker delegte

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *fixImage = [self fixOriginalImageOrientation:originalImage];
    self.showImage.image = fixImage;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (UIImage *)fixOriginalImageOrientation:(UIImage *)originalImage {
    
    // No-op if the orientation is already correct
    if (originalImage.imageOrientation == UIImageOrientationUp) return originalImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    UIImageOrientation orientaion = originalImage.imageOrientation;
    if (orientaion == UIImageOrientationDown || orientaion == UIImageOrientationDownMirrored) {
        transform = CGAffineTransformTranslate(transform, originalImage.size.width, originalImage.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
    }else if (orientaion == UIImageOrientationLeft || orientaion == UIImageOrientationLeftMirrored){
        transform = CGAffineTransformTranslate(transform, originalImage.size.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
    }
    
    switch (originalImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, originalImage.size.width, originalImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, originalImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, originalImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (originalImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, originalImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, originalImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, originalImage.size.width, originalImage.size.height,
                                             CGImageGetBitsPerComponent(originalImage.CGImage), 0,
                                             CGImageGetColorSpace(originalImage.CGImage),
                                             CGImageGetBitmapInfo(originalImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (originalImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,originalImage.size.height,originalImage.size.width), originalImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,originalImage.size.width,originalImage.size.height), originalImage.CGImage);
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
