//
//  NSString+GLGenerateQRCode.h
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/4/2.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (GLGenerateQRCode)

/// 异步生成二维码，以免阻塞线程，生成完回到主线程，size默认 100
- (void)generateQRCodeWithSize:(CGFloat)size callBack:(void(^)(UIImage *QRCodeImage))callBackBlock;

/// 同步生成二维码，比较耗时，size默认 100
- (UIImage *)generateQRCodeWithSize:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
