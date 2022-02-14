pragma solidity ^0.8.0;

library ContractRepository{

    bytes private constant REPOSITORY_STORAGE = "lib.repository";

    struct RepositoryStorage {
        mapping(bytes4 => mapping(uint => address)) contractVersionStore;
    }

    function repositoryStorage() internal pure returns(RepositoryStorage storage repoStore) {
        bytes32 REPOSITORY_STORAGE_POSITION = keccak256(REPOSITORY_STORAGE);
        assembly {repoStore.slot := REPOSITORY_STORAGE_POSITION}
    }
}