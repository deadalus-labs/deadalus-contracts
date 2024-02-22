use starknet::ClassHash;

// add event, when contract is created
// add class_hash in constructor

#[starknet::interface]
trait ICounterFactory<TContractState> {
    fn deploy_counter_contract(ref self: TContractState, initial_counter: u256) -> ContractAddress;
    fn set_counter_classhash(ref self: TContractState, class_hash: ClassHash);
}


#[starknet::contract]
mod CounterFactory {
    use core::poseidon::poseidon_hash_span;
    use super::ICounterFactory;
    use starknet::ClassHash;
    use starknet::ContractAddress;
    use starknet::SyscallResult;

    use starknet::syscalls::deploy_syscall;
    use starknet::get_caller_address;
    use starknet::info::get_contract_address;

    use openzeppelin::access::ownable::OwnableComponent;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[storage]
    struct Storage {
        // owner_factory: ContractAddress,
        counter_contracts: LegacyMap::<ContractAddress, u128>,
        counter_contract_class_hash: ClassHash, // need this in order to deploy,
        counter_id: u128,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[constructor]
    fn constructor(ref self: ContractState, counter_contract_class_hash: ClassHash) {
        self.ownable.initializer(get_caller_address());
        self.counter_contract_class_hash.write(counter_contract_class_hash);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        ContractCreated: ContractCreated,
    }

    #[derive(Drop, starknet::Event)]
    struct ContractCreated {
        owner: ContractAddress,
    }

    //  emit events
    #[abi(embed_v0)]
    impl CounterFactory of ICounterFactory<ContractState> {
        fn deploy_counter_contract(ref self: ContractState, initial_counter: u256) {
            let caller_address = get_caller_address();
            let call_data = array![initial_counter.into()].span(); // empty call data
            let deploy_result: SyscallResult = deploy_syscall(
                self.counter_contract_class_hash.read(),
                generate_salt(
                    caller_address, self.counter_id.read().into()
                ), // important for preventing address collision
                call_data,
                deploy_from_zero: false
            );
            match deploy_result {
                Result::Ok((
                    _contract_address, _return_data
                )) => {
                    let mut counter_id = self.counter_id.read();
                    self.counter_contracts.write(_contract_address, counter_id);
                    self.counter_id.write(counter_id + 1);
                },
                Result::Err(_) => { panic!("error in contract call"); }
            }
            deploy_result
        }
        fn set_counter_classhash(ref self: ContractState, class_hash: ClassHash) {
            self.ownable.assert_only_owner();
            // let caller: ContractAddress = get_caller_address();
            // assert(caller == self.owner.read(), 'caller is not owner');
            self.counter_contract_class_hash.write(class_hash);
        }
    }

    // needed to provide randomness to the contract address
    fn generate_salt(address: ContractAddress, nonce: felt252) -> felt252 {
        let values = array![address.into(), nonce];
        let salt = poseidon_hash_span(values.span());
        salt
    }
}
