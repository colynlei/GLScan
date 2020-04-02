//
//  GLGenerateQRCodeViewController.m
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/3/23.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import "GLGenerateQRCodeViewController.h"
#import "GLGenerateQRCode.h"
#import "GLScanQRCode.h"

@interface GLGenerateQRCodeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;

@property (weak, nonatomic) IBOutlet UILabel *showQRCodeTextLabel;

@end

@implementation GLGenerateQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textField.text = @"http://www.baidu.com/中华大地";
}

#pragma mark - ------< 异步生成 >------
- (IBAction)asyncGenerateBtnAction:(id)sender {
    [GLGenerateQRCode generateQRCodeWithString:self.textField.text size:200 callBack:^(UIImage * _Nonnull QRCodeImage) {
        self.qrCodeImageView.image = QRCodeImage;
    }];
}

#pragma mark - ------< 同步生成 >------
- (IBAction)syncGenerateBtnAction:(id)sender {
    UIImage *image = [GLGenerateQRCode generateQRCodeWithString:self.textField.text size:200];
    self.qrCodeImageView.image = image;
}

#pragma mark - ------< 清除二维码 >------

- (IBAction)clearQRCodeBtnAction:(id)sender {
    self.qrCodeImageView.image = nil;
    self.showQRCodeTextLabel.text = @"";
}

- (IBAction)qrCodeLongPressAction:(id)sender {
    NSArray *results = [GLScanQRCode getQRCodeFromImage:self.qrCodeImageView.image];
    if (results && results.count) {
        self.showQRCodeTextLabel.text = results.firstObject;
    } else {
        self.showQRCodeTextLabel.text = @"未识别出二维码内容";
    }
}


- (void)dealloc {
    NSLog(@"===== %@ release =====",NSStringFromClass(self.class));
}


@end
