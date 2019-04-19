pragma solidity 0.5.1;

import "./Registry.sol";

/**
 * @title Proxy
 * @author Rob Hitchens
 * @notice Trustless upgradable contract proxy.
 */
 
interface ProxyInterface {
    function registryAddress() external view returns(address);
    function componentUid() external view returns(bytes32);
    function userImplementation(address user) external view returns(address);
    function () external payable;
}

contract Proxy is ProxyInterface {
    
    bytes32 private constant REGISTRY_ADDRESS_KEY = keccak256("Registry address key");
    address private constant UNDEFINED = address(0);
    
    /**
     * @notice Deploys a new registry for this component. Each proxy controls one upgradable component. 
     * @notice Stores the release manager contract address in the proxy contract. 
     * @notice Uses a collision-resistant storage slot.
     */
    constructor() public {
        Registry registry = new Registry();
        registry.transferOwnership(msg.sender);
        address registryAddress = address(registry);
        bytes32 registryAddressStorageKey = REGISTRY_ADDRESS_KEY;
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            sstore(registryAddressStorageKey, registryAddress)
        }
    }
    
    /**
     * @return The address of authoratative implementation registry for this proxy. 
     */
    function registryAddress() public view returns(address) {
        address r;
        bytes32 registryAddressKey = REGISTRY_ADDRESS_KEY;
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            r := sload(registryAddressKey)
        }
        require(r != UNDEFINED, "Internal error. The registry is undefined.");
        return r;
    }
    
    /**
     * @return The componentUid for this proxy.
     */
    function componentUid() public view returns(bytes32) {
        RegistryInterface registry = RegistryInterface(registryAddress());
        return registry.componentUid();
    }
    
    /** 
     * @return The user implementation preference. 
     * @dev If the user has no preference or the preference was recalled, returns the default implementation. 
     */
    function userImplementation(address user) public view returns(address) {
        RegistryInterface registry = RegistryInterface(registryAddress());
        return registry.userImplementation(user);
    } 
    
    /**
     * @notice Delegates invokations to the user's preferred implementation. 
     */
    function () external payable {
        address implementationAddress = userImplementation(msg.sender);
        //solium-disable-next-line security/no-inline-assembly
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, implementationAddress, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}
