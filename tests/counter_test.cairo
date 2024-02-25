use snforge_std::{declare, ContractClassTrait};

use starknet::ContractAddress;

use deadalus::counter::counter::{ICounterDispatcher, ICounterDispatcherTrait};

#[test]
fn check_counter_Balance() {
    // First declare and deploy a contract
    let contract = declare('Counter');
    let constructor_data = array![];

    let contract_address = contract.deploy(@constructor_data);

    let dispatcher = ICounterDispatcher { contract_address };
// let balance = dispatcher.increment();

}
