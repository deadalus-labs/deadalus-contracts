#[starknet::component]
mod CustomComponent {
    use deadalus::custom::interface;
    use deadalus::custom::interface::TokenTrait;
    // use openzeppelin::utils::storage::StoreTokenTrait;

    #[storage]
    struct Storage {
        Custom_token_traits: LegacyMap<u256, TokenTrait>
    }

    #[embeddable_as(CustomImpl)]
    impl Custom<
        TContractState, +HasComponent<TContractState>
    > of interface::ICustom<ComponentState<TContractState>> {
        /// Returns whether the contract implements the given interface.
        fn get_token_trait(self: @ComponentState<TContractState>, token_id: u256) -> TokenTrait {
            self.Custom_token_traits.read(token_id)
        }
    }

    #[generate_trait]
    impl InternalImpl<
        TContractState, +HasComponent<TContractState>
    > of InternalTrait<TContractState> {
        /// Registers the given interface as supported by the contract.
        fn add_token_trait(
            ref self: ComponentState<TContractState>, token_id: u256, token_trait: TokenTrait
        ) {
            self.Custom_token_traits.write(token_id, token_trait)
        }
    }
}
