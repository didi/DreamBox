//
//  DBReferenceModel.m
//  DreamBox_iOS
//
//  Created by zhangchu on 2020/12/19.
//

#import "DBReferenceModel.h"
#import "NSDictionary+DBExtends.h"

@implementation DBReferenceModel

+ (DBReferenceModel *)modelWithDict:(NSDictionary *)dict{
    DBReferenceModel *model = [[DBReferenceModel alloc] init];
    
    model.marginTop = [dict db_objectForKey:@"marginTop"];
    model.marginBottom = [dict db_objectForKey:@"marginBottom"];
    model.marginLeft = [dict db_objectForKey:@"marginLeft"];
    model.marginRight = [dict db_objectForKey:@"marginRight"];
    
    model.paddingTop = [dict db_objectForKey:@"paddingTop"];
    model.paddingLeft = [dict db_objectForKey:@"paddingLeft"];
    model.paddingRight = [dict db_objectForKey:@"paddingRight"];
    model.paddingBottom = [dict db_objectForKey:@"paddingBottom"];
    
    model.width = [dict db_objectForKey:@"width"];
    model.height = [dict db_objectForKey:@"height"];
    model.maxWidth = [dict db_objectForKey:@"maxWidth"];
    model.minWidth = [dict db_objectForKey:@"minWidth"];
    model.maxHeight = [dict db_objectForKey:@"maxHeight"];
    model.minHeight = [dict db_objectForKey:@"minHeight"];
    
    //相对约束属性
    model.leftToLeft = [dict db_objectForKey:@"leftToLeft"];
    model.leftToRight = [dict db_objectForKey:@"leftToRight"];
    model.rightToRight = [dict db_objectForKey:@"rightToRight"];
    model.rightToLeft = [dict db_objectForKey:@"rightToLeft"];
    model.topToTop = [dict db_objectForKey:@"topToTop"];
    model.topToBottom = [dict db_objectForKey:@"topToBottom"];
    model.bottomToTop = [dict db_objectForKey:@"bottomToTop"];
    model.bottomToBottom = [dict db_objectForKey:@"bottomToBottom"];
    
    return model;
}

@end
