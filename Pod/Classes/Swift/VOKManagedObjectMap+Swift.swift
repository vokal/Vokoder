//
//  VOKManagedObjectMap+Swift.swift
//  Vokoder
//
//  Created by Carl Hill-Popper on 11/13/15.
//  Copyright © 2015 Vokal.
//

public extension VOKManagedObjectMap {

    /**
     Creates a managed object map from a foreign key and String-based enum case
     */
    convenience init<StringEnum: RawRepresentable where StringEnum.RawValue == String>
        (foreignKeyPath: String, coreDataKeyEnum: StringEnum) {
            self.init(foreignKeyPath: foreignKeyPath, coreDataKey: coreDataKeyEnum.rawValue)
    }
}
