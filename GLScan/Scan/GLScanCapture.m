//
//  GLScanCapture.m
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/3/21.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import "GLScanCapture.h"
#import <Photos/Photos.h>


@interface GLScanCapture ()<AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureDevice *capture;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;// ios 9 及以下
@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;// iOS 10 及以上

@property (nonatomic, strong) AVCaptureSession *session;// 会话对象

@property (nonatomic, strong) UIView *captureView;// 预览父视图
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;// 预览图层

@end

@implementation GLScanCapture


- (instancetype)init {
    return [self initWithScanShowView:nil];
}

#pragma mark - ------< 初始化方法 >------
- (instancetype)initWithScanShowView:(UIView *)showView {
    self = [super init];
    if (self) {
        self.showView = showView;
        [self setDefault];
        [self initCapture];
        
    }
    return self;
}

#pragma mark - ------< 设置默认参数 >------
- (void)setDefault {
    self.isSingleTapAutoFocus = NO;
    self.isDoubleTapScale = YES;
}

#pragma mark - ------< 初始化相机等输入对象 >------
- (void)initCapture {
    if ([self isAuthority] == NO) return;
    // 获取摄像设备
    self.capture = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 当启动AVCaptureDeviceSubjectAreaDidChangeNotification通知时
    // 需将subjectAreaChangeMonitoringEnabled改为YES
    [self.capture lockForConfiguration:nil];
    self.capture.subjectAreaChangeMonitoringEnabled = YES;
    [self.capture unlockForConfiguration];
    // 设置会话对象
    self.session = [[AVCaptureSession alloc] init];
    // 设置会话采集率
    self.session.sessionPreset = AVCaptureSessionPreset1920x1080;
    
    // 创建摄像设备输入流
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.capture error:nil];
    [self.session addInput:self.input];
    
    // 创建元数据输出流
    AVCaptureMetadataOutput *metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
    [metaDataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 设置扫描范围（取值0~1，以屏幕右上角为原点）
    metaDataOutput.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    // 添加元数据输出流到会话对象
    [self.session addOutput:metaDataOutput];
    
    // 创建摄像设备输出流，用于识别光线强弱
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    // 添加摄像设备输出流到会话对象
    [self.session addOutput:videoDataOutput];
    
    NSArray *keys=@[
        // 二维码
        AVMetadataObjectTypeQRCode,
        // 以下是条形码
        AVMetadataObjectTypeUPCECode,
        AVMetadataObjectTypeEAN8Code,
        AVMetadataObjectTypeEAN13Code,
        AVMetadataObjectTypeAztecCode,
        AVMetadataObjectTypeCode39Code,
        AVMetadataObjectTypeCode93Code,
        AVMetadataObjectTypePDF417Code,
        AVMetadataObjectTypeCode128Code,
        AVMetadataObjectTypeCode39Mod43Code,
    ];
    metaDataOutput.metadataObjectTypes = keys;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureDeviceSubjectAreaDidChangeNotification:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.capture];
}

#pragma mark - ------< 初始化预览视图 >------
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    if (_previewLayer.session == nil) {
        [_previewLayer setSession:self.session];
    }
    return _previewLayer;
}

#pragma mark - ------< 预览视图的父视图，用于自动放大，手势放大等>------
- (UIView *)captureView {
    if (!_captureView) {
        _captureView = [[UIView alloc] init];
        [_captureView.layer addSublayer:self.previewLayer];
    }
    return _captureView;
}

#pragma mark - ------< 查询是否有相机访问权限 >------
- (BOOL)isAuthority {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {
        return YES;
    } else {
        NSLog(@"相机访问权限已被禁止，请在\"设置 - 隐私 - 相机\"选项中，允许多客访问您的相机");
        return NO;
    }
}

#pragma mark - ------< 获取相机访问权限 >------
- (void)getCaptureAuthority {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initCapture];
                [self startRunning];
            });
        } else {
            NSLog(@"被用户拒绝");
        }
    }];
}

#pragma mark - ------< AVCaptureMetadataOutputObjectsDelegate >------
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(nonnull NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(nonnull AVCaptureConnection *)connection {
    NSLog(@"%@",metadataObjects);
    if (metadataObjects == nil) return;
    NSString *scanText = nil;
    for (AVMetadataMachineReadableCodeObject *obj in metadataObjects) {
        NSString *text = obj.stringValue;
        if (text && text.length) {
            scanText = text;
        }
    }
    NSLog(@"====1%@",scanText);
}

#pragma mark - ------< AVCaptureVideoDataOutputSampleBufferDelegate >------
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer fromConnection:(nonnull AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    CGFloat brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    NSLog(@"====%f",brightnessValue);
}

#pragma mark - ------< 开启会话 >------
- (void)startRunning {
    if ([self isAuthority] == NO) {
        [self getCaptureAuthority];
        return;
    }
    
    if (self.showView == nil) {
        NSLog(@"预览父视图不存在");
        return;
    }
    if (self.captureView.superview == nil) {
        [self.showView insertSubview:self.captureView atIndex:0];
        self.captureView.frame = self.showView.bounds;
        self.previewLayer.frame = self.captureView.bounds;
        
        //给预览父视图添加单击和双击手势
        [self captureViewAddSingleAndDoubleTap];
    }
    if (self.session == nil) {
        NSLog(@"会话对象不存在");
        return;
    }
    [self.session startRunning];
}

#pragma mark - ------< 关闭会话 >------
- (void)stopRunning {
    if (self.session.isRunning) {
        [self.session stopRunning];
    }
}

#pragma mark - ------< 给预览父视图添加单击和双击手势 >------
- (void)captureViewAddSingleAndDoubleTap {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    [self.captureView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.captureView addGestureRecognizer:doubleTap];
    
    // 优先触发双击
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)singleTapAction:(UITapGestureRecognizer *)singleTap {
    if (self.isSingleTapAutoFocus == NO) return;
    CGPoint p = [singleTap locationInView:self.captureView];
    [self setFocusCursorWithPoint:p focusModel:AVCaptureFocusModeAutoFocus];
    
}

- (void)doubleTapAction:(UITapGestureRecognizer *)doubleTap {
    if (self.isDoubleTapScale == YES) return;
    CGPoint p = [doubleTap locationInView:self.captureView];
    NSLog(@"双击:%@",NSStringFromCGPoint(p));
}

#pragma mark - ------< 通知 >------
- (void)captureDeviceSubjectAreaDidChangeNotification:(NSNotification *)notif {
    CGPoint point = self.captureView.center;
    [self setFocusCursorWithPoint:point focusModel:AVCaptureFocusModeContinuousAutoFocus];
}

- (void)setFocusCursorWithPoint:(CGPoint)point focusModel:(AVCaptureFocusMode)focusModel{
    // 先判断是否支持控制对焦
    if (self.capture.isFocusPointOfInterestSupported && [self.capture isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        //对拍照设备操作前，先进行锁定，防止其他线程w访问
        NSError *error = nil;
        if ([self.capture lockForConfiguration:&error]) {
            self.capture.focusMode = focusModel;
            CGSize size = self.previewLayer.bounds.size;
            CGPoint focusPoint = CGPointMake(point.y / size.height, 1-point.x/size.width);
            self.capture.focusPointOfInterest = focusPoint;
        }
        [self.capture unlockForConfiguration];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.captureView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                self.captureView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
}

//-(void)setFocusCursorWithPoint:(CGPoint)point{
//     //下面是手触碰屏幕后对焦的效果
//    _focusView.center = point;
//    _focusView.hidden = NO;
//
//    [UIView animateWithDuration:0.3 animations:^{
//        _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
//    }completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.5 animations:^{
//            _focusView.transform = CGAffineTransformIdentity;
//        } completion:^(BOOL finished) {
//            _focusView.hidden = YES;
//        }];
//    }];
//
//}

- (void)dealloc {
    NSLog(@"===== %@ release =====",NSStringFromClass(self.class));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
