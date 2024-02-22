use starknet::ContractAddress;

#[starknet::interface]
trait ICounter<TContractState> {
    fn increment(ref self: TContractState);
    fn decrement(ref self: TContractState);
    fn set_owner(ref self: TContractState, new_owner: ContractAddress);
    fn get_count(self: @TContractState);
}

#[starknet::contract]
mod Counter {
    use super::ICounter;

    use starknet::get_caller_address;
    use starknet::ContractAddress;
    use openzeppelin::access::ownable::OwnableComponent;

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[storage]
    struct Storage {
        owner: ContractAddress,
        counter: u256,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState, initial_counter: u256, initial_owner: ContractAddress
    ) { // added parameter initial_counter so that you could create the contract for another wallet if necessary
        self.counter.write(initial_counter);
        self.ownable.initializer(initial_owner);
    }

    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;

    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    // TODO: how to emit event form OZ ownable, transfer_ownership?
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CounterIncreased: CounterIncreased,
        CounterDecreased: CounterDecreased,
        OwnableEvent: OwnableComponent::Event
    }

    #[derive(Drop, starknet::Event)]
    struct CounterIncreased {
        counter: u32
    }

    #[derive(Drop, starknet::Event)]
    struct CounterDecreased {
        counter: u32
    }

    #[abi(embed_v0)]
    impl Counter of ICounter<ContractState> {
        fn increment(ref self: ContractState) {
            self.ownable.assert_only_owner();
            self.counter.write(self.counter.read() + 1);
            self.emit(CounterIncreased { counter: self.counter.read() })
        }
        fn decrement(ref self: ContractState) {
            // TODO: underflow protection?
            self.ownable.assert_only_owner();
            self.counter.write(self.counter.read() - 1);
            self.emit(CounterDecreased { counter: self.counter.read() })
        }
        fn set_owner(ref self: ContractState, new_owner: ContractAddress) {
            self.ownable.assert_only_owner();
            // self.owner.write(new_owner)
            self.ownable.initializer(new_owner);
        }
        fn get_count(self: @ContractState) {
            self.counter;
        }
    }
}
