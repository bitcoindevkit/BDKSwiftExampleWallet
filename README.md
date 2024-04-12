# BDKSwiftExampleWallet

[![License](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue.svg)](https://github.com/reez/BDKSwiftExampleWallet/blob/main/LICENSE)

An example iOS app using [Bitcoin Dev Kit](https://github.com/bitcoindevkit) (BDK)

<img src="Docs/bitcoin-screen.png" alt="Screenshot" width="210.5" height="420">

## Functionality

*This is an experimental work in progress.*

### Wallet

Supports single key HD wallets with BIP86 derivation paths. 

### Implementation

The example `BDKClient` singleton may be found in `Service/BDKService/BDKService.swfit`.

- [x] Create Wallet `Wallet(descriptor: changeDescriptor: network: databaseConfig:)`

- [x] Get Address `getAddress`

- [x] Get Balance `getBalance`

- [x] List Transactions `listTransactions`

- [x] Send `send`

- [x] Sync `sync`

## Swift Packages

- [bdk-swift](https://github.com/bitcoindevkit/bdk-swift)

- [BitcoinUI](https://github.com/reez/BitcoinUI)

- [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess)

## System Requirements

- [Xcode](https://developer.apple.com/xcode/) version 15.0 or higher.

- iOS Simulators running iOS version 17.0 or higher.

- MacOS Sonoma version 14.0 or higher.
