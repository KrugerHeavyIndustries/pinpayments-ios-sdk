// __  __ ______ _______ _______ _______ ______
// |  |/  |   __ \   |   |     __|    ___|   __ \
// |     <|      <   |   |    |  |    ___|      <
// |__|\__|___|__|_______|_______|_______|___|__|
//        H E A V Y  I N D U S T R I E S
//
// Copyright (C) 2017 Kruger Heavy Industries
// http://www.krugerheavyindustries.com
//
// This software is provided 'as-is', without any express or implied
// warranty.  In no event will the authors be held liable for any damages
// arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented; you must not
//    claim that you wrote the original software. If you use this software
//    in a product, an acknowledgment in the product documentation would be
//    appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
//    misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source distribution.

#import <objc/runtime.h>

#import "NSObject+Json.h"
#import "NSDateFormatter+iso8601.h"

static NSString* stringFromClass(Class theClass) {
    static NSMapTable *map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    });

    NSString *string = nil;
    @synchronized(map) {
        string = [map objectForKey:theClass];
        if (!string)
        {
            string = NSStringFromClass(theClass);
            [map setObject:string forKey:theClass];
        }
    }
    return string;
}

static Class classFromString(NSString *string) {
    static NSMapTable *map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    });

    Class theClass = nil;
    @synchronized(map)
    {
        theClass = [map objectForKey:string];
        if (!theClass)
        {
            theClass = NSClassFromString(string);
            [map setObject:theClass forKey:string];
        }
    }
    return theClass;
}

@implementation NSObject (Json)

+ (NSDictionary*)jsonMapping {
    return @{};
}

- (void)jsonSetValuesForKeysWithDictionary:(NSDictionary*)dictionary {
    NSDictionary *mapping = [self.class jsonMapping];
    for (NSString* key in dictionary) {
        NSString *propertyName = mapping[key];
        if (propertyName) {
            [self jsonSetValue: [dictionary valueForKey:key] forKey:propertyName];
        }
    }
}

- (void)jsonSetValue:(id)value forKey:(NSString*)mappedKey {
    if (value == [NSNull null]) {
        value = nil;
    }

    NSString *typeAttribute = [self jsonTypeAttributeForKey:mappedKey];
    //NSString *propertyType = [typeAttribute substringFromIndex:1];
    //const char *propertyTypeAsCString = [propertyType UTF8String];

    if ([self jsonIsClassTypeTypeAttribute:typeAttribute]) {

        NSString *className = nil;
        NSArray *protocols = nil;

        [self jsonGetClassName:&className protocols:&protocols fromTypeAttribute:typeAttribute];

        if (className.length == 0)
        {
            // It's an "id".

            // Actually, we should make a compare like this:
            //if (strcmp(propertyTypeAsCString, @encode(id)) == 0)
            //    return YES;
            //
            // However, becuase of the "if" statements, we know that our typeAttribute begins with a "@" and
            // if "className.length" == 0 means that the "rawPropertyType" to be compared is exactly an @encode(id).
            //
            // Therefore, we return directly YES.

            //return YES;
            return;
        } else {
            Class typeClass = classFromString(className);
            if (typeClass) {
                //NSLog(@"%@ --> %@", mappedKey, stringFromClass(typeClass));
                if ([typeClass isSubclassOfClass:NSDate.class]) {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    value = [formatter dateFromISO8601:value];
                } else if ([value isKindOfClass:NSString.class] || [value isKindOfClass:NSNumber.class]) {
                    
                } else if ([typeClass isSubclassOfClass:NSObject.class]) {
                    id instance = nil;
                    instance = [[typeClass alloc] init];
                    [instance jsonSetValuesForKeysWithDictionary:value];
                    value = instance;
                    //return [self jsonValidateAutomaticallyValue:ioValue toClass:typeClass forKey:mappedKey];
                }
            }
        }
        //return NO;
    }

    //NSError *error = nil;
    //BOOL validated = [self jsonValidateValue:&value forKey:mappedKey error:&error];
    
    if (value) {
        [self setValue:value forKey:mappedKey];
    }
}

- (NSString*)jsonTypeAttributeForKey:(NSString*)key {
 
    static NSMutableDictionary *typeAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeAttributes = [NSMutableDictionary dictionary];
    });

    @synchronized (typeAttributes) {
        NSMutableDictionary *classTypeAttributes = typeAttributes[stringFromClass(self.class)];
        if (!classTypeAttributes)
        {
            classTypeAttributes = [NSMutableDictionary dictionary];
            typeAttributes[stringFromClass(self.class)] = classTypeAttributes;
        }

        NSString *typeAttribute = classTypeAttributes[key];
        if (typeAttribute)
            return typeAttribute;

        objc_property_t property = class_getProperty(self.class, key.UTF8String);

        if (!property)
            return nil;

        const char * type = property_getAttributes(property);

        NSString * typeString = @(type);
        NSArray * attributes = [typeString componentsSeparatedByString:@","];
        typeAttribute = attributes[0];

        classTypeAttributes[key] = typeAttribute;

        return typeAttribute;
    }
}

- (BOOL)jsonIsClassTypeTypeAttribute:(NSString*)typeAttribute {
    static NSMutableDictionary *dictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = [NSMutableDictionary dictionary];
    });

    NSNumber *isClassType = nil;
    @synchronized(dictionary) {
        isClassType = dictionary[typeAttribute];
        if (!isClassType)
        {
            isClassType = @([typeAttribute hasPrefix:@"T@"] && ([typeAttribute length] > 1));
            dictionary[typeAttribute] = isClassType;
        }
    }

    return isClassType.boolValue;
}

- (void)jsonGetClassName:(out NSString *__autoreleasing*)className protocols:(out NSArray *__autoreleasing*)protocols fromTypeAttribute:(NSString*)typeAttribute
{
    static NSMutableDictionary *dictionary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = [NSMutableDictionary dictionary];
    });

    // TODO: This synchronization must be optimized
    @synchronized(dictionary) {
        NSArray *array = dictionary[typeAttribute];
        if (array) {
            if (array.count > 0) {
                *className = array[0];
                *protocols = array[1];
            }
            return;
        }

        if ([self jsonIsClassTypeTypeAttribute:typeAttribute]) {
            if (typeAttribute.length < 3) {
                *className = @"";
                return;
            }
            NSString *classAttribute = [typeAttribute substringWithRange:NSMakeRange(3, typeAttribute.length-4)];
            NSString *protocolNames = nil;
            if (classAttribute)
            {
                NSScanner *scanner = [NSScanner scannerWithString:classAttribute];
                [scanner scanUpToString:@"<" intoString:className];
                [scanner scanUpToString:@">" intoString:&protocolNames];
            }

            if (*className == nil)
                *className = @"";

            if (protocolNames.length > 0) {
                protocolNames = [protocolNames substringFromIndex:1];
                protocolNames = [protocolNames stringByReplacingOccurrencesOfString:@" " withString:@""];
                *protocols = [protocolNames componentsSeparatedByString:@","];
            } else {
                *protocols = @[];
            }
            NSArray *array = @[*className, *protocols];
            dictionary[typeAttribute] = array;
        } else {
            dictionary[typeAttribute] = @[];
        }
    }
}
@end
