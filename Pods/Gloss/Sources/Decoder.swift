//
//  Decoder.swift
//  Gloss
//
// Copyright (c) 2015 Harlan Kellaway
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

/**
Decodes JSON to objects.
*/
public struct Decoder {
    
    /**
     Decodes JSON to a generic value.
    
    - parameter key: Key used in JSON for decoded value.
    
    - returns: Value decoded from JSON.
    */
    public static func decode<T>(key: String) -> (JSON) -> T? {
        return {
            json in
            
            if let value = json[key] as? T {
                return value
            }
            
            return nil
        }
    }
    
    /**
     Decodes JSON to a date.
     
     - parameter key:           Key used in JSON for decoded value.
     - parameter dateFormatter: Date formatter used to create date.
     
     - returns: Value decoded from JSON.
     */
    public static func decodeDate(key: String, dateFormatter: DateFormatter) -> (JSON) -> NSDate? {
        return {
            json in
            
            if let dateString = json[key] as? String {
                return dateFormatter.date(from: dateString) as NSDate?
            }
            
            return nil
        }
    }
    
    /**
     Decodes JSON to a date array.
     
     - parameter key:           Key used in JSON for decoded value.
     - parameter dateFormatter: Date formatter used to create date.
     
     - returns: Value decoded from JSON.
     */
    public static func decodeDateArray(key: String, dateFormatter: DateFormatter) -> (JSON) -> [NSDate]? {
        return {
            json in
            
            if let dateStrings = json[key] as? [String] {
                var dates: [NSDate] = []
                
                for dateString in dateStrings {
                    guard let date = dateFormatter.date(from: dateString) else {
                        return nil
                    }
                    
                    dates.append(date as NSDate)
                }
                
                return dates
            }
            
            return nil
        }
    }
    
    /**
     Decodes JSON to an ISO8601 date.
     
     - parameter key: Key used in JSON for decoded value.
     
     - returns: Value decoded from JSON.
     */
    public static func decodeDateISO8601(key: String) -> (JSON) -> NSDate? {
        return Decoder.decodeDate(key: key, dateFormatter: GlossDateFormatterISO8601)
    }
    
    /**
     Decodes JSON to an ISO8601 date array.
     
     - parameter key: Key used in JSON for decoded value.
     
     - returns: Value decoded from JSON.
     */
    public static func decodeDateISO8601Array(key: String) -> (JSON) -> [NSDate]? {
        return Decoder.decodeDateArray(key: key, dateFormatter: GlossDateFormatterISO8601)
    }
    
    /**
     Decodes JSON to a Decodable object.
     
     - parameter key: Key used in JSON for decoded value.
     
     - returns: Value decoded from JSON.
     */
    public static func decodeDecodable<T: Decodable>(key: String) -> (JSON) -> T? {
        return {
            json in
            
            if let subJSON = json[key] as? JSON {
                return T(json: subJSON)
            }
            
            return nil
            
        }
    }
    
    /**
     Decodes JSON to a Decodable object array.
     
     - parameter key: Key used in JSON for decoded value.
     
     - returns: Value decoded from JSON.
     */
    public static func decodeDecodableArray<T: Decodable>(key: String) -> (JSON) -> [T]? {
        return {
            json in
            
            if let jsonArray = json[key] as? [JSON] {
                var models: [T] = []
                
                for subJSON in jsonArray {
                    guard let model = T(json: subJSON) else {
                        return nil
                    }
                    
                    models.append(model)
                }
                
                return models
            }
            
            return nil
        }
    }
    
    /**
     Decodes JSON to a dictionary of String to Decodable.
     
     - parameter key: Key used in JSON for decoded value.
     
     - returns: Value decoded from JSON.
     */
    public static func decodeDecodableDictionary<T:Decodable>(key: String) -> (JSON) -> [String : T]? {
        return {
            json in
            
            guard let dictionary = json[key] as? [String : JSON] else {
                return nil
            }
            
            return dictionary.flatMap {
                (key, value) in
                
                guard let decoded = T(json: value) else {
                    return nil
                }
                
                return (key, decoded)
            }
        }
    }
    
    /**
     Decodes JSON to a dictionary of String to Decodable array.
     
     - parameter key: Key used in JSON for decoded value.
     
     - returns: Value decoded from JSON.
     */
    public static func decodeDecodableDictionary<T:Decodable>(key: String) -> (JSON) -> [String : [T]]? {
        return {
            json in
            
            guard let dictionary = json[key] as? [String : [JSON]] else {
                return nil
            }
            
            return dictionary.flatMap {
                (key, value) in
                
                guard let decoded = [T].fromJSONArray(jsonArray: value) else {
                    return nil
                }
                
                return (key, decoded)
            }
        }
    }
    
    /**
     Decodes JSON to an enum value.
     
     - parameter key: Key used in JSON for decoded value.
     
     - returns: Value decoded from JSON.
     */
    public static func decodeEnum<T: RawRepresentable>(key: String) -> (JSON) -> T? {
        return {
            json in
            
            if let rawValue = json[key] as? T.RawValue {
                return T(rawValue: rawValue)
            }
            
            return nil
        }
    }
    
    /**
     Decodes JSON to an enum value array.
     
     - parameter key: Key used in JSON for decoded value.
     
     - returns: Value decoded from JSON.
     */
    public static func decodeEnumArray<T: RawRepresentable>(key: String) -> (JSON) -> [T]? {
        return {
            json in
            
            if let rawValues = json[key] as? [T.RawValue] {
                var enumValues: [T] = []
                
                for rawValue in rawValues {
                    guard let enumValue = T(rawValue: rawValue) else {
                        return nil
                    }
                    
                    enumValues.append(enumValue)
                }
                
                return enumValues
            }
            
            return nil
        }
    }
    
    /**
     Decodes JSON to an Int32.
     
     - parameter key: Key used in JSON for decoded value.
     
     - returns: Value decoded from JSON.
     */
    public static func decodeInt32(key: String) -> (JSON) -> Int32? {
        return {
            json in
            
            if let number = json[key] as? NSNumber {
                return number.int32Value
            }
            
            return nil
        }
    }
    
    /**
     Decodes JSON to an Int32 array.
     
     - parameter key: Key used in JSON for decoded value.
     
     - returns: Value decoded from JSON.
     */
    public static func decodeInt32Array(key: String) -> (JSON) -> [Int32]? {
        return {
            json in
            
            if let numbers = json[key] as? [NSNumber] {
                let ints: [Int32] = numbers.map { $0.int32Value }
                
                return ints
            }
            
            return nil
        }
    }

	/**
	Decodes JSON to an UInt32.

	- parameter key: Key used in JSON for decoded value.

	- returns: Value decoded from JSON.
	*/
	public static func decodeUInt32(key: String) -> (JSON) -> UInt32? {
		return {
			json in

			if let number = json[key] as? NSNumber {
				return number.uint32Value
			}

			return nil
		}
	}

	/**
	Decodes JSON to an UInt32 array.

	- parameter key: Key used in JSON for decoded value.

	- returns: Value decoded from JSON.
	*/
	public static func decodeUInt32Array(key: String) -> (JSON) -> [UInt32]? {
		return {
			json in

			if let numbers = json[key] as? [NSNumber] {
				let uints: [UInt32] = numbers.map { $0.uint32Value }

				return uints
			}

			return nil
		}
	}

    /**
     Decodes JSON to an Int64.

     - parameter key: Key used in JSON for decoded value.

     - returns: Value decoded from JSON.
     */
    public static func decodeInt64(key: String) -> (JSON) -> Int64? {
        return {
            json in
            
            if let number = json[key] as? NSNumber {
                return number.int64Value
            }
            
            return nil
        }
    }
    
    /**
     Decodes JSON to an Int64 array.
     
     - parameter key: Key used in JSON for decoded value.
     
     - returns: Value decoded from JSON.
     */
    public static func decodeInt64Array(key: String) -> (JSON) -> [Int64]? {
        return {
            json in
            
            if let numbers = json[key] as? [NSNumber] {
                let ints: [Int64] = numbers.map { $0.int64Value }
                
                return ints
            }
            
            return nil
        }
    }

	/**
	Decodes JSON to an UInt64.

	- parameter key: Key used in JSON for decoded value.

	- returns: Value decoded from JSON.
	*/
	public static func decodeUInt64(key: String) -> (JSON) -> UInt64? {
		return {
			json in

			if let number = json[key] as? NSNumber {
				return number.uint64Value
			}

			return nil
		}
	}

	/**
	Decodes JSON to an UInt64 array.

	- parameter key: Key used in JSON for decoded value.

	- returns: Value decoded from JSON.
	*/
	public static func decodeUInt64Array(key: String) -> (JSON) -> [UInt64]? {
		return {
			json in

			if let numbers = json[key] as? [NSNumber] {
				let uints: [UInt64] = numbers.map { $0.uint64Value }

				return uints
			}

			return nil
		}
	}

    /**
     Decodes JSON to a URL.

     - parameter key: Key used in JSON for decoded value.

     - returns: Value decoded from JSON.
     */
    public static func decodeURL(key: String) -> (JSON) -> NSURL? {
        return {
            json in
            
            if let urlString = json[key] as? String,
                let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
                return NSURL(string: encodedString)
            }
            
            return nil
        }
    }
    
    /**
     Decodes JSON to a URL array.
     
     - parameter key: Key used in JSON for decoded value.
     
     - returns: Value decoded from JSON.
     */
    public static func decodeURLArray(key: String) -> (JSON) -> [NSURL]? {
        return {
            json in
            
            if let urlStrings = json[key] as? [String] {
                var urls: [NSURL] = []
                
                for urlString in urlStrings {
                    guard let url = NSURL(string: urlString) else {
                        return nil
                    }
                    
                    urls.append(url)
                }
                
                return urls
            }
            
            return nil
        }
    }
    
}
