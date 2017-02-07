//  Converted with Swiftify v1.0.6242 - https://objectivec2swift.com/
//
//  GTMNSString+HTML.swift
//  Dealing with NSStrings that contain HTML
//
//  Copyright 2006-2008 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//
import Foundation
/// Utilities for NSStrings containing HTML
extension NSString {
    /// Get a string where internal characters that need escaping for HTML are escaped 
    //
    ///  For example, '&' become '&amp;'. This will only cover characters from table
    ///  A.2.2 of http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
    ///  which is what you want for a unicode encoded webpage. If you have a ascii
    ///  or non-encoded webpage, please use stringByEscapingAsciiHTML which will
    ///  encode all characters.
    ///
    /// For obvious reasons this call is only safe once.
    //
    //  Returns:
    //    Autoreleased NSString
    //
    func gtm_stringByEscapingForHTML() -> String {
        return self.gtm_stringByEscapingHTML(usingTable: gUnicodeHTMLEscapeMap, of: MemoryLayout<gUnicodeHTMLEscapeMap>.size, escapingUnicode: false)
    }
    /// Get a string where internal characters that need escaping for HTML are escaped 
    //
    ///  For example, '&' become '&amp;'
    ///  All non-mapped characters (unicode that don't have a &keyword; mapping)
    ///  will be converted to the appropriate &#xxx; value. If your webpage is
    ///  unicode encoded (UTF16 or UTF8) use stringByEscapingHTML instead as it is
    ///  faster, and produces less bloated and more readable HTML (as long as you
    ///  are using a unicode compliant HTML reader).
    ///
    /// For obvious reasons this call is only safe once.
    //
    //  Returns:
    //    Autoreleased NSString
    //

    func gtm_stringByEscapingForAsciiHTML() -> String {
        return self.gtm_stringByEscapingHTML(usingTable: gAsciiHTMLEscapeMap, of: MemoryLayout<gAsciiHTMLEscapeMap>.size, escapingUnicode: true)
    }
    /// Get a string where internal characters that are escaped for HTML are unescaped 
    //
    ///  For example, '&amp;' becomes '&'
    ///  Handles &#32; and &#x32; cases as well
    ///
    //  Returns:
    //    Autoreleased NSString
    //

    func gtm_stringByUnescapingFromHTML() -> String {
        var range = NSRange(location: 0, length: self.length)
        var subrange: NSRange = (self as NSString).rangeOf("&", options: .backwards, range: range)
        // if no ampersands, we've got a quick way out
        if subrange.length == 0 {

        }
        var finalString: String = self
        repeat {
            var semiColonRange = NSRange(location: subrange.location, length: NSMaxRange(range) - subrange.location)
            semiColonRange = (self as NSString).rangeOf(";", options: [], range: semiColonRange)
            range = NSRange(location: 0, length: subrange.location)
            // if we don't find a semicolon in the range, we don't have a sequence
            if semiColonRange.location == NSNotFound {
                continue
            }
            var escapeRange = NSRange(location: subrange.location, length: semiColonRange.location - subrange.location + 1)
            var escapeString: String = (self as NSString).substring(with: escapeRange)
            var length: Int = (escapeString.characters.count ?? 0)
            // a squence must be longer than 3 (&lt;) and less than 11 (&thetasym;)
            if length > 3 && length < 11 {
                if escapeString[1] == "#" {
                    var char2: unichar = escapeString[2]
                    if char2 == "x" || char2 == "X" {
                            // Hex escape squences &#xa3;
                        var hexSequence: String = (escapeString as NSString).substring(with: NSRange(location: 3, length: length - 4))
                        var scanner = Scanner(string: hexSequence)
                        var value: UInt
                        if scanner.scanHexInt32(value) && value < USHRT_MAX && value > 0 && scanner.scanLocation == length - 4 {
                            var uchar: unichar = value
                            var charString = String(characters: uchar, length: 1)
                            finalString.replaceCharacters(in: escapeRange, with: charString)
                        }
                    }
                    else {
                            // Decimal Sequences &#123;
                        var numberSequence: String = (escapeString as NSString).substring(with: NSRange(location: 2, length: length - 3))
                        var scanner = Scanner(string: numberSequence)
                        var value: Int
                        if scanner.scanInt32(value) && value < USHRT_MAX && value > 0 && scanner.scanLocation == length - 3 {
                            var uchar: unichar = value
                            var charString = String(characters: uchar, length: 1)
                            finalString.replaceCharacters(in: escapeRange, with: charString)
                        }
                    }
                }
                else {
                    // "standard" sequences
                    for i in 0..<MemoryLayout<gAsciiHTMLEscapeMap>.size / MemoryLayout<HTMLEscapeMap>.size {
                        if (escapeString == gAsciiHTMLEscapeMap[i].escapeSequence) {
                            finalString.replaceCharacters(in: escapeRange, with: String(characters: gAsciiHTMLEscapeMap[i].uchar, length: 1))
                            break
                        }
                    }
                }
            }
        } while (subrange = (self as NSString).rangeOf("&", options: .backwards, range: range)).length != 0
        return finalString
    }


    func gtm_stringByEscapingHTML(usingTable table: HTMLEscapeMap, ofSize size: Int, escapingUnicode escapeUnicode: Bool) -> String {
        var length: Int = self.length
        if length == 0 {

        }
        var finalString = String()
        var data2 = Data(capacity: MemoryLayout<unichar>.size * length)
            // this block is common between GTMNSString+HTML and GTMNSString+XML but
            // it's so short that it isn't really worth trying to share.
        let buffer: unichar? = CFStringGetCharactersPtr((self as? CFString))
        if buffer == nil {
                // We want this buffer to be autoreleased.
            var data = Data(length: length * MemoryLayout<UniChar>.size)
            if !data {
                // COV_NF_START  - Memory fail case
                self.GTMDevLog("couldn't alloc buffer")
                return nil
                // COV_NF_END
            }
            self.getCharacters(data.mutableBytes)
            buffer = data.bytes
        }
        if !buffer || !data2 {
            // COV_NF_START
            self.GTMDevLog("Unable to allocate buffer or data2")
            return nil
            // COV_NF_END
        }
        var buffer2: unichar? = (data2.mutableBytes as? unichar)
        var buffer2Length: Int = 0
        for i in 0..<length {
            var val: HTMLEscapeMap? = bsearch(buffer[i], table, size / MemoryLayout<HTMLEscapeMap>.size, MemoryLayout<HTMLEscapeMap>.size, EscapeMapCompare)
            if val || (escapeUnicode && buffer[i] > 127) {
                if buffer2Length != 0 {
                    CFStringAppendCharacters((finalString as? CFMutableStringRef), buffer2, buffer2Length)
                    buffer2Length = 0
                }
                if val != nil {
                    finalString += val?.escapeSequence
                }
                else {
                    self.GTMDevAssert(escapeUnicode && buffer[i] > 127, "Illegal Character")
                    finalString += "&#\(buffer[i]);"
                }
            }
            else {
                buffer2[buffer2Length] = buffer[i]
                buffer2Length += 1
            }
        }
        if buffer2Length != 0 {
            CFStringAppendCharacters((finalString as? CFMutableStringRef), buffer2, buffer2Length)
        }
        return finalString
    }
    // gtm_stringByEscapingHTML
    // gtm_stringByEscapingAsciiHTML
}
typealias HTMLEscapeMap = (: String, uchar: unichar)
// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// Ordered by uchar lowest to highest for bsearching

// A.2.2. Special characters
// A.2.1. Latin-1 characters
// A.2.2. Special characters cont'd
// A.2.3. Symbols
// A.2.2. Special characters cont'd
// A.2.3. Symbols cont'd
// A.2.2. Special characters cont'd
// A.2.3. Symbols cont'd  
// A.2.2. Special characters cont'd
// A.2.3. Symbols cont'd  
// A.2.2. Special characters cont'd
// A.2.3. Symbols cont'd  
// A.2.2. Special characters cont'd
// A.2.3. Symbols cont'd  

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// This is table A.2.2 Special Characters

// C0 Controls and Basic Latin
// Latin Extended-A
// Spacing Modifier Letters
// General Punctuation

// Utility function for Bsearching table above
func EscapeMapCompare(ucharVoid: Void, mapVoid: Void) -> Int {
    let uchar: unichar? = (ucharVoid as? unichar)
    let map: HTMLEscapeMap? = (mapVoid as? HTMLEscapeMap)
    var val: Int
    if uchar > map?.uchar {
        val = 1
    }
    else if uchar < map?.uchar {
        val = -1
    }
    else {
        val = 0
    }

    return val
}