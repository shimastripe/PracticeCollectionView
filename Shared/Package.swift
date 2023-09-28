// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Shared",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "CustomCell",
            targets: ["CustomCell"]),
        .library(
            name: "DiffableDataSource",
            targets: ["DiffableDataSource"]),
        .library(
            name: "ReconfigureDataSource",
            targets: ["ReconfigureDataSource"]),
    ],
    targets: [
        .target(
            name: "CustomCell"),
        .target(
            name: "DiffableDataSource"),
        .target(
            name: "ReconfigureDataSource"),
    ]
)
