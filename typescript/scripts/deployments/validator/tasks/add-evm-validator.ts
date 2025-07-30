import { task } from "hardhat/config";
import { ba_account, getClientDatas } from "../../../utils/constants";
import { addEVMValidator } from "../validator-utils";

task("validator-evm", "Add EVM Validator")
  .addPositionalParam("phase")
  .addPositionalParam("validatorAddress")
  .setAction(async (taskArgs) => {
    console.log("Adding EVM Validator");

    const clientDatas = getClientDatas(taskArgs.phase);

    let promises: Promise<void>[] = new Array<Promise<void>>(
      clientDatas.length,
    );

    for (let i: number = 0; i < clientDatas.length; i++) {
      promises[i] = addEVMValidator(
        clientDatas[i],
        ba_account,
        ba_account,
        taskArgs.validatorAddress,
      );
    }
    await Promise.all(promises);
  });
