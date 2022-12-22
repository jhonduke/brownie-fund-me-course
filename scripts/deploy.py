from brownie import FundMe, MockV3Aggregator, config, network
from scripts.helpful_scripts import get_account, deploy_mocks, LOCAL_BLOCKCHAIN_ENVIRONMENT
from web3 import Web3

def deploy_fund_me():
    account = get_account()
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENT:
        price_feed_address = config["networks"][network.show_active()]["eth_usd_price_feed"]
    else:
        deploy_mocks()
        #[-1] funciona porque el deploy anterior, brownie puede reconocer el ultimo deploy en tiempo de ejecucion
        price_feed_address = MockV3Aggregator[-1].address
        print(f"Mocks deployed")

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from":account},
         publish_source=config["networks"][network.show_active()].get("verify"))
    print(f"contract deployed to {fund_me.address}")
    return fund_me
    

def main():
    deploy_fund_me()