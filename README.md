# BDKSwiftExampleWallet

[![License](https://img.shields.io/badge/license-MIT%2FApache--2.0-blue.svg)](https://github.com/reez/BDKSwiftExampleWallet/blob/main/LICENSE)

An example iOS app using [BDK](https://github.com/bitcoindevkit)

<img src="Docs/bitcoin-screen.png" alt="Screenshot" width="236" height="511">

## Functionality

This app is an experimental work in progress. 

### Wallet

Supports single key HD segwit/bech32 wallets with BIP86 derivation paths. 

Descriptors created by the app will look like: `wpkh([extended private key]/88'/1'/0'/0/*)`

### Implemented

- [x] Create Wallet `Wallet(descriptor: changeDescriptor: network: databaseConfig:)`

- [x] Get Address `getAddress`

- [x] Get Balance `getBalance`

- [x] List Transactions `listTransactions`

- [x] Send `send`

- [x] Sync `sync`

