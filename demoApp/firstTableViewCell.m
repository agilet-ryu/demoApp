//
//  firstTableViewCell.m
//  demoApp
//
//  Created by agilet on 2019/06/17.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import "firstTableViewCell.h"
#import "UITool.h"

@interface firstTableViewCell()
@property (nonatomic, strong) UIButton *bu;
@end

@implementation firstTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 62)];
        [self initSubView];
    }
    return self;
}

- (void)initSubView{
    UIButton *bu = [UIButton buttonWithType:UIButtonTypeCustom];
    bu.backgroundColor = [UIColor whiteColor];
    [bu setFrame:CGRectMake(16, 4, self.frame.size.width - 32, 50)];
    bu.layer.borderWidth = [UITool shareUITool].lineWidth;
    bu.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [bu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    bu.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    bu.titleLabel.font = [UIFont systemFontOfSize:[UITool shareUITool].textSizeMedium];
    [bu addTarget:self action:@selector(selectItem) forControlEvents:UIControlEventTouchUpInside];
    bu.layer.borderColor = [UIColor colorWithHexString:[UITool shareUITool].lineColorHexString alpha:1.0f].CGColor;
    bu.layer.cornerRadius = 5.0f;
    bu.layer.masksToBounds = YES;
    [self.contentView addSubview:bu];
    self.bu = bu;
}

- (void)setModel:(firstTableModel *)model{
    _model = model;
    [self.bu setTitle:model.buttonTitle forState:UIControlStateNormal];
    self.bu.layer.borderColor = model.isSelected ? [UIColor colorWithHexString:[UITool shareUITool].baseColorHexString alpha:1.0].CGColor : [UIColor colorWithHexString:[UITool shareUITool].lineColorHexString alpha:1.0].CGColor;
//    self.bu.layer.shadowOpacity = 0.15f;
//    self.bu.layer.shadowOffset = CGSizeMake(4, 4);
//    self.bu.layer.masksToBounds = NO;
    model.isSelected = false;
}

- (void)selectItem {
    self.model.isSelected = true;
    if ([self.delegate respondsToSelector:@selector(didSelectItem:)]) {
        [self.delegate didSelectItem:self.model];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
