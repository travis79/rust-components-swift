// -*- mode: Swift -*-

// AUTOGENERATED BY glean_parser. DO NOT EDIT. DO NOT COMMIT.

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */



import Glean

// swiftlint:disable superfluous_disable_command
// swiftlint:disable nesting
// swiftlint:disable line_length
// swiftlint:disable identifier_name
// swiftlint:disable force_try

extension GleanMetrics {
    class GleanBuild {
        private init() {
            // Intentionally left private, no external user can instantiate a new global object.
        }

        public static let info = BuildInfo(buildDate: DateComponents(calendar: Calendar.current, timeZone: TimeZone(abbreviation: "UTC"), year: 2022, month: 1, day: 20, hour: 15, minute: 10, second: 0))
    }

    enum LoginsStoreMigration {
        /// The total number of login records processed by the migration
        static let numProcessed = CounterMetricType( // generated from logins_store_migration.num_processed
            category: "logins_store_migration",
            name: "num_processed",
            sendInPings: ["metrics"],
            lifetime: .ping,
            disabled: false
        )

        /// The total number of login records successfully migrated
        static let numSucceeded = CounterMetricType( // generated from logins_store_migration.num_succeeded
            category: "logins_store_migration",
            name: "num_succeeded",
            sendInPings: ["metrics"],
            lifetime: .ping,
            disabled: false
        )

        /// The total number of login records which failed to migrate
        static let numFailed = CounterMetricType( // generated from logins_store_migration.num_failed
            category: "logins_store_migration",
            name: "num_failed",
            sendInPings: ["metrics"],
            lifetime: .ping,
            disabled: false
        )

        /// How long the migration tool
        static let totalDuration = TimespanMetricType( // generated from logins_store_migration.total_duration
            category: "logins_store_migration",
            name: "total_duration",
            sendInPings: ["metrics"],
            lifetime: .ping,
            disabled: false,
            timeUnit: .millisecond
        )

        /// Errors discovered in the migration.
        static let errors = StringListMetricType( // generated from logins_store_migration.errors
            category: "logins_store_migration",
            name: "errors",
            sendInPings: ["metrics"],
            lifetime: .ping,
            disabled: false
        )

    }

}
