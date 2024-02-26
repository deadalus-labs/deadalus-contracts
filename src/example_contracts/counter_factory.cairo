use starknet::ClassHash;


#[starknet::interface]
trait ICounterFactory<TContractState>{
    fn deploy_counter_contract(ref self: TContractState);
    fn set_counter_classhash(ref self: TContractState, class_hash: ClassHash);
}


#[starknet::contract]
mod CounterFactory{

    use core::poseidon::poseidon_hash_span;
    use super::ICounterFactory;
    use starknet::syscalls::deploy_syscall;
    use starknet::{
        ClassHash,
        ContractAddress,
        SyscallResult,
        get_caller_address,
        get_contract_address,
        get_tx_info
    };

    #[storage]
    struct Storage{
        owner: ContractAddress,
        counter_contracts: LegacyMap::<ContractAddress, u128>,
        counter_contract_class_hash: ClassHash, // need this in order to deploy,
        counter_id: u128
    }

    #[constructor]
    fn constructor(ref self: ContractState, class_hash: ClassHash){
        self.owner.write(get_caller_address());
        self.counter_contract_class_hash.write(class_hash);
    }

    #[abi(embed_v0)]
    impl CounterFactory of ICounterFactory<ContractState>{

        fn deploy_counter_contract(ref self: ContractState){
            let caller_address = get_caller_address();
            let call_data = array![''].span(); // empty call data
            let transaction_nonce: felt252 = get_tx_info().unbox().nonce;
            let deploy_result: SyscallResult = deploy_syscall(
                self.counter_contract_class_hash.read(),
                generate_salt(caller_address, transaction_nonce), // important for preventing address collision
                call_data,
                deploy_from_zero: false
            );
            match deploy_result {
                Result::Ok((_contract_address, _return_data)) =>{
                    let mut counter_id = self.counter_id.read();
                    self.counter_contracts.write(_contract_address, counter_id);
                    self.counter_id.write(counter_id + 1);
                },
                Result::Err(_) => {
                    panic!("error in contract call");
                }
            }
        }
        fn set_counter_classhash(ref self: ContractState, class_hash: ClassHash){
            let caller: ContractAddress = get_caller_address();
            assert(caller == self.owner.read(), 'caller is not owner');
            self.counter_contract_class_hash.write(class_hash);
        }
    }

    // needed to provide randomness to the contract address
    fn generate_salt(address: ContractAddress, nonce: felt252) -> felt252{
        let values = array![address.into(), nonce];
        let salt = poseidon_hash_span(values.span());
        salt
    }

}