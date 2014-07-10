//
//  XVim.m
//  XVim
//
//  Created by Shuichiro Suzuki on 1/19/12.
//  Copyright 2012 JugglerShu.Net. All rights reserved.
//

// This is the main class of XVim
// The main role of XVim class is followings.
//    - create hooks.
//    - provide methods used by all over the XVim features.
//
// Hooks:
// The plugin entry point is "load" but does little thing.
// The important method after that is hook method.
// In this method we create hooks necessary for XVim initializing.
// The most important hook is hook for IDEEditorArea and DVTSourceTextView.
// These hook setup command line and intercept key input to the editors.
//
// Methods:
// XVim is a singleton instance and holds objects which can be used by all the features in XVim.
// See the implementation to know what kind of objects it has. They are not difficult to understand.
// 



#import "XVim.h"
#import "Logger.h"
#import "XVimSearch.h"
#import "XVimCharacterSearch.h"
#import "XVimExCommand.h"
#import "XVimKeymap.h"
#import "XVimMode.h"
#import "XVimRegister.h"
#import "XVimKeyStroke.h"
#import "XVimOptions.h"
#import "XVimHistoryHandler.h"
#import "XVimHookManager.h"
#import "XVimCommandLine.h"

static XVim* s_instance = nil;

@interface XVim() {
	XVimHistoryHandler *_exCommandHistory;
	XVimHistoryHandler *_searchHistory;
	XVimKeymap* _keymaps[MODE_COUNT];
    NSFileHandle* _logFile;
}
- (void)parseRcFile;
@property (strong) NSArray *numberedRegisters;
@end

@implementation XVim
@synthesize registers = _registers;
@synthesize repeatRegister = _repeatRegister;
@synthesize recordingRegister = _recordingRegister;
@synthesize lastPlaybackRegister = _lastPlaybackRegister;
@synthesize numberedRegisters = _numberedRegisters;
@synthesize searcher = _searcher;
@synthesize characterSearcher = _characterSearcher;
@synthesize excmd = _excmd;
@synthesize options = _options;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [s_instance.options removeObserver:s_instance forKeyPath:@"debug"];
}

+(void)receiveNotification:(NSNotification*)notification{
    if( [notification.name hasPrefix:@"IDE"] || [notification.name hasPrefix:@"DVT"] ){
        TRACE_LOG(@"Got notification name : %@    object : %@", notification.name, NSStringFromClass([[notification object] class]));
    }
}

+ (void) load 
{ 
    NSBundle* app = [NSBundle mainBundle];
    NSString* identifier = [app bundleIdentifier];
    
    if( ![identifier isEqualToString:@"com.apple.dt.Xcode"] ){
        return;
    }
    // Entry Point of the Plugin.
    [Logger defaultLogger].level = LogTrace;
	
	// Allocate singleton instance
	s_instance = [[XVim alloc] init];
    [s_instance.options addObserver:s_instance forKeyPath:@"debug" options:NSKeyValueObservingOptionNew context:nil];
	[s_instance parseRcFile];
    
    TRACE_LOG(@"XVim loaded");
    
    // This is for reverse engineering purpose. Comment this in and log all the notifications named "IDE" or "DVT"
    //[[NSNotificationCenter defaultCenter] addObserver:[XVim class] selector:@selector(receiveNotification:) name:nil object:nil];
    
    // Do the hooking after the App has finished launching,
    // Otherwise, we may miss some classes.

    // Command line window is not setuped if hook is too late.
    [XVimHookManager hookWhenPluginLoaded];

    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver: [XVimHookManager class]
                                  selector: @selector( hookWhenDidFinishLaunching )
                                   name: NSApplicationDidFinishLaunchingNotification
                                 object: nil];
}

+ (XVim*)instance
{
	return s_instance;
}

//////////////////////////////
// XVim Instance Methods /////
//////////////////////////////

- (instancetype)init
{
	if (self = [super init])
	{
		_excmd = [[XVimExCommand alloc] init];
		_exCommandHistory = [[XVimHistoryHandler alloc] init];
		_searchHistory = [[XVimHistoryHandler alloc] init];
		_searcher = [[XVimSearch alloc] init];
		_characterSearcher = [[XVimCharacterSearch alloc] init];
		_options = [[XVimOptions alloc] init];
		// From the vim documentation:
		// There are nine types of registers:
		// *registers* *E354*
		_registers =
        @{@"DQUOTE": [[XVimRegister alloc] initWithDisplayName:@"\""], 
		 // 2. 10 numbered registers "0 to "9 
		 @"NUM0": [[XVimRegister alloc] initWithDisplayName:@"0"], 
		 @"NUM1": [[XVimRegister alloc] initWithDisplayName:@"1"], 
		 @"NUM2": [[XVimRegister alloc] initWithDisplayName:@"2"], 
		 @"NUM3": [[XVimRegister alloc] initWithDisplayName:@"3"], 
		 @"NUM4": [[XVimRegister alloc] initWithDisplayName:@"4"], 
		 @"NUM5": [[XVimRegister alloc] initWithDisplayName:@"5"], 
		 @"NUM6": [[XVimRegister alloc] initWithDisplayName:@"6"], 
		 @"NUM7": [[XVimRegister alloc] initWithDisplayName:@"7"], 
		 @"NUM8": [[XVimRegister alloc] initWithDisplayName:@"8"], 
		 @"NUM9": [[XVimRegister alloc] initWithDisplayName:@"9"], 
		 // 3. The small delete register "-
		 @"DASH": [[XVimRegister alloc] initWithDisplayName:@"-"], 
		 // 4. 26 named registers "a to "z or "A to "Z
		 @"a": [[XVimRegister alloc] initWithDisplayName:@"a"], 
		 @"b": [[XVimRegister alloc] initWithDisplayName:@"b"], 
		 @"c": [[XVimRegister alloc] initWithDisplayName:@"c"], 
		 @"d": [[XVimRegister alloc] initWithDisplayName:@"d"], 
		 @"e": [[XVimRegister alloc] initWithDisplayName:@"e"], 
		 @"f": [[XVimRegister alloc] initWithDisplayName:@"f"], 
		 @"g": [[XVimRegister alloc] initWithDisplayName:@"g"], 
		 @"h": [[XVimRegister alloc] initWithDisplayName:@"h"], 
		 @"i": [[XVimRegister alloc] initWithDisplayName:@"i"], 
		 @"j": [[XVimRegister alloc] initWithDisplayName:@"j"], 
		 @"k": [[XVimRegister alloc] initWithDisplayName:@"k"], 
		 @"l": [[XVimRegister alloc] initWithDisplayName:@"l"], 
		 @"m": [[XVimRegister alloc] initWithDisplayName:@"m"], 
		 @"n": [[XVimRegister alloc] initWithDisplayName:@"n"], 
		 @"o": [[XVimRegister alloc] initWithDisplayName:@"o"], 
		 @"p": [[XVimRegister alloc] initWithDisplayName:@"p"], 
		 @"q": [[XVimRegister alloc] initWithDisplayName:@"q"], 
		 @"r": [[XVimRegister alloc] initWithDisplayName:@"r"], 
		 @"s": [[XVimRegister alloc] initWithDisplayName:@"s"], 
		 @"t": [[XVimRegister alloc] initWithDisplayName:@"t"], 
		 @"u": [[XVimRegister alloc] initWithDisplayName:@"u"], 
		 @"v": [[XVimRegister alloc] initWithDisplayName:@"v"], 
		 @"w": [[XVimRegister alloc] initWithDisplayName:@"w"], 
		 @"x": [[XVimRegister alloc] initWithDisplayName:@"x"], 
		 @"y": [[XVimRegister alloc] initWithDisplayName:@"y"], 
		 @"z": [[XVimRegister alloc] initWithDisplayName:@"z"], 
		 // 5. four read-only registers ":, "., "% and "#
		 @"COLON": [[XVimRegister alloc] initWithDisplayName:@":"], 
		 @"DOT": [[XVimRegister alloc] initWithDisplayName:@"."], 
		 @"PERCENT": [[XVimRegister alloc] initWithDisplayName:@"%"], 
		 @"NUMBER": [[XVimRegister alloc] initWithDisplayName:@"#"], 
		 // 6. the expression register "=
		 @"EQUAL": [[XVimRegister alloc] initWithDisplayName:@"="], 
		 // 7. The selection and drop registers "*, "+ and "~  
		 @"ASTERISK": [[XVimRegister alloc] initWithDisplayName:@"*"], 
		 @"PLUS": [[XVimRegister alloc] initWithDisplayName:@"+"], 
		 @"TILDE": [[XVimRegister alloc] initWithDisplayName:@"~"], 
		 // 8. The black hole register "_
		 @"UNDERSCORE": [[XVimRegister alloc] initWithDisplayName:@"_"], 
		 // 9. Last search pattern register "/
		 @"SLASH": [[XVimRegister alloc] initWithDisplayName:@"/"], 
		 // additional "hidden" register to store text for '.' command
		 @"repeat": [[XVimRegister alloc] initWithDisplayName:@"repeat"]};

        _numberedRegisters =
        @[[_registers valueForKey:@"NUM0"],
         [_registers valueForKey:@"NUM1"],
         [_registers valueForKey:@"NUM2"],
         [_registers valueForKey:@"NUM3"],
         [_registers valueForKey:@"NUM4"],
         [_registers valueForKey:@"NUM5"],
         [_registers valueForKey:@"NUM6"],
         [_registers valueForKey:@"NUM7"],
         [_registers valueForKey:@"NUM8"],
         [_registers valueForKey:@"NUM9"]];
        
        _recordingRegister = nil;
        _lastPlaybackRegister = nil;
        _repeatRegister = [_registers valueForKey:@"repeat"];
        _logFile = nil;
        
		for (int i = 0; i < MODE_COUNT; ++i)
		{
			_keymaps[i] = [[XVimKeymap alloc] init];
		}
		[XVimKeyStroke initKeymaps];
        
	}
	return self;
}




- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if( [keyPath isEqualToString:@"debug"]) {
        if( [s_instance options].debug ){
            NSString *homeDir = NSHomeDirectoryForUser(NSUserName());
            NSString *logPath = [homeDir stringByAppendingString: @"/.xvimlog"]; 
            [[Logger defaultLogger] setLogFile:logPath];
        }else{
            [[Logger defaultLogger] setLogFile:nil];
        }
    }
}
    
- (void)parseRcFile {
    NSString *homeDir = NSHomeDirectoryForUser(NSUserName());
    NSString *keymapPath = [homeDir stringByAppendingString: @"/.xvimrc"]; 
    NSString *keymapData = [[NSString alloc] initWithContentsOfFile:keymapPath 
                                                           encoding:NSUTF8StringEncoding
															  error:NULL];
	for (NSString *string in [keymapData componentsSeparatedByString:@"\n"])
	{
		[self.excmd executeCommand:[@":" stringByAppendingString:string] inWindow:nil];
	}
}

- (void)writeToLogfile:(NSString*)str{
    return;
    if( ![[self.options getOption:@"debug"] boolValue] ){
        return;
    }
    
    NSString *homeDir = NSHomeDirectoryForUser(NSUserName());
    NSString *logPath = [homeDir stringByAppendingString: @"/.xvimlog"]; 
     if( nil == _logFile){
        NSFileManager* fm = [NSFileManager defaultManager];
         if( [fm fileExistsAtPath:logPath] ){
            [fm removeItemAtPath:logPath error:nil];
        }
        [fm createFileAtPath:logPath contents:nil attributes:nil];
         _logFile = [NSFileHandle fileHandleForWritingAtPath:logPath]; // Do we need to retain this? I want to use this handle as long as Xvim is alive.
        [_logFile seekToEndOfFile];
    }
    
    [_logFile writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
}
- (XVimKeymap*)keymapForMode:(int)mode {
	return _keymaps[mode];
}

- (XVimRegister*)findRegister:(NSString*)name{
    return [self.registers valueForKey:name];
}

- (XVimHistoryHandler*)exCommandHistory
{
    return _exCommandHistory;
}

- (XVimHistoryHandler*)searchHistory
{
	return _searchHistory;
}

- (void)ringBell {
    if (_options.errorbells) {
        NSBeep();
    }
    return;
}

- (void)onDeleteOrYank:(XVimRegister*)yankRegister
{
    // Don't do anything if we are recording into a register (that isn't the repeat register)
    if (self.recordingRegister != nil){
        return;
    }

    // If we are yanking into a specific register then we do not cycle through
    // the numbered registers.
    if (yankRegister != nil){
        [yankRegister clear];
        [yankRegister appendText:[[NSPasteboard generalPasteboard]stringForType:NSStringPboardType]];
    }else{
        // There are 10 numbered registers
        for (NSUInteger i = self.numberedRegisters.count - 2; ; --i){
            XVimRegister *prev = (self.numberedRegisters)[i];
            XVimRegister *next = (self.numberedRegisters)[i+1];
            
            [next clear];
            [next appendText:prev.text];
            if( i == 0 ){
                break;
            }
        }
        
        XVimRegister *reg = (self.numberedRegisters)[0];
        [reg clear];
        [reg appendText:[[NSPasteboard generalPasteboard]stringForType:NSStringPboardType]];
    }
}

- (NSString*)pasteText:(XVimRegister*)yankRegister
{
	if (yankRegister)
	{
		return yankRegister.text;
	}

    return [[NSPasteboard generalPasteboard]stringForType:NSStringPboardType];
}

@end
