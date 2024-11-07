# Capture the Spec

Welcome to the **Capture the Spec** contest! This event challenges participants to demonstrate their Solidity and formal verification skills in a fun environment using the Certora Prover.

## Table of Contents
- [Contest Overview](#contest-overview)
- [Rules](#rules)
- [How to Participate](#how-to-participate)
- [Submission Guidelines](#submission-guidelines)
- [Prizes](#prizes)
- [Contact](#contact)

## Contest Overview

In this contest, participants will receive a formal specification of a Solidity contract expressed in the Certora Verification Language (CVL). Your task is to write a Solidity contract that satisfies all the rules and invariants defined in the specification, which will be verified using the Certora Prover.

### Specification Breakdown
The specification is divided into three parts:
1. **main multisig.spec**: Contains all integrity rules showcasing what each function of the contract should do.
2. **invariant.spec**: Demonstrates inductive properties of the contract.
3. **sanity.spec**: Outlines rules that show legal paths of the contract.

If you want to run specific rule use `--rule rule_name` in your terminal


The contest will take place during DSS from **November 7 to November 9**.

## Rules

1. **Eligibility**: Open to all participants.
2. **Original Work**: All submissions must be the original work of the participant or team.
3. **Verification**: Participants must ensure that their contracts verify all rules and invariants using the Certora Prover. You can configure the prover using the `run.conf` file provided.
4. **Judging Criteria**: The primary judging criteria will be based on the verification of all rules. If no participant verifies all rules, the top 3 submissions will be awarded based on partial verification (highest number of verified rules).

## How to Participate


1. **Signup** at https://www.certora.com/signup
2. **Set Up Your Environment**: Prepare your development environment to write and verify Solidity contracts using the Certora Prover.  install - https://docs.certora.com/en/latest/docs/user-guide/install.html
3. **Read the Documentation**: Familiarize yourself with the [Certora Verification Language](https://docs.certora.com/).
4. **Develop Your Contract**: Create a Solidity contract that meets all specified rules and invariants.
5. **Run the Prover**: Use the provided `run.conf` file to run the Certora Prover and verify your contract. `certoraRun run.conf` . If you get `Unrecognized option: -havocInitEVMMemory` just `pip uninstall certora-cli` and `pip install certora-cli-beta` and start again.

## Submission Guidelines

Submissions must be made via a Google Form. Include the link to your verification run of the Certora Prover in your submission. The form can be found here: https://docs.google.com/forms/d/e/1FAIpQLSeyowlo-NMulAVf3HnexJh1cYZIJzK3erCDuCuwm3y3Ksf-nA/viewform.

## Prizes

- **1st, 2nd, and 3rd Place**: $1000 each for the three fastest participants/teams who successfully write a contract that verifies all rules. If no one can verify all rules and invariants, the top 3 submissions based on partial verification will win.
- **Bonus Prize**: An additional $500 will be awarded to the three fastest participants who achieve low live statistics on the following specific rules:
  - Rule 1: voteForTransactionIntegrity
  - Rule 2: tickCannotDecrease on voteForTransaction
  - Rule 3: transactionExist_IFF_notInFuture on voteForTransaction

For any questions or concerns, please reach out to us at [contest-email@certora.com](mailto:contest-email@certora.com) or at TG https://t.me/+TTuWSF6xfqRjNjY0
---

Good luck, and may the best team win!


## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

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
