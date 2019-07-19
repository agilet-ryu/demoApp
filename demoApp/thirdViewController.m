//
//  thirdViewController.m
//  demoApp
//
//  Created by agilet on 2019/06/19.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "thirdViewController.h"
#import "UITool.h"
#import "fouthViewController.h"
#import "faceIDManager.h"
#import "CameraScanManager.h"
#import "hudView.h"
#import "OCRResultViewController.h"

@interface thirdViewController ()<faceIDManagerDelegate, cameraScanManagerDelegate>

@property (nonatomic, strong) UIButton *nextBT;
@property (nonatomic, assign) BOOL isFront;
@property (nonatomic, strong) CameraScanManager *cameraScanManager;
@property (nonatomic, strong) UIImageView *img1;
@property (nonatomic, strong) UIImageView *img2;
@property (nonatomic, strong) hudView *myHudView;
@property (nonatomic, strong) UIButton *checkbox1;
@property (nonatomic, strong) UIButton *checkbox2;
@property (nonatomic, strong) UIButton *camera1;
@property (nonatomic, strong) UIButton *camera2;
@end

@implementation thirdViewController

- (CameraScanManager *)cameraScanManager{
    if (!_cameraScanManager) {
        _cameraScanManager = [CameraScanManager sharedCameraScanManager];
        _cameraScanManager.delegate = self;
    }
    return _cameraScanManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initScrollView];
    [self initProgressBar];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.cameraScanManager.delegate = self;
    [self.img1 setImage:self.currentModel.frontImage];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    for (UIView *v in self.view.subviews) {
        v.hidden = NO;
    }
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)initProgressBar {
    UIProgressView *p = [[ UIProgressView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 2)];
    p.trackTintColor = [UIColor lightGrayColor];
    p.tintColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0];
    [p setProgress:0.5 animated:NO];
    [self.view addSubview:p];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(backTo)];
    self.navigationItem.rightBarButtonItem = back;
}

- (void)backTo{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)initView {
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title = @"";
    self.navigationItem.backBarButtonItem = back;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"撮影結果の確認";
    
    UIButton *footBT = [UIButton buttonWithType:UIButtonTypeCustom];
    [footBT setFrame:CGRectMake(16, [UIScreen mainScreen].bounds.size.height - 68, [UIScreen mainScreen].bounds.size.width - 32, 54)];
    [footBT setTitle:@"次へ" forState:UIControlStateNormal];
    [footBT addTarget:self action:@selector(goNextView) forControlEvents:UIControlEventTouchUpInside];
    footBT.backgroundColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:0.3f];
    footBT.userInteractionEnabled = false;
    footBT.layer.cornerRadius = 6.0f;
//    footBT.layer.shadowOpacity = 0.15f;
//    footBT.layer.shadowOffset = CGSizeMake(6, 6);
    footBT.layer.masksToBounds = NO;
    [self.view addSubview:footBT];
    self.nextBT = footBT;
}

- (void)initScrollView{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 132)];
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    UILabel *sectionL = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, [UIScreen mainScreen].bounds.size.width - 32, 100)];
    sectionL.numberOfLines = 0;
    sectionL.textAlignment = NSTextAlignmentLeft;
    sectionL.text = [NSString stringWithFormat:@"記載されている文字がはっきり読めることを確認してください。"];
    sectionL.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    sectionL.textColor = [UIColor colorWithHexString:[UITool shareUITool].bodyTextColorHexString alpha:1.0f];
    [scrollView addSubview:sectionL];
    
    UILabel *frontTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 100, [UIScreen mainScreen].bounds.size.width - 32, 25)];
    frontTitle.textAlignment = NSTextAlignmentCenter;
    frontTitle.text = [NSString stringWithFormat:@"表面"];
    frontTitle.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    [scrollView addSubview:frontTitle];
    
    UIImageView *img1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic3"]];
    [img1 setImage:self.currentModel.frontImage];
    [img1 setFrame:CGRectMake(40, 145, [UIScreen mainScreen].bounds.size.width - 80, 200)];
    [scrollView addSubview:img1];
    self.img1 = img1;
    
    UIButton *check1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [check1 setFrame:CGRectMake(40, 425, [UIScreen mainScreen].bounds.size.width - 80, 30)];
    [check1 addTarget:self action:@selector(didCheck1:) forControlEvents:UIControlEventTouchUpInside];
    [check1 setImage:[UIImage imageNamed:@"pic5"] forState:UIControlStateNormal];
    [check1 setImage:[UIImage imageNamed:@"pic6"] forState:UIControlStateSelected];
    [check1 setTitleColor:[UIColor colorWithHexString:[UITool shareUITool].bodyTextColorHexString alpha:1.0f] forState:UIControlStateNormal];
    [check1 setTitle:@"確認しました。" forState:UIControlStateNormal];
    check1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [scrollView addSubview:check1];
    self.checkbox1 = check1;
    
    UIButton *BT1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [BT1 setFrame:CGRectMake(40, 365, [UIScreen mainScreen].bounds.size.width - 80, 50)];
    BT1.backgroundColor = [UIColor whiteColor];
    [BT1 setTitle:@"再撮影" forState:UIControlStateNormal];
    [BT1 addTarget:self action:@selector(didBT1Click) forControlEvents:UIControlEventTouchUpInside];
    
    [BT1 setTitleColor:[UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f] forState:UIControlStateNormal];
    BT1.layer.borderWidth = [UITool shareUITool].lineWidth;
    BT1.layer.cornerRadius = 3.0f;
    BT1.layer.borderColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f].CGColor;
    BT1.layer.masksToBounds = YES;
    
    BT1.userInteractionEnabled = !check1.isSelected;
    [scrollView addSubview:BT1];
    self.camera1 = BT1;
    
    UILabel *backTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 485, [UIScreen mainScreen].bounds.size.width - 32, 25)];
    backTitle.textAlignment = NSTextAlignmentCenter;
    backTitle.text = [NSString stringWithFormat:@"裏面"];
    backTitle.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    [scrollView addSubview:backTitle];

    UIImageView *img2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic4"]];
    [img2 setImage:self.currentModel.behindImage];
    [img2 setFrame:CGRectMake(40, 530, [UIScreen mainScreen].bounds.size.width - 80, 200)];
    [scrollView addSubview:img2];
    self.img2 = img2;
    
    UIButton *check = [UIButton buttonWithType:UIButtonTypeCustom];
    [check setFrame:CGRectMake(40, 810, [UIScreen mainScreen].bounds.size.width - 80, 30)];
    [check addTarget:self action:@selector(didCheck2:) forControlEvents:UIControlEventTouchUpInside];
    [check setImage:[UIImage imageNamed:@"pic5"] forState:UIControlStateNormal];
    [check setImage:[UIImage imageNamed:@"pic6"] forState:UIControlStateSelected];
    [check setTitleColor:[UIColor colorWithHexString:[UITool shareUITool].bodyTextColorHexString alpha:1.0f] forState:UIControlStateNormal];
    [check setTitle:@"確認しました。" forState:UIControlStateNormal];
    check.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [scrollView addSubview:check];
    self.checkbox2 = check;

    UIButton *BT2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [BT2 setFrame:CGRectMake(40, 750, [UIScreen mainScreen].bounds.size.width - 80, 50)];
    [BT2 setTitle:@"再撮影" forState:UIControlStateNormal];
    [BT2 addTarget:self action:@selector(didBT2Click) forControlEvents:UIControlEventTouchUpInside];
    
    BT2.backgroundColor = [UIColor whiteColor];
    [BT2 setTitleColor:[UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f] forState:UIControlStateNormal];
    BT2.layer.borderWidth = [UITool shareUITool].lineWidth;
    BT2.layer.cornerRadius = 3.0f;
    BT2.layer.borderColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f].CGColor;
    BT2.layer.masksToBounds = YES;

    BT2.userInteractionEnabled = !check.isSelected;
    [scrollView addSubview:BT2];
    self.camera2 = BT2;

    [scrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 850)];
}

#pragma mark - 再摄影点击时
- (void)didBT1Click{
    self.isFront = YES;
    for (UIView *v in self.view.subviews) {
        v.hidden = YES;
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor blackColor];
    [self.cameraScanManager start];
}

- (void)didBT2Click{
    self.isFront = NO;
    for (UIView *v in self.view.subviews) {
        v.hidden = YES;
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.view.backgroundColor = [UIColor blackColor];
    [self.cameraScanManager start];
}

#pragma mark - checkbox点击时
- (void)didCheck1:(UIButton *)button{
    [self checkNextButton:button andCameraButton:self.camera1];
}
- (void)didCheck2:(UIButton *)button{
    [self checkNextButton:button andCameraButton:self.camera2];
}
- (void)checkNextButton:(UIButton *)button andCameraButton:(UIButton *)cameraButton{
    button.selected = !button.isSelected;
    
    cameraButton.backgroundColor = button.isSelected ? [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:0.3f] : [UIColor whiteColor];
    cameraButton.layer.borderColor = button.isSelected ? [UIColor clearColor].CGColor : [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f].CGColor;
    cameraButton.userInteractionEnabled = !button.isSelected;
    button.isSelected ? [cameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal] : [cameraButton setTitleColor:[UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f] forState:UIControlStateNormal];
    
    self.nextBT.backgroundColor = self.checkbox1.isSelected && self.checkbox2.isSelected ? [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f] : [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:0.3f];
    self.nextBT.userInteractionEnabled = self.checkbox1.isSelected && self.checkbox2.isSelected;
}

#pragma mark - cameraScan回调
- (void)cameraScanSuccessWithImage:(UIImage *)image{
    self.isFront ? [self.currentModel setFrontImage:image] : [self.currentModel setBehindImage:image];
    self.isFront ? [self.img1 setImage:image] : [self.img2 setImage:image];
}

- (void)goNextView{
    hudView *hud = [[hudView alloc] initWithModel:nil isFront:nil];
    [hud show];
    self.myHudView = hud;
    [self performSelector:@selector(goToOCRView) withObject:nil afterDelay:2.0f];
}

- (void)goToOCRView{
    OCRResultViewController *ocr = [[OCRResultViewController alloc] init];
    ocr.currentModel = self.currentModel;
    [self.myHudView hide];
    [self.navigationController pushViewController:ocr animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
