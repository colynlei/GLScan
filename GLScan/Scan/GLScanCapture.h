//
//  GLScanCapture.h
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/3/21.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GLScanCapture;
@protocol GLScanCaptureDelegate <NSObject>

- (void)gl_capture:(GLScanCapture *)scanCapture resultText:(NSString *)resultText;

@end

@interface GLScanCapture : NSObject

/// 初始化方法
/// @param showView 预览图层父视图
- (instancetype)initWithScanShowView:(UIView * _Nullable)showView;

// 接收扫描返回结果可以用代理，也可以用block
@property (nonatomic, weak) id<GLScanCaptureDelegate> delegate;

/// 预览图层父视图，也可以通过初始化方法传入，
@property (nonatomic, strong) UIView *showView;

/// 开启会话
- (void)startRunning;

/// 停止会话
- (void)stopRunning;

/// 是否可以点击自动对焦，默认NO
@property (nonatomic, assign) BOOL isSingleTapAutoFocus;

/// 是否可以双击放大，默认NO
@property (nonatomic, assign) BOOL isDoubleTapScale;

/// 是否可以手势缩放，默认NO
@property (nonatomic, assign) BOOL isPinchScale;

@end

NS_ASSUME_NONNULL_END
