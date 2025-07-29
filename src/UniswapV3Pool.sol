// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import {IUniswapV3PoolDeployer} from "./interfaces/IUniswapV3PoolDeployer.sol";
import {Tick} from "./libraries/Tick.sol";


contract UniswapV3Pool {
    
    address public immutable factory;
    address public immutable token0;
    address public immutable token1;
    uint24 public immutable fee;
    int24 public immutable tickSpacing;
    uint128 public immutable maxLiquidityPerTick;

    constructor() {

        int24 _tickSpacing;
        (factory, token0, token1, fee, _tickSpacing) = IUniswapV3PoolDeployer(msg.sender).parameters();
        tickSpacing = _tickSpacing;

        maxLiquidityPerTick = Tick.tickSpacingToMaxLiquidityPerTick(_tickSpacing);
      

    }

}