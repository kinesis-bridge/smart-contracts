import { NAMESPACES } from "../../utils/constants";
import {
  IAccountWithKeys,
  ICapability,
  IClientWithData,
  IDomains,
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
