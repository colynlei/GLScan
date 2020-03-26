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

+ (UIImage *)generateQRCodeWithString:(NSString *)string size:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
