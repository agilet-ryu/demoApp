//
//  TableViewController.m
//  demoApp
//
//  Created by agilet on 2019/06/17.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "TableViewController.h"
#import "firstTableViewCell.h"
#import "UITool.h"
#import "secondViewController.h"

@interface TableViewController ()<firstTableViewCellDelegate>
@property (strong, nonatomic) NSArray *titleList;
@property (strong, nonatomic) NSMutableArray <firstTableModel *>*modelList;
@property (strong, nonatomic) UIButton *nextBT;
@property (strong, nonatomic) firstTableModel *currentModel;
@end

@implementation TableViewController


- (NSArray *)titleList{
    if (!_titleList) {
        _titleList = @[@"運転免許証",
                       @"マイナンバーカード",
                       @"パスポート",
                       @"在留カード",
                       @"特別永住者証明書",
                       ];
    }
    return _titleList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
    [self initProgressBar];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    firstTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if(!cell){
        cell=[[firstTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    cell.model = [self.modelList objectAtIndex:indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 100;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * view = [[UIView alloc] init];
    UILabel *sectionL = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, [UIScreen mainScreen].bounds.size.width - 32, 100)];
    sectionL.numberOfLines = 0;
    sectionL.text = @"使用する本人確認書類を選択してください。";
    sectionL.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    sectionL.textColor = [UIColor colorWithHexString:[UITool shareUITool].bodyTextColorHexString alpha:1.0f];
    [view addSubview:sectionL];
    return view;
}

- (void)initData{
    self.modelList = [NSMutableArray array];
    for (int i=0; i<self.titleList.count; i++) {
        firstTableModel *model = [[firstTableModel alloc] initWithTitle:[self.titleList objectAtIndex:i] frontImagePath:@"" behindImagePath:@"" isSelected:NO];
        [self.modelList addObject:model];
    }
}

- (void)initView{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[firstTableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    self.tableView.bounces = NO;
    UIButton *footBT = [UIButton buttonWithType:UIButtonTypeCustom];
    [footBT setFrame:CGRectMake(16, [UIScreen mainScreen].bounds.size.height - 68 - 64, [UIScreen mainScreen].bounds.size.width - 32, 54)];
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
    
    self.title = @"本人確認書類の選択";
    [self.tableView setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 50 -64)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(backTo)];
    self.navigationItem.rightBarButtonItem = back;
    [self.navigationItem setHidesBackButton:YES];
}

- (void)didSelectItem:(firstTableModel *)model{
    self.currentModel = model;
    self.nextBT.userInteractionEnabled = true;
    [self.nextBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextBT.backgroundColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0f];
    [self.tableView reloadData];
}

- (void)backTo{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)goNextView {
    UIButton *bt1 = [UIButton buttonWithType:UIButtonTypeCustom];
    bt1.backgroundColor = [UIColor whiteColor];
    [bt1 setImage:[UIImage imageNamed:@"pic1.png"] forState:UIControlStateNormal];
    [bt1 setTitle:@"カメラ撮影" forState:UIControlStateNormal];
    [bt1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    bt1.adjustsImageWhenHighlighted = NO;
    bt1.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 50);
    bt1.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    bt1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [bt1 setFrame:CGRectMake(0, 0, 1, 1)];
    bt1.layer.borderColor = [UIColor colorWithHexString:[UITool shareUITool].lineColorHexString alpha:1.0f].CGColor;
    bt1.layer.borderWidth = [UITool shareUITool].lineWidth;
    bt1.layer.cornerRadius = 20.0f;
//    bt1.layer.shadowOpacity = 0.1f;
//    bt1.layer.shadowOffset = CGSizeMake(4, 4);
    bt1.layer.masksToBounds = NO;
    
    UIButton *bt2 = [UIButton buttonWithType:UIButtonTypeCustom];
    bt2.backgroundColor = [UIColor whiteColor];
    [bt2 setImage:[UIImage imageNamed:@"pic2.png"] forState:UIControlStateNormal];
    [bt2 setTitle:@"NFC読み取り" forState:UIControlStateNormal];
    [bt2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    bt2.adjustsImageWhenHighlighted = NO;
    bt2.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 50);
    bt2.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    bt2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [bt2 setFrame:CGRectMake(0, 0, 1, 1)];
    bt2.layer.borderColor = [UIColor colorWithHexString:[UITool shareUITool].lineColorHexString alpha:1.0f].CGColor;
    bt2.layer.borderWidth = [UITool shareUITool].lineWidth;
    bt2.layer.cornerRadius = 20.0f;
//    bt2.layer.shadowOpacity = 0.15f;
//    bt2.layer.shadowOffset = CGSizeMake(4, 4);
    bt2.layer.masksToBounds = NO;
    
    secondViewController *s = [[secondViewController alloc] init];
    s.currentModel = self.currentModel;
    s.bt1 = bt1;
    s.bt2 = bt2;
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title = @"";
    self.navigationItem.backBarButtonItem = back;
    [self.navigationController pushViewController:s animated:YES];
}

- (void)initProgressBar {
    UIProgressView *p = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 2)];
    p.trackTintColor = [UIColor lightGrayColor];
    p.tintColor = [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0];
    [p setProgress:0.1 animated:NO];
    [self.view addSubview:p];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
