//
//  ViewController.m
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/3/21.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import "ViewController.h"
#import "GLScanViewController.h"
#import "GLScanViewController2.h"
#import "GLGenerateQRCodeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)scanBtn_protocol_Action:(id)sender {
    
    GLScanViewController *scanVC = [[GLScanViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
    
}
- (IBAction)scanBtn_block_Action:(id)sender {
    GLScanViewController2 *scanVC = [[GLScanViewController2 alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (IBAction)generateQRCodeAction:(id)sender {
    GLGenerateQRCodeViewController *vc = [[GLGenerateQRCodeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
