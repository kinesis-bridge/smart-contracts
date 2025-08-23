import { task } from "hardhat/config";
import { ba_account, getClientDatas } from "../../../utils/constants";
import { addKDAValidator } from "../validator-utils";

task("validator-kda", "Add KDA Validator")
  .addPositionalParam("phase")
  .setAction(async (taskArgs) => {
    console.log("Adding KDA Validator");

    const clientDatas = getClientDatas(taskArgs.phase);

    let promises: Promise<void>[] = new Array<Promise<void>>(
      clientDatas.length,
    );

    for (let i: number = 0; i < clientDatas.length; i++) {
      promises[i] = addKDAValidator(clientDatas[i], ba_account, ba_account);
    }
    await Promise.all(promises);
  });
