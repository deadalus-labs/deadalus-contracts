pub use starknet::{ContractAddress, ClassHash};

#[starknet::interface]
pub trait ICounterFactory<TContractState> {
    fn get_init_argument(self: @TContractState) -> Span<felt252>;
    fn get_contracts(self: @TContractState) -> Span<felt252>;

    /// Create a new counter contract from stored arguments
    fn create_flat(ref self: TContractState) -> ContractAddress;

    /// Create a new counter contract from the given arguments
    fn create_flat_with(ref self: TContractState, init_argument: Span<felt252>) -> ContractAddress;

    /// Update the argument
    fn update_init_argument(ref self: TContractState, init_argument: Span<felt252>);

    /// Update the class hash of the Counter contract to deploy when creating a new counter
    fn update_counter_class_hash(ref self: TContractState, counter_class_hash: ClassHash);
}


#[starknet::contract]
pub mod FlatFactory {
    use starknet::{ContractAddress, ClassHash, SyscallResultTrait};
    use starknet::syscalls::deploy_syscall;
    use deadalus::utils::storage::StoreSpanFelt252;

    #[storage]
    struct Storage {
        /// Store the constructor arguments of the contract to deploy
        init_argument: Span<felt252>,
        /// Store the class hash of the contract to deploy
        counter_class_hash: ClassHash,
        contracts_created: Array::<ContractAddress>,
        contract_id: u128,
    }

    #[constructor]
    fn constructor(ref self: ContractState, init_argument: Span<felt252>, class_hash: ClassHash) {
        self.init_argument.write(init_argument);
        self.counter_class_hash.write(class_hash);
        self.contract_id.write(1);
    }

    #[abi(embed_v0)]
    impl Factory of super::ICounterFactory<ContractState> {
        fn create_flat_with(
            ref self: ContractState, init_argument: Span<felt252>
        ) -> ContractAddress {
            // Contructor arguments
            let mut constructor_calldata: Span<felt252> = init_argument;

            // Contract deployment
            let (deployed_address, _) = deploy_syscall(
                self.counter_class_hash.read(), 0, constructor_calldata, false
            )
                .unwrap_syscall();
            self.contracts_created.append(deployed_address);
            // self.contracts_created.write(self.contract_id.read(), deployed_address);
            self.contract_id.write(self.contract_id.read() + 1);

            deployed_address
        }

        fn create_flat(ref self: ContractState) -> ContractAddress {
            self.create_flat_with(self.init_argument.read())
        }

        fn update_init_argument(ref self: ContractState, init_argument: Span<felt252>) {
            self.init_argument.write(init_argument);
        }

        fn update_counter_class_hash(ref self: ContractState, counter_class_hash: ClassHash) {
            self.counter_class_hash.write(counter_class_hash);
        }

        fn get_init_argument(self: @ContractState) -> Span<felt252> {
            self.init_argument.read()
        }

        fn get_contracts(self: @TContractState) -> Span<felt252> {
            self.contracts_created.read()
        }
    }
}
