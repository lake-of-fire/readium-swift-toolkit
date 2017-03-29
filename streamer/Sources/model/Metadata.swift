//
//  Metadata.swift
//  R2Streamer
//
//  Created by Alexandre Camilleri on 2/16/17.
//  Copyright © 2017 Readium. All rights reserved.
//

import Foundation
import ObjectMapper
import AEXML

extension MultilangString: Loggable {}

/// `MultilangString` is designed to containe : else a `singleString` (the
/// mainTitle) or a `multiString` (the mainTitle + the altTitles).
/// It has 2 properties because of the JSON serialisation, we need an simple
/// String or an array depending of the situation.
public class MultilangString {
    public var singleString: String?
    public var multiString =  [String: String]()

    public func fill(forElement element: AEXMLElement, _ metadata: AEXMLElement) {
        guard let elementId = element.attributes["id"] else {
            log(level: .error, "The passed element have no id")
            return
        }
        let altScriptAttribute = ["refines": "#\(elementId)", "property": "alternate-script"]

        // Find the <meta refines="elementId" property="alternate-script">
        // in order to find the alternative strings, if any.
        guard let altScriptMetas = metadata["meta"].all(withAttributes: altScriptAttribute) else {
            return
        }
        // For each alt meta element.
        for altScriptMeta in altScriptMetas {
            // If it have a value then add it to the multiString dictionnary.
            guard let title = altScriptMeta.value,
                let lang = altScriptMeta.attributes["xml:lang"] else {
                    continue
            }
            multiString[lang] = title
        }
        // If we have 'alternates'...
        if !multiString.isEmpty {
            // TODO: is that ok "functionnaly"? (it is for contributors, the
            // question is about the titles)
            guard let lang = element.attributes["xml:lang"] else {
                return
            }
            let value = element.value

            // Add the main element to the dictionnary.
            multiString[lang] = value
        }
    }
}

/// The data representation of the <metadata> element of the "*.opf" file.
public class Metadata: Mappable {

    /// The structure used for the serialisation.
    internal var _title: MultilangString?
    /// The publicly accessible publication title (mainTitle).
    public var title: String? {
        get {
            return _title?.singleString
        }
    }
    //
    public var languages = [String]()
    public var identifier: String?
    // Authors, translators and other contributors
    public var authors = [Contributor]()
    public var translators = [Contributor]()
    public var editors = [Contributor]()
    public var artists = [Contributor]()
    public var illustrators = [Contributor]()
    public var letterers = [Contributor]()
    public var pencilers = [Contributor]()
    public var colorists = [Contributor]()
    public var inkers = [Contributor]()
    public var narrators = [Contributor]()
    public var imprints = [Contributor]()
    //
    public var subjects = [Subject]()
    public var publishers = [Contributor]()
    public var contributors = [Contributor]()

    public var modified: Date?
    public var publicationDate: String?
    public var description: String?
    public var direction: String
    public var rendition = Rendition()
    public var source: String?
    public var epubType = [String]()
    public var rights: String?

    public var otherMetadata = [MetadataItem]()

    // MARK: - Public methods.

    public init() {
        direction = "default"
    }

    required public init?(map: Map) {
        direction = "default"
        // TODO: init
    }

    /// Get the title for the given `lang`, if it exists in the dictionnary.
    ///
    /// - Parameter lang: The string representing the lang e.g. "en", "fr"..
    /// - Returns: The corresponding title String in the `lang`language.
    public func titleForLang(_ lang: String) -> String? {
        return _title?.multiString[lang]
    }

    public func mapping(map: Map) {
        var modified = self.modified?.iso8601

        identifier <- map["identifier", ignoreNil: true]
        // If multiString is not empty, then serialize it.
        if var titlesFromMultistring = _title?.multiString,
            !titlesFromMultistring.isEmpty {
            titlesFromMultistring <- map["title"]
            return
        } else {
            var titleForSinglestring = _title?.singleString ?? ""

             titleForSinglestring <- map["title"]
        }
        languages <- map["languages", ignoreNil: true]
        if !authors.isEmpty {
            authors <- map["authors", ignoreNil: true]
        }
        if !translators.isEmpty {
            translators <- map["translators", ignoreNil: true]
        }
        if !editors.isEmpty {
            editors <- map["editors", ignoreNil: true]
        }
        if !artists.isEmpty {
            artists <- map["artists", ignoreNil: true]
        }
        if !illustrators.isEmpty {
            illustrators <- map["illustrators", ignoreNil: true]
        }
        if !letterers.isEmpty {
            letterers <- map["letterers", ignoreNil: true]
        }
        if !pencilers.isEmpty {
            pencilers <- map["pencilers", ignoreNil: true]
        }
        if !colorists.isEmpty {
            colorists <- map["colorists", ignoreNil: true]
        }
        if !inkers.isEmpty {
            inkers <- map["inkers", ignoreNil: true]
        }
        if !narrators.isEmpty {
            narrators <- map["narrators", ignoreNil: true]
        }
        if !contributors.isEmpty {
            contributors <- map["contributors", ignoreNil: true]
        }
        if !publishers.isEmpty {
            publishers <- map["publishers", ignoreNil: true]
        }
        if !imprints.isEmpty {
            imprints <- map["imprints", ignoreNil: true]
        }
        modified <- map["modified", ignoreNil: true]
        publicationDate <- map["publicationDate", ignoreNil: true]
        rendition <- map["rendition", ignoreNil: true]
        source <- map["source", ignoreNil: true]
        rights <- map["rights", ignoreNil: true]
        if !subjects.isEmpty {
            subjects <- map["subjects", ignoreNil: true]
        }
    }
}
