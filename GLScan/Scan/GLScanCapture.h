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

@interface GLScanCapture : NSObject


/// 初始化方法
/// @param showView 预览图层父视图
- (instancetype)initWithScanShowView:(UIView * _Nullable)showView;

/// 预览图层父视图，也可以通过初始化方法传入，
@property (nonatomic, strong) UIView *showView;
/// 开启会话
- (void)startRunning;
/// 停止会话
- (void)stopRunning;

/// 是否可以点击进行自动对焦，默认NO
@property (nonatomic, assign) BOOL isSingleTapAutoFocus;

/// 是否可以双击放大，默认NO
@property (nonatomic, assign) BOOL isDoubleTapScale;

@end

NS_ASSUME_NONNULL_END
