//SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

// las librerias las llamo para utilizarlas en un unico contrato
// configuro con ctrl + shift + p y edito el archivo settings.json
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
/*Si no deseo hacer el import, abajo puedo copiarel código de la interfaz de chainlik desde github:
https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
* Network: Goerli
* Aggregator: ETH/USD
* Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
desde https://docs.chain.link/data-feeds/price-feeds/addresses
*/
// siempre que quiera interactuar con otro contrato desplegado voy a necesitar la ABI 
// (Aplication binary Interfaz) de ese contrato. Las interfaces se compilan hasta la ABI
// interactuar con contrato tipo interfaz es como hacerlo con una Struct o una varialbe

contract FundMe{

  // asegura que los datos no incurran en overflows. versiones de solodity <= a 0.8.0
  using SafeMathChainlink for uint256; 
  mapping(address => uint256) public addressToAmountFunded;
  address[] public funders;
  //declara el dueño del contrato para restringir las salidas
  address public owner;
  // cambio del original-- se utiliza este aggregator desde el constructor y lo quito de las funciones
  AggregatorV3Interface public priceFeed;
  // constructores es codigo que se ejecuta automaticam después del despliegue del contrato
    constructor(address _priceFeed) public{
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender; // quien haga el deploy se convierte en el dueño
    }

   // funcioni payable puede ser utilizada para pagar por cosas
    function fund() public payable{
        // condicion de recibir 50 usd como minimo
        // cuanto eth -> USD tasa de conversión
        uint256 minimunUSD = 50 * 10 ** 18; // 50 en gwai , 50 por 10 elevado a la 18
        // condiciones previas que se deben cumplir para ejecutar la funcion fund.
        require(getConversionRate(msg.value)>= minimunUSD, "Debes enviar minimo 50 USD");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns(uint256){
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        return priceFeed.version();
    }

    function getPrice() public view returns(uint256){
        //AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        // lo siguiente es una tupla, list de objetos que pueden tener distintos tipos de datos
        // su numero es constante al tiempo de compilación, no se puede añadir más despues de compilar
        (,int price,,,) = priceFeed.latestRoundData();
         return uint256(price * 10000000000);  // data casting - multiplicado todo en Wei
         // 1.232,47568236 precio actual de eth que me devolvió
    }

    function getEntranceFee() public view returns(uint256){
        // minimun USD
        uint256 minimunUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return ((minimunUSD * precision)/price) + 1;
    }

    function getConversionRate(uint256 ethAmount) public view returns(uint256){
        uint256 ethPrice  = getPrice();
        uint256 ethAmountInUsd =(ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    // para establecer que solo el dueño sea el que puede ejecutar withdraw
    // modificadores se usan para cambir como se comporta una funcion y se usan de manera declarativa

    modifier onlyOwner{
        require(msg.sender == owner);  // == compara entre dos elementos
        _;   // _ significa todo los demas a ejecutar -- notar que esta despues del require
    }

    function withdraw() payable onlyOwner public {
        msg.sender.transfer(address(this).balance);
        for(uint256 funderIndex; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}