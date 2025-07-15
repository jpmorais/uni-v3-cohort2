// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import  {IUniswapV3PoolDeployer} from  "./interfaces/IUniswapV3PoolDeployer.sol";
import {UniswapV3Pool} from "./UniswapV3Pool.sol";

contract UniswapV3PoolDeployer is IUniswapV3PoolDeployer {

    struct Parameters {
        address factory;
        address token0;
        address token1;
        uint24 fee;
        int24 tickSpacing;
    }

    Parameters public override parameters;

    // To actually deploy the pool
    function deploy(
        address factory,
        address token0,
        address token1,
        uint24 fee,
        int24 tickSpacing
    ) internal returns (address pool) {
        // set the parameters for this pool
        parameters = Parameters({factory: factory, token0: token0, token1: token1, fee: fee, tickSpacing: tickSpacing});
        // I use create2 to create a new pool with salt keccak(token0, token1, fee)
        pool = address(new UniswapV3Pool{salt: keccak256(abi.encode(token0, token1, fee))}());
        // I delete the parameters because the pool has already callback to retrieve them
        delete parameters;
    }


}