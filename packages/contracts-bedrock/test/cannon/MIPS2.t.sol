// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { CommonTest } from "test/setup/CommonTest.sol";
import { MIPS2 } from "src/cannon/MIPS2.sol";
import { PreimageOracle } from "src/cannon/PreimageOracle.sol";
import "src/dispute/lib/Types.sol";

contract MIPS2_Test is CommonTest {
    MIPS2 internal mips;
    PreimageOracle internal oracle;

    // keccak256(bytes32(0) ++ bytes32(0))
    bytes32 internal constant EMPTY_THREAD_ROOT = hex"ad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5";

    function setUp() public virtual override {
        super.setUp();
        oracle = new PreimageOracle(0, 0);
        mips = new MIPS2(oracle);
        vm.store(address(mips), 0x0, bytes32(abi.encode(address(oracle))));
        vm.label(address(oracle), "PreimageOracle");
        vm.label(address(mips), "MIPS2");
    }

    function test_step_abi_succeeds() public {
        uint32[32] memory registers;
        registers[16] = 0xbfff0000;
        MIPS2.ThreadContext memory thread = MIPS2.ThreadContext({
            threadID: 0,
            exitCode: 0,
            exited: false,
            futexAddr: 0,
            futexVal: 0,
            futexTimeoutStep: 0,
            pc: 4,
            nextPC: 8,
            lo: 0,
            hi: 0,
            registers: registers
        });
        bytes memory encodedThread = encodeThread(thread);
        bytes memory threadWitness = abi.encodePacked(encodedThread, EMPTY_THREAD_ROOT);
        bytes32 threadRoot;
        assembly {
            let memptr := mload(0x40)
            mstore(memptr, 0x0)
            mstore(add(memptr, 0x20), 0x0)
            mstore(0x40, add(memptr, 0x40))
            threadRoot := keccak256(memptr, 0x40)
        }

        MIPS2.State memory state = MIPS2.State({
            memRoot: hex"30be14bdf94d7a93989a6263f1e116943dc052d584730cae844bf330dfddce2f",
            preimageKey: bytes32(0),
            preimageOffset: 0,
            heap: 0,
            exitCode: 0,
            exited: false,
            step: 1,
            wakeup: 0xFF_FF_FF_FF,
            traverseRight: false,
            leftThreadStack: threadRoot,
            rightThreadStack: 0
        });
        bytes memory memProof =
            hex"3c10bfff3610fff0341100013c08ffff3508fffd34090003010950202d420001ae020008ae11000403e000080000000000000000000000000000000000000000ad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5b4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d3021ddb9a356815c3fac1026b6dec5df3124afbadb485c9ba5a3e3398a04b7ba85e58769b32a1beaf1ea27375a44095a0d1fb664ce2dd358e7fcbfb78c26a193440eb01ebfc9ed27500cd4dfc979272d1f0913cc9f66540d7e8005811109e1cf2d887c22bd8750d34016ac3c66b5ff102dacdd73f6b014e710b51e8022af9a1968ffd70157e48063fc33c97a050f7f640233bf646cc98d9524c6b92bcf3ab56f839867cc5f7f196b93bae1e27e6320742445d290f2263827498b54fec539f756afcefad4e508c098b9a7e1d8feb19955fb02ba9675585078710969d3440f5054e0f9dc3e7fe016e050eff260334f18a5d4fe391d82092319f5964f2e2eb7c1c3a5f8b13a49e282f609c317a833fb8d976d11517c571d1221a265d25af778ecf8923490c6ceeb450aecdc82e28293031d10c7d73bf85e57bf041a97360aa2c5d99cc1df82d9c4b87413eae2ef048f94b4d3554cea73d92b0f7af96e0271c691e2bb5c67add7c6caf302256adedf7ab114da0acfe870d449a3a489f781d659e8beccda7bce9f4e8618b6bd2f4132ce798cdc7a60e7e1460a7299e3c6342a579626d22733e50f526ec2fa19a22b31e8ed50f23cd1fdf94c9154ed3a7609a2f1ff981fe1d3b5c807b281e4683cc6d6315cf95b9ade8641defcb32372f1c126e398ef7a5a2dce0a8a7f68bb74560f8f71837c2c2ebbcbf7fffb42ae1896f13f7c7479a0b46a28b6f55540f89444f63de0378e3d121be09e06cc9ded1c20e65876d36aa0c65e9645644786b620e2dd2ad648ddfcbf4a7e5b1a3a4ecfe7f64667a3f0b7e2f4418588ed35a2458cffeb39b93d26f18d2ab13bdce6aee58e7b99359ec2dfd95a9c16dc00d6ef18b7933a6f8dc65ccb55667138776f7dea101070dc8796e3774df84f40ae0c8229d0d6069e5c8f39a7c299677a09d367fc7b05e3bc380ee652cdc72595f74c7b1043d0e1ffbab734648c838dfb0527d971b602bc216c9619ef0abf5ac974a1ed57f4050aa510dd9c74f508277b39d7973bb2dfccc5eeb0618db8cd74046ff337f0a7bf2c8e03e10f642c1886798d71806ab1e888d9e5ee87d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        bytes32 post = mips.step(encodeState(state), memProof, threadWitness, 0);
        assertNotEq(post, bytes32(0));
    }

    function encodeState(MIPS2.State memory _state) internal pure returns (bytes memory) {
        return abi.encodePacked(
            _state.memRoot,
            _state.preimageKey,
            _state.preimageOffset,
            _state.heap,
            _state.exitCode,
            _state.exited,
            _state.step,
            _state.traverseRight,
            _state.leftThreadStack,
            _state.rightThreadStack
        );
    }

    function encodeThread(MIPS2.ThreadContext memory _thread) internal pure returns (bytes memory) {
        bytes memory registers;
        for (uint256 i = 0; i < _thread.registers.length; i++) {
            registers = bytes.concat(registers, abi.encodePacked(_thread.registers[i]));
        }
        return abi.encodePacked(
            _thread.threadID,
            _thread.exitCode,
            _thread.exited,
            _thread.futexAddr,
            _thread.futexVal,
            _thread.futexTimeoutStep,
            _thread.pc,
            _thread.nextPC,
            _thread.lo,
            _thread.hi,
            registers
        );
    }
}
