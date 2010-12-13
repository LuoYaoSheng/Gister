//
//  Gist.m
//  GistManager
//
//  Created by David Keegan on 12/9/10.
//  Copyright 2010 InScopeApps{+}. All rights reserved.
//

#import "Gist.h"
#import "NSString+Gist.h"
#import <JSON/JSON.h>

@implementation Gist

@synthesize created;
@synthesize description, owner, repository;
@synthesize files;
@synthesize public;

- (void)setPropertiesFromDictionary:(NSDictionary *)aDictionary{
    //2010/10/04 20:04:38 -0700
    //TODO: this is returning null
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] initWithDateFormat:@"yyyy/MM/dd hh:mm:ss" 
                                                         allowNaturalLanguage:NO];
    NSLog(@"%@", [aDictionary objectForKey:@"created_at"]);
    self.created = [dateFormat dateFromString:[aDictionary objectForKey:@"created_at"]];
    self.description = [aDictionary objectForKey:@"description"];
    self.owner = [aDictionary objectForKey:@"owner"];
    self.files = [aDictionary objectForKey:@"files"];
    self.public = [[aDictionary objectForKey:@"public"] boolValue];
    self.repository = [aDictionary objectForKey:@"repo"];    
}

- (id)initWithDictionary:(NSDictionary *)aDictionary{
    self = [super init];
    if(self != nil){
        [self setPropertiesFromDictionary:aDictionary];
    }
    return self;
}

- (id)initWithRepository:(NSString *)aRepository{
    self = [super init];
    if(self != nil){
        NSError *error;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://gist.github.com/api/v1/json/%@", aRepository]];
        NSLog(@"%@", [NSString initFromUrl:url]);
        NSDictionary *data = (NSDictionary *)[[SBJsonParser alloc] objectWithString:[NSString initFromUrl:url] error:&error];
        [self setPropertiesFromDictionary:[[data objectForKey:@"gists"] objectAtIndex:0]];
    }
    return self;
}

- (NSArray *)fullURLs{
    NSMutableArray *sourceUrls = [[NSMutableArray alloc] initWithCapacity:[self.files count]];
    if([self.files count] == 1){
        NSString *url = [NSString stringWithFormat:@"http://gist.github.com/%@.txt", self.repository];
        [sourceUrls addObject:[NSURL URLWithString:url]];
    }else{
        NSError *error;
        //If there is more then one files the only way to get the paths is by parsing an html block on the json return
        NSURL *jsonUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://gist.github.com/%@.json", self.repository]];
        NSLog(@"%@", jsonUrl);
        NSDictionary *data = (NSDictionary *)[[SBJsonParser alloc] objectWithString:[NSString initFromUrl:jsonUrl] error:&error];
        NSString *div = [data objectForKey:@"div"];
        
        //split the html on newlines
        NSArray *lines = [div componentsSeparatedByString:@"\n"];
        NSString *searchUrl = [NSString stringWithFormat:@"gist.github.com/raw/%@", self.repository];
        NSAutoreleasePool *pool =  [[NSAutoreleasePool alloc] init];
        for(NSString *line in lines){
            //see if the search url is in the line
            if([line rangeOfString:searchUrl options:NSCaseInsensitiveSearch].location != NSNotFound){
                NSMutableString *url = [[NSMutableString alloc] init];
                BOOL storeChar = NO;
                //loop over the characters in the string to find the value within the first quotes
                for(NSUInteger i=0; i<[line length]; ++i){
                    NSRange range = NSMakeRange(i, 1);
                    NSString *character = [line substringWithRange:range];
                    if([character isEqualToString:@"\""]){
                        //second quote found, stop searching
                        if(storeChar){
                            break;
                        }else{
                            //quote found, start storing with the next character
                            storeChar = YES;
                            continue;
                        }
                    }
                    if(storeChar){
                        [url appendString:character];
                    }
                }
                [sourceUrls addObject:[NSURL URLWithString:url]];
            }
        }
        [pool drain];
    }
    return sourceUrls;
}

- (NSString *)textForURL:(NSURL *)url{
    return [NSString initFromUrl:url];
}

@end
