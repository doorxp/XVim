//
//  NSEvent+VimHelper.h
//  XVim
//
//  Created by Marlon Andrade on 08/27/2012.
//
//

#import <Cocoa/Cocoa.h>

@interface NSEvent (VimHelper)

@property (NS_NONATOMIC_IOSONLY, readonly) unichar unmodifiedKeyCode;
@property (NS_NONATOMIC_IOSONLY, readonly) unichar modifiedKeyCode;
    
@end
