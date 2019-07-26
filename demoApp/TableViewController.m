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
#import "InfoDatabase.h"
#import "loginViewController.h"
#import "hudView.h"

@interface TableViewController ()<firstTableViewCellDelegate>
@property (strong, nonatomic) NSMutableArray <firstTableModel *>*modelList; // 書類配列
@property (strong, nonatomic) UIButton *nextBT; // 「次へ」ボタン
@property (strong, nonatomic) firstTableModel *currentModel; // 選択する書類
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 共通領域のデータを取得する
    [self initData];
    
    // 画面初期化
    [self initView];
    
    // プログレスバーを表示する
    [self initProgressBar];
}

// 共通領域のデータを取得する
- (void)initData{
    
    // 共通領域初期化
    CONFIG_FILE_DATA *db = [InfoDatabase shareInfoDatabase].configFileData;
    SystemCode *sysCode = [Utils getSystemCode];
    
    int enable = sysCode.identification_KBN.IDENTIFICATION_ENABLE.code;
    ID_DOC_KBN * idDoc = sysCode.id_doc_KBN;
    
    // 設定ファイルデータで有効となっている本人確認書類に対し、選択ボタンを表示する。
    self.modelList = [NSMutableArray array];
    if (db.IDENTIFICATION_DOCUMENT_DRIVERS_LICENCE == enable) [self.modelList addObject:[[firstTableModel alloc] initWithKBNModel:idDoc.CARD_DRIVER]];

    if (db.IDENTIFICATION_DOCUMENT_MYNUMBER == enable) [self.modelList addObject:[[firstTableModel alloc] initWithKBNModel:idDoc.CARD_MYNUMBER]];
    
    if (db.IDENTIFICATION_DOCUMENT_PASSPORT == enable) [self.modelList addObject:[[firstTableModel alloc] initWithKBNModel:idDoc.CARD_PASSPORT]];
    
    if (db.IDENTIFICATION_DOCUMENT_RESIDENCE == enable) [self.modelList addObject:[[firstTableModel alloc] initWithKBNModel:idDoc.CARD_RESIDENCE]];
    
    if (db.IDENTIFICATION_DOCUMENT_SPECIAL_PERMANENT_RESIDENT_CERTIFICATE == enable) [self.modelList addObject:[[firstTableModel alloc] initWithKBNModel:idDoc.CARD_SPECIALIP]];
}

// 画面初期化
- (void)initView{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[firstTableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    self.tableView.bounces = NO;
    UIButton *footBT = [UIButton buttonWithType:UIButtonTypeCustom];
    [footBT setFrame:CGRectMake(16, [UIScreen mainScreen].bounds.size.height - 68 - 64, [UIScreen mainScreen].bounds.size.width - 32, 54)];
    [footBT setTitle:@"次へ" forState:UIControlStateNormal];
    [footBT addTarget:self action:@selector(goNextView) forControlEvents:UIControlEventTouchUpInside];
    footBT.backgroundColor = kBaseColorUnEnabled;
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

// 「次へ」ボタンをタップ時、イベント処理を実施する。
- (void)goNextView {
    // 共通領域初期化
    InfoDatabase *db = [InfoDatabase shareInfoDatabase];
    SystemCode *sysCode = [Utils getSystemCode];
    KBNModel *camera = sysCode.read_method_KBN.CAMERA;
    KBNModel *nfc = sysCode.read_method_KBN.NFC;
    int unenable = sysCode.enable_KBN.UNENFORCE.code;
    
    // 本人確認内容データへ本人確認書類区分を設定する
    db.identificationData.DOC_TYPE = self.currentModel.kbnModel.code;
    
    // 本人確認内容データへ読取方法を設定する
    if (db.configFileData.NFC_ENABLE == unenable) {
        
        // NFC読込みを実施しないの場合、「1:カメラ撮影」を設定する。
        db.identificationData.GAIN_TYPE = camera.code;
    }
    if (db.configFileData.CAMERA_ENABLE == unenable) {
        
        // カメラ撮影を実施しないの場合、「2:NFC読取」を設定する。
        db.identificationData.GAIN_TYPE = nfc.code;
    }
    
    UIViewController *nextController;
    if (db.identificationData.GAIN_TYPE == camera.code) {
        
        // カメラ撮影の場合、「G0040-01： 本人確認書類撮影開始前画面」へ遷移する。
        hudView *hud = [[hudView alloc] initWithModel:self.currentModel andController:self];
        [hud show];
    } else if (db.identificationData.GAIN_TYPE == nfc.code) {
        
        // NFC読取の場合、「G0070-01：暗証番号入力画面」へ遷移する
        loginViewController *log = [[loginViewController alloc] init];
        log.currentModel = self.currentModel;
        nextController = log;
    } else {
        
        // 未設定の場合、「G0030-01：読取方法選択画面」へ遷移する。
        UIButton *bt1 = [UIButton buttonWithType:UIButtonTypeCustom];
        bt1.backgroundColor = [UIColor whiteColor];
        [bt1 setImage:[UIImage imageNamed:camera.STM1] forState:UIControlStateNormal];
        [bt1 setTitle:@"カメラ撮影" forState:UIControlStateNormal];
        [bt1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        bt1.adjustsImageWhenHighlighted = NO;
        bt1.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 50);
        bt1.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        bt1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [bt1 setFrame:CGRectMake(0, 0, 1, 1)];
        bt1.layer.borderColor = kLineColor.CGColor;
        bt1.layer.borderWidth = [UITool shareUITool].lineWidth;
        bt1.layer.cornerRadius = 20.0f;
        //    bt1.layer.shadowOpacity = 0.1f;
        //    bt1.layer.shadowOffset = CGSizeMake(4, 4);
        bt1.layer.masksToBounds = NO;
        
        UIButton *bt2 = [UIButton buttonWithType:UIButtonTypeCustom];
        bt2.backgroundColor = [UIColor whiteColor];
        [bt2 setImage:[UIImage imageNamed:nfc.STM1] forState:UIControlStateNormal];
        [bt2 setTitle:@"NFC読み取り" forState:UIControlStateNormal];
        [bt2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        bt2.adjustsImageWhenHighlighted = NO;
        bt2.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 50);
        bt2.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        bt2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [bt2 setFrame:CGRectMake(0, 0, 1, 1)];
        bt2.layer.borderColor = kLineColor.CGColor;
        bt2.layer.borderWidth = [UITool shareUITool].lineWidth;
        bt2.layer.cornerRadius = 20.0f;
        //    bt2.layer.shadowOpacity = 0.15f;
        //    bt2.layer.shadowOffset = CGSizeMake(4, 4);
        bt2.layer.masksToBounds = NO;
        
        secondViewController *s = [[secondViewController alloc] init];
        s.currentModel = self.currentModel;
        s.bt1 = bt1;
        s.bt2 = bt2;
        
        nextController = s;
    }
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] init];
    back.title = @"";
    self.navigationItem.backBarButtonItem = back;
    [self.navigationController pushViewController:nextController animated:YES];
}

#pragma mark - delegate

// firstTableViewCellDelegate
- (void)didSelectItem:(firstTableModel *)model{
    self.currentModel = model;
    
    // 「次へ」ボタンを活性化させる。
    self.nextBT.userInteractionEnabled = true;
    [self.nextBT setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextBT.backgroundColor = kBaseColor;
    [self.tableView reloadData];
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
    sectionL.textColor = kBodyTextColor;
    [view addSubview:sectionL];
    return view;
}

- (void)backTo{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)initProgressBar {
    UIProgressView *p = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 2)];
    p.trackTintColor = [UIColor lightGrayColor];
    p.tintColor = kBaseColor;
    [p setProgress:0.1 animated:NO];
    [self.view addSubview:p];
}
@end
