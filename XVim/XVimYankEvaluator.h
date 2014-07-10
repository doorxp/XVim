//
//  XVimYankEvaluator.h
//  XVim
//
//  Created by Shuichiro Suzuki on 2/25/12.
//  Copyright (c) 2012 JugglerShu.Net. All rights reserved.
//

#import "XVimOperatorEvaluator.h"
#import "XVimOperatorAction.h"

@interface XVimYankEvaluator : XVimOperatorEvaluator
- (XVimEvaluator*)y:(XVimWindow*)window;
@end

@interface XVimYankAction : XVimOperatorAction {
	
}
@property (nonatomic, strong)XVimRegister *yankRegister;
- (instancetype)initWithYankRegister:(XVimRegister*)xregister NS_DESIGNATED_INITIALIZER;
@end
