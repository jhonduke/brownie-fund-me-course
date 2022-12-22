from brownie import accounts, config, network, MockV3Aggregator
#from web3 import Web3

DECIMALS = 8
STARTING_PRICE = 200000000000

LOCAL_BLOCKCHAIN_ENVIRONMENT = ["ganache-local", "development"]
FORKED_LOCAL_ENVIROMENTS = ["mainnet-fork","mainnet-fork-dev"]

def get_account():
    if (network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENT or network.show_active() in FORKED_LOCAL_ENVIROMENTS):
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])

def deploy_mocks():
    print(f"the active network is {network.show_active()}")
    print(f"deploying the Mocks")
    # 8 y 2000 a variables estaticas(no se modifican), se usan en POO
    # MockV3Aggregator.deploy(8,Web3.toWei(2000, "ether"), {"from": get_account()})
    MockV3Aggregator.deploy(DECIMALS, STARTING_PRICE, {"from": get_account()})