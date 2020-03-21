//
//  ViewController.m
//  GLScan
//
//  Created by 『国』 🇨🇳 on 2020/3/21.
//  Copyright © 2020 『国』 🇨🇳. All rights reserved.
//

#import "ViewController.h"
#import "GLScanViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)scanBtnAction:(id)sender {
    
    GLScanViewController *scanVC = [[GLScanViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
    
}

@end
