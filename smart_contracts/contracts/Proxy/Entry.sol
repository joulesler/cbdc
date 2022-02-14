pragma solidity ^0.8.0;

import "./ContractRepository.sol";

contract Entry {

    function addContract() public returns (bool success){

    }

    fallback() external payable {
        ContractRepository.RepositoryStorage storage repoStore = ContractRepository.repositoryStorage();
        address implementation = repoStore.contractVersionStore[msg.sig][0];
        require(implementation != address(0));

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
