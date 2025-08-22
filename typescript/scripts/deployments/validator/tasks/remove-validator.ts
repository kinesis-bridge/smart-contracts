import { task } from "hardhat/config";
import { ba_account, getClientDatas } from "../../../utils/constants";
import { removeEVMValidator } from "../validator-utils";

task("remove-validator-evm", "Remove EVM Validator")
  .addPositionalParam("phase")
  .addPositionalParam("validatorAddress")
  .setAction(async (taskArgs) => {
    console.log("Removing EVM Validator");

    const clientDatas = getClientDatas(taskArgs.phase);

    let promises: Promise<void>[] = new Array<Promise<void>>(
      clientDatas.length,
    );

    for (let i: number = 0; i < clientDatas.length; i++) {
      promises[i] = removeEVMValidator(
        clientDatas[i],
        ba_account,
        ba_account,
        taskArgs.validatorAddress,
      );
    }
    await Promise.all(promises);
  });
