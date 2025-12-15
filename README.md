## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Deployed Contracts (Testnet)

- **BNBDIDRegistry**: `0x42068De9BC19d3597A683D2e695D9A1E504EF0Af`
- **PaymentToken**: `0x7C4d10a7d5890786fc001bF57407e2Fbd4580293`
- **SBTTransfer**: `0xa49Cea986b656BE679f94D7aA8236D7D9893C2Ba`
- **SBTCredential**: `0xA8C5545d3cBb14E6D0438493E491Cf14E8D4FE00`
- **SBTReview**: `0x2185206C6a000aA985B317E8515217F944395401`
- **VirtualTransfer**: `0x60E86B953f5EBA20917cF18aB96C70D076EcA5Cb` (for demo)

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
