//
//  GLGenerateQRCodeViewController.m
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/3/23.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import "GLGenerateQRCodeViewController.h"
#import "GLGenerateQRCode.h"

@interface GLGenerateQRCodeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImageView;

@end

@implementation GLGenerateQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.textField.text = @"http://www.baidu.com";
}
- (IBAction)generateBtnAction:(id)sender {
    UIImage *image = [GLGenerateQRCode generateQRCodeWithString:self.textField.text size:200];
    self.qrCodeImageView.image = image;
}

- (void)dealloc {
    NSLog(@"===== %@ release =====",NSStringFromClass(self.class));
}

@end
