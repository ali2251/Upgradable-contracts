pragma solidity 0.5.1;

import "./Upgradable.sol";

/**
 * @title HelloWorld, HelloUniverse
 * @author Rob Hitchens
 * @notice Trustless contract upgrade demonstration.
 */ 

contract HelloWorld is Upgradable {
    
    /**
     * @dev Layout only. Do not write values that want to emerge in the upgradable context. 
     * @dev Use setter functions via the proxy contract to ensure values are written to the proxy contract state.
     */ 
    address public something;
    uint public somethingElse;
    
    /**
     * @param componentUid Must match the COMPONENT_UID of the registry where you intend to register this implementation. 
     * @dev Pass the componentUid to the Upgradable constructor to ensure storage in the implementation contract state. 
     */
    constructor(bytes32 componentUid) Upgradable(componentUid) public {}
    
    /**
     * @dev Use onlyProxy to ensure failure if the deployed implementation if accessed without using the proxy.
     */
    function set(address a, uint u) public onlyProxy {
        something = a;
        somethingElse = u;
    }
}

/**
 * @dev MUST inherit the contract to replace to pick up storage layout and existing functions. 
 * @dev ALWAYS inherit from the latest implementation to avoid overwriting existing storage layout. 
 */
contract HelloUniverse is HelloWorld {

    /**
     * @dev Layout only. Do not write values that want to emerge in the upgradable context. 
     * @dev Use setter functions via the proxy contract to ensure values are written to the proxy contract state.
     */    
    uint public anotherThing;
    
    /**
     * @param componentUid Must match the COMPONENT_UID of the registry where you intend to register this implementation. 
     * @dev Pass the componentUid to the replaced contract constructor to ensure storage in the implementation state. 
     */
    constructor(bytes32 componentUid) HelloWorld(componentUid) public {}
    
    /**
     * @dev Use onlyProxy to ensure failure if the deployed implementation if accessed without using the proxy.
     */    
    function set(address a, uint u, uint v) public onlyProxy {
        something = a;
        somethingElse = u;
        anotherThing = v;
    }
}