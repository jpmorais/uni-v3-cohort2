pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/UniswapV3Factory.sol"; 
import "../src/UniswapV3Pool.sol";
import "../src/Token.sol";
import "../src/interfaces/callback/IUniswapV3MintCallback.sol";

contract MintTest is Test, IUniswapV3MintCallback {

    UniswapV3Factory factory;
    UniswapV3Pool pool;
    Token tokenA;
    Token tokenB;


    function setUp() public {
        tokenA = new Token("Token A", "TKA");
        tokenB = new Token("Token B", "TKB");
        factory = new UniswapV3Factory();
        pool = UniswapV3Pool(factory.createPool(address(tokenA), address(tokenB), 500));

    }

    function testMintPosition() public {
        (uint amount0, uint amount1) = pool.mint(address(this),-10,10,10**9,"");
        console.log(amount0);
        console.log(amount1);
    }

    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes calldata data
    ) external {
        require(msg.sender == address(pool));
        tokenA.transfer(address(pool),amount0Owed);
        tokenB.transfer(address(pool),amount1Owed);
    }

    

}