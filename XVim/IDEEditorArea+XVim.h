//
//  IDEEditorArea+XVim.h
//  XVim
//
//  Created by Suzuki Shuichiro on 5/18/12.
//  Copyright (c) 2012 JugglerShu.Net. All rights reserved.
//

#import "IDEKit.h"
#import "XVimCommandLine.h"

@interface IDEEditorArea (XVim)
@property (NS_NONATOMIC_IOSONLY, readonly, strong) NSView *textViewArea;
- (void)setupCommandLine;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) XVimCommandLine *commandLine;
@end
