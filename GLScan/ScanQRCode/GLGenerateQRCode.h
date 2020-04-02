//
//  GLGenerateQRCode.h
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/3/23.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface GLGenerateQRCode : NSObject

/// 异步生成二维码，以免阻塞线程，生成完回到主线程，size默认 100
+ (void)generateQRCodeWithString:(NSString *)string size:(CGFloat)size callBack:(void(^)(UIImage *QRCodeImage))callBackBlock;

/// 异步生成二维码,size默认 100
+ (UIImage *)generateQRCodeWithString:(NSString *)string size:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
