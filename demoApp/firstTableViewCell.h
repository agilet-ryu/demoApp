//
//  firstTableViewCell.h
//  demoApp
//
//  Created by agilet on 2019/06/17.
//  Copyright © 2019 fujitsu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "firstTableModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol firstTableViewCellDelegate <NSObject>

- (void)didSelectItem:(firstTableModel *)model;

@end

@interface firstTableViewCell : UITableViewCell

@property (strong, nonatomic) firstTableModel *model;
@property (weak, nonatomic) id<firstTableViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
