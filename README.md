# TrustlessUpgrades

[https://github.com/rob-Hitchens/TrustlessUpgrades](https://github.com/rob-Hitchens/TrustlessUpgrades)

Experimental Upgradable Contract Framework with user opt-in/out upgrades. 

Use this framework to implement upgradable contracts with user control over upgrades. 

## User Opt-in/out

User's can set a preferred implementation version and optionally accept or disregard new releases (upgraded contracts). There is no requirement for all users to migrate simultaneously. 

By default, users accept upgrades (automatic update). 

## Familiar Contract Style

Upgradable contracts are written in familar styles, significantly reducing the learning curve required to deploy upgradable contract systems. See the `HelloUniverse.sol` example which shows there are minimal requirements to transform a regular contract into an upgradable contract. All that is required is:

- inherit the `Upgradable` contract.
- pass an argument through the constructor. 
- guard functions with the `onlyProxy` modifier to prevent anyone from accessing an implementation contract directly. 

## Preserves State

Contract state is stored in the Proxy contract and preserved across versions. 

## Structure

- `Proxy.sol` This is the common entry point for all implementation versions. Delegates calls to implementation contracts. 
- `Registry.sol` Maintains a list of implementations and user preferences. 
- `Upgradable.sol` Inheritable properties for upgradable contracts. 

## Migrations

- Deploy a `Proxy`. Each proxy automatically deploys a `Registry`. One registry per upgradable contract. 
- Note the `Registry` address from the `Proxy`. 
- Instantiate the `Registry` and note the unique `componentUid`.
- Deploy an upgradable contract (the first implementation) that inherits from `Upgradable` and passes a `componentUid` to `Upgradable`. This value must match the `componentUid` in the `Registry`. This helps prevent deployment process errors. 
- Register the address of the first implementation in the `Registry`. 
- Set the default implementation to the first implementation in the `Registry`. 
- Instantiate the upgradable contract with the implemntation's ABI _at the Proxy contract address._

## Manage Releases

- The account that deployed the `Proxy` is the intial owner of the registry contract, which is not upgradable. 
- Each implementation contract inherits from the previous implementation contract source code. This is to prevent accidental overwrite of existing states. Existing storage layout and functions are preserved in the proxy contract. Be sure to pass in a `componentUid` that matches the `componentUid` the `Registry` expects or it will not accept the implementation. 
- Implementation contracts _should_ use the `onlyProxy` modifier to prevent implementation contracts writing to their own state when called directly. They should only be called through the `Proxy` to ensure all writes are to the `Proxy` state. 
- Register additional implementation contracts. For example, `HellowWorld` and its upgrade, `HelloUniverse`.
- Optionally set the default implementation to the new implementation contract. 
- Use the ABI of the implementation that matches the user's preferred implementation which can be found by inspecting the `Registry`. The `Proxy` will delegate to the user's preferred implementation. 
- Optionally recall implementations. Set another default implementation before recalling the default implementation. 

## Full Decentralization

The transferable registry owner is uniquely privileged to add and recall implementations and set the default implementation. This structure _implies_ considerable remaining centralized control, especially given that the default user configuration accepts all changes as the default implementation evolves. (Users who don't want push updates select an implementation and lock it in, which halts the upgrade process, for them.)

The registry owner privilege is transferable. It is expected that this privilege would be transferred to a suitable governance contract to diffuse centralized control. Formulation and implementation of a less centralized governance process is a separate concern. All that is required is to deploy an acceptable governance contract and transfer registry ownership. Such a contract would define the proposal and approval processes for new implementations and recalls of problematic implementations. 

For emphasis, nothing the registry owner does can force an update upon individual users, by design. The registry owner only controls the range of possibilities available to users. The registry owner should be primarily focused on quality assurance and ensuring no implementation harms the application or its users. The onboarding process for new implementations anticipates that users will want to see proposed implementations _as deployed and at a specific address_ so they can both examine the bytecode and vote on unambiguous proposals. 

This structure can potentially bootstrap crowdsourcing of contract upgrades in a way that protects users from bad actors and well-meaning but flawed implementations. 

## Tests

NO TESTING OF ANY KIND HAS BEEN PERFORMED AND YOU USE THIS LIBRARY AT YOUR OWN EXCLUSIVE RISK.

## Contributors

Optimization and clean-up is ongoing.

The author welcomes pull requests, feature requests, testing assistance and feedback. Contact the author if you would like assistance with customization or calibrating the code for a specific application or gathering of different statistics.

Implements Ali Azam's trustless upgrade technique: https://github.com/ali2251/Upgradable-contracts

## License

Copyright (c), 2019 Rob Hitchens. The MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Hope it helps.
