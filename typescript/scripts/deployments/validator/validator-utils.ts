import { NAMESPACES } from "../../utils/constants";
import {
  IAccountWithKeys,
  ICapability,
  IClientWithData,
  IDomains,
  IValidatorAnnounceCfg,
} from "../../utils/interfaces";
import { submitSignedTxWithCap } from "../../utils/submit-tx";

export const addEVMValidator = async (
  client: IClientWithData,
  sender: IAccountWithKeys,
  account: IAccountWithKeys,
  validatorAddress: `0x${string}`,
) => {
  const command = `(namespace "${NAMESPACES[client.phase as keyof IDomains]}")
      (merkle-tree-ism.add-validator "${validatorAddress}")`;

  const capabilities: ICapability[] = [
    { name: "coin.GAS" },
    {
      name: `${NAMESPACES[client.phase as keyof IDomains]}.merkle-tree-ism.ONLY_ADMIN`,
    },
  ];
  const result = await submitSignedTxWithCap(
    client,
    sender,
    account,
    command,
    capabilities,
  );
  console.log(result);
};

export const addKDAValidator = async (
  client: IClientWithData,
  sender: IAccountWithKeys,
  account: IAccountWithKeys,
) => {
  const validatorCfg: IValidatorAnnounceCfg[] = [
    {
      validator: "0xdd3d6e30453490b027eb32a299e6779efc29f0d3",
      storageLocation: "file:///tmp/hyperlane-validator-signatures-kadena",
      signature:
        "0x5719b6fc770f6983a28f02c10b37605b2c876ffbda45840e66750622859c25b151b0930597a6cda1bed8e2550be3dd0e0fee00494e8b465982bdad42ae13b8081b",
    },
  ];

  const command = `(namespace "${NAMESPACES[client.phase as keyof IDomains]}")
      (validator-announce.announce "${validatorCfg[0].validator}" "${validatorCfg[0].storageLocation}" "${validatorCfg[0].signature}")`;

  const capabilities: ICapability[] = [
    { name: "coin.GAS" },
    {
      name: `${NAMESPACES[client.phase as keyof IDomains]}.validator-announce.ONLY_ADMIN`,
    },
  ];
  const result = await submitSignedTxWithCap(
    client,
    sender,
    account,
    command,
    capabilities,
  );
  console.log(result);
};

export const removeEVMValidator = async (
  client: IClientWithData,
  sender: IAccountWithKeys,
  account: IAccountWithKeys,
  validatorAddress: `0x${string}`,
) => {
  const command = `(namespace "${NAMESPACES[client.phase as keyof IDomains]}")
      (merkle-tree-ism.remove-validator "${validatorAddress}")`;

  const capabilities: ICapability[] = [
    { name: "coin.GAS" },
    {
      name: `${NAMESPACES[client.phase as keyof IDomains]}.merkle-tree-ism.ONLY_ADMIN`,
    },
  ];
  const result = await submitSignedTxWithCap(
    client,
    sender,
    account,
    command,
    capabilities,
  );
  console.log(result);
};