use starknet::ContractAddress;
use starknet::ClassHash;


// transfer is transferred to contract as soon owner mints the tokens/nfts 
// how to redeem/ give back ownership --> have all tokens/nfts burned --> transfer ownership
// mint function that transfer ownership to contract 
// 

enum FractionPeriod {
    DAILY,
    MONTHLY,
    YEARLY
}


#[starknet::interface]
trait IFractionVaultFactory<TContractState> {
    fn deposit_contract(
        ref self: TContractState, name: felt252, contract_address: ContractAddress,
    // fraction_period: FractionPeriod
    );
    fn transfer_owner_hourly(ref self: TContractState, contract_address: ContractAddress);
    fn transfer_owner_daily(ref self: TContractState, contract_address: ContractAddress);
    fn transfer_owner_monthly(ref self: TContractState, contract_address: ContractAddress);
    fn redeem(ref self: TContractState, contract_address: ContractAddress);
}


#[starknet::contract]
mod FractionVaultFactory {
    use super::IFractionVaultFactory;
    use super::FractionPeriod;
    use starknet::ClassHash;
    use starknet::ContractAddress;

    use starknet::get_caller_address;

    #[storage]
    struct Storage {
        owner: ContractAddress, // owner no needed?
        erc20_token_class_hash: ClassHash,
        contracts: ArrayTrait, // Mapping contractAddress to fractionPeriod ???
    }

    #[constructor]
    fn constructor(ref self: ContractState, erc20_class_hash: ClassHash) {
        self.owner.write(get_caller_address());
        self.erc20_token_class_hash.write(erc20_class_hash);
    }

    #[abi(embed_v0)]
    impl FracationVaultFactory of IFractionVaultFactory<ContractState> {
        fn deposit_contract(
            ref self: ContractState, name: felt252, contract_address: ContractAddress,
        // fraction_period: FractionPeriod
        ) { // call mint 
        }

        fn transfer_owner_hourly(
            ref self: TContractState, contract_address: ContractAddress
        ) { // assert owner NFT of contract_address, type, block
        // then: call contract transferOwnership function
        }
        fn transfer_owner_daily(ref self: TContractState, contract_address: ContractAddress) {}
        fn transfer_owner_monthly(ref self: TContractState, contract_address: ContractAddress) {}
        fn redeem(
            ref self: TContractState, contract_address: ContractAddress
        ) { // check if all NFTs are in msg.sender and then burn them -> transferOwnership to msg.sender
        }
    }
}
