//
//  GLScanQRCode.m
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/3/21.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import "GLScanQRCode.h"
#import <Photos/Photos.h>


@interface GLScanQRCode ()<AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;// ios 9 及以下
@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;// iOS 10 及以上

@property (nonatomic, strong) AVCaptureSession *session;// 会话对象

@property (nonatomic, strong) UIView *captureView;// 预览父视图
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;// 预览图层

@property (nonatomic, assign) CGFloat maxZoomFactor;// 最大缩放比例
@property (nonatomic, assign) CGFloat minZoomFactor;// 最小缩放比例
@property (nonatomic, assign) CGFloat currentZoomFactor;// 当前缩放比例

@property (nonatomic, assign) BOOL bHadAutoVideoZoom;

@end

@implementation GLScanQRCode


#pragma mark - ------< 初始化 >------
- (instancetype)initWithScanShowView:(UIView *)showView {
    self = [super init];
    if (self) {
        self.showView = showView;
        [self setDefault];
        [self initCapture];
        
        // 添加主题区域更改监视
        // 当AVCaptureDevice的subjectAreaChangeMonitoringEnabled属性为YES时才会发送此通知
        // 更改subjectAreaChangeMonitoringEnabled属性时需加锁处理
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureDeviceSubjectAreaDidChangeNotification:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.device];
        
        // 屏幕旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarDidChangeFrameNotification:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
        
    }
    return self;
}

#pragma mark - ------< 设置默认参数 >------
- (void)setDefault {
    self.isSingleTapAutoFocus = NO;
    self.isDoubleTapScale = NO;
    self.isPinchScale = NO;
    self.bHadAutoVideoZoom = NO;
}

#pragma mark - ------< 初始化相机等输入对象 >------
- (void)initCapture {
    if ([self isAuthority] == NO) return;
    // 获取摄像设备
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 当启动AVCaptureDeviceSubjectAreaDidChangeNotification通知时
    // 需将subjectAreaChangeMonitoringEnabled改为YES
    [self.device lockForConfiguration:nil];
    self.device.subjectAreaChangeMonitoringEnabled = YES;
    [self.device unlockForConfiguration];
    // 设置会话对象
    self.session = [[AVCaptureSession alloc] init];
    // 设置会话采集率
    self.session.sessionPreset = AVCaptureSessionPreset1920x1080;
    
    // 创建摄像设备输入流
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    // 创建元数据输出流
    AVCaptureMetadataOutput *metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
    [metaDataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 设置扫描范围（取值0~1，以屏幕右上角为原点）
    metaDataOutput.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    // 添加元数据输出流到会话对象
    if ([self.session canAddOutput:metaDataOutput]) {
        [self.session addOutput:metaDataOutput];
    }
    
    // 获取扫码类型
//    [metaDataOutput availableMetadataObjectTypes];//检查类型是否有效
    metaDataOutput.metadataObjectTypes = [self getMetadataObjectTypes];
    
    // 创建摄像设备输出流，用于识别光线强弱
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    // 添加摄像设备输出流到会话对象
    if ([self.session canAddOutput:videoDataOutput]) {
        [self.session addOutput:videoDataOutput];
    }
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = [[NSDictionary alloc]initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey ,nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
}

#pragma mark - ------< 扫码类型 >------
- (NSArray *)getMetadataObjectTypes {
    return @[
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
}

#pragma mark - ------< 获取最大缩放比例 >------
- (CGFloat)maxZoomFactor {
    CGFloat max = 1;
    if (@available(iOS 11.0, *)) {
        max = self.device.maxAvailableVideoZoomFactor;
    } else {
        max = self.device.activeFormat.videoMaxZoomFactor;
    }
    
    // 对最大缩放比例再次做限制
    if (max > 5) {
        max = 5;
    }
    
    return max;
}

#pragma mark - ------< 获取最小缩放比例 >------
- (CGFloat)minZoomFactor {
    CGFloat min = 1;
    if (@available(iOS 11.0, *)) {
        min = self.device.minAvailableVideoZoomFactor;
    }
    return min;
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
        _captureView.alpha = 0;
        
        // 添加预览视图
        [_captureView.layer addSublayer:self.previewLayer];
        
        // 给预览父视图添加单击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
        [_captureView addGestureRecognizer:singleTap];
        
        // 给预览父视图添加双击手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        [_captureView addGestureRecognizer:doubleTap];
        
        // 优先触发双击
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        // 给预览父视图添加缩放手势
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
        [_captureView addGestureRecognizer:pinch];
    }
    return _captureView;
}

#pragma mark - ------< 查询是否有相机访问权限 >------
- (BOOL)isAuthority {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:
            NSLog(@"用户尚未进行授权使用相机操作");
            return NO;
            break;
        case AVAuthorizationStatusRestricted:
            NSLog(@"相机访问权限已被禁止，请在\"设置 - 隐私 - 相机\"选项中，允许多客访问您的相机");
            return NO;
            break;
        case AVAuthorizationStatusDenied:
            NSLog(@"相机访问权限已被禁止，请在\"设置 - 隐私 - 相机\"选项中，允许多客访问您的相机");
            return NO;
            break;
        case AVAuthorizationStatusAuthorized:
            NSLog(@"用户已经授权使用相机");
            return YES;
            break;
            
        default:
            break;
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
    if (!self.bHadAutoVideoZoom) {
        AVMetadataMachineReadableCodeObject *obj = (AVMetadataMachineReadableCodeObject*)[self.previewLayer transformedMetadataObjectForMetadataObject:metadataObjects.lastObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self changeVideoScale:obj];
        });
        self.bHadAutoVideoZoom  =YES;
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(gl_capture:resultText:)]) {
        [self.delegate gl_capture:self resultText:scanText];
    }
}

-(void)changeVideoScale:(AVMetadataMachineReadableCodeObject*)objc{
    NSArray *array = objc.corners;
    CGPoint point = CGPointZero;
    int index = 0;
    CFDictionaryRef dic = (__bridge CFDictionaryRef)(array[index++]);
    // 把字典转换为点，存在point里，成功返回true 其他false
    CGPointMakeWithDictionaryRepresentation(dic, &point);
    CGPoint point2 = CGPointZero;
    CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[2], &point2);
//    self.centerPoint = CGPointMake((point.x + point2.x) / 2, (point.y + point2.y) / 2);
    CGFloat scace = 150/(point2.x-point.x);
    [self setVideoScale:scace];
    
    return;
    
}
-(void)setVideoScale:(CGFloat)scale{
    [self.input.device lockForConfiguration:nil];
    AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:self.stillImageOutput.connections];
    CGFloat maxScaleAndCropfactor = ([[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo]videoMaxScaleAndCropFactor])/16;
    if (scale > maxScaleAndCropfactor) {
        scale = maxScaleAndCropfactor;
        
    }else if (scale < 1){
        scale = 1;
    }
  
    videoConnection.videoScaleAndCropFactor = scale;
    
    //放大预览图
    if ([self.device lockForConfiguration:nil]) {
        [self.device setVideoZoomFactor:1.5];
//        [self.device rampToVideoZoomFactor:1.5 withRate:5];
        [self.device unlockForConfiguration];
    }
}

-(AVCaptureConnection*)connectionWithMediaType:(NSString*)mediaType fromConnections:(NSArray*)connections{
    for (AVCaptureConnection *connection in connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqualToString:mediaType]) {
                return connection;
            }
        }
    }
    return nil;
}

#pragma mark - ------< AVCaptureVideoDataOutputSampleBufferDelegate >------
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer fromConnection:(nonnull AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    CGFloat brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
//    NSLog(@"====%f",brightnessValue);
}

#pragma mark - ------< 开启会话 >------
- (void)startRunning {
    // 查询是否有相机权限
    if ([self isAuthority] == NO) {
        // 无权限时获取权限
        [self getCaptureAuthority];
        return;
    }
    if (self.showView == nil) {
        NSLog(@"预览父视图不存在");
        return;
    }
    if (self.session == nil) {
        NSLog(@"会话对象不存在");
        return;
    }
    if (self.captureView.superview == nil) {
        [self.showView insertSubview:self.captureView atIndex:0];
        self.captureView.frame = self.showView.bounds;
        self.previewLayer.frame = self.captureView.bounds;
        if (self.captureView.alpha != 1) {
            [UIView animateWithDuration:0.3 animations:^{
                self.captureView.alpha = 1;
            }];
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.session startRunning];
    });
}

#pragma mark - ------< 关闭会话 >------
- (void)stopRunning {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.session.isRunning) {
            [self.session stopRunning];
        }
    });
}

#pragma mark - ------< 给预览父视图添加单击手势 >------
- (void)singleTapAction:(UITapGestureRecognizer *)singleTap {
    if (self.isSingleTapAutoFocus == NO || ![self.session isRunning]) return;
    CGPoint tapPoint = [singleTap locationInView:self.captureView];
    [self setFocusCursorWithPoint:tapPoint focusModel:AVCaptureFocusModeAutoFocus];
    
}

#pragma mark - ------< 给预览父视图添加双击手势 >------
- (void)doubleTapAction:(UITapGestureRecognizer *)doubleTap {
    if (self.isDoubleTapScale == NO || ![self.session isRunning]) return;
    CGPoint tapPoint = [doubleTap locationInView:self.captureView];
    [self.device unlockForConfiguration];
    if ([self.device lockForConfiguration:nil]) {
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            self.device.focusPointOfInterest = tapPoint;
            self.device.focusMode = AVCaptureFocusModeAutoFocus;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            if (self.device.videoZoomFactor == self.minZoomFactor) {
                [self.device rampToVideoZoomFactor:self.maxZoomFactor withRate:8];
            } else {
                [self.device rampToVideoZoomFactor:self.minZoomFactor withRate:8];
            }
        }completion:^(BOOL finished) {
            [self.device unlockForConfiguration];
        }];
    }
}

#pragma mark - ------< 给预览父视图添加缩放手势 >------
- (void)pinchAction:(UIPinchGestureRecognizer *)pinch {
    if (self.isPinchScale == NO || ![self.session isRunning]) return;
    if (pinch.state == UIGestureRecognizerStateBegan) {
        self.currentZoomFactor = self.device.videoZoomFactor;
    } else if (pinch.state == UIGestureRecognizerStateChanged) {
        CGFloat currentZoomFactor = self.currentZoomFactor * pinch.scale;        
        if (currentZoomFactor < self.maxZoomFactor &&
            currentZoomFactor > self.minZoomFactor) {
            if ([self.device lockForConfiguration:nil]) {
                self.device.videoZoomFactor = currentZoomFactor;

                [self.device unlockForConfiguration];
            }
        }
    }
}

#pragma mark - ------< 通知 >------
#pragma mark - ------< 主题区域更改通知 >------
- (void)captureDeviceSubjectAreaDidChangeNotification:(NSNotification *)notif {
    CGPoint point = self.captureView.center;
    [self setFocusCursorWithPoint:point focusModel:AVCaptureFocusModeContinuousAutoFocus];
}

- (void)statusBarDidChangeFrameNotification:(NSNotification *)notif {
    self.captureView.frame = self.showView.bounds;
    self.previewLayer.frame = self.captureView.bounds;
}

#pragma mark - ------< 触发对焦 >------
- (void)setFocusCursorWithPoint:(CGPoint)point focusModel:(AVCaptureFocusMode)focusModel{
    //对拍照设备操作前，先进行锁定，防止其他线程w访问
    NSError *error = nil;
    [self.session beginConfiguration];
    if ([self.device lockForConfiguration:&error]) {
        
        // 获取聚焦点
        CGPoint focusPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
        
        // 设置聚焦点，必须先设置聚焦点再设置聚焦模式
        if ([self.device isFocusPointOfInterestSupported]) {
            self.device.focusPointOfInterest = focusPoint;
        }
        
        // 设置聚焦模式
        if ([self.device isFocusModeSupported:focusModel]) {
            self.device.focusMode = focusModel;
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.captureView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self.captureView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [self.device unlockForConfiguration];
                [self.session commitConfiguration];
            }];
        }];
    }
}

#pragma mark - ------< 从图片中获取二维码 >------
- (NSArray *)getQRCodeFromImage:(UIImage *)image {
    return [self getQRCodeFromImageData:UIImagePNGRepresentation(image)];
}

- (NSArray *)getQRCodeFromImageData:(NSData *)imageData {
    return [GLScanQRCode getQRCodeFromImageData:imageData];
}

+ (NSArray *)getQRCodeFromImage:(UIImage *)image {
    return [GLScanQRCode getQRCodeFromImageData:UIImagePNGRepresentation(image)];
}

+ (NSArray *)getQRCodeFromImageData:(NSData *)imageData {
    if (imageData == nil) {
        return nil;
    }
    CIImage *originImage = [CIImage imageWithData:imageData];
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(false),kCIContextPriorityRequestLow:@(false)}];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:originImage];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:0];
    for (CIQRCodeFeature *result in features) {
        if (result.messageString.length) {
            [results addObject:result.messageString];
        }
    }
    return results.copy;
}

- (void)dealloc {
    NSLog(@"===== %@ release =====",NSStringFromClass(self.class));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
