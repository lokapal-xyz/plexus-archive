# Subgraph Deployment Guide

This guide details the steps required to set up, build, and deploy the Plexus Archive Subgraph to **The Graph Studio**.

## Subgraph Project Structure

The key files and directories within your project are:

| File/Directory | Description |
| :--- | :--- |
| `setup-subgraph.sh` | The main executable script to install the CLI, manage dependencies, and run code generation/build. |
| `subgraph/` | The root directory for the subgraph project files. |
| `subgraph/abis/` | Contains the **contract's ABI JSON file (`PlexusArchive.json`)** used by the code generator. |
| `subgraph/src/` | Contains the **AssemblyScript mapping logic (`plexus-archive.ts`)** that handles blockchain events. |
| `subgraph/networks.json` | Configuration file that defines the network endpoints for development/testing. |
| `subgraph/package.json` | Project manifest that defines dependencies and deployment scripts (`npm run deploy`). |
| `subgraph/schema.graphql` | Defines the GraphQL data model (entities) for your subgraph. |
| `subgraph/subgraph.yaml` | The subgraph manifest that links the contract, ABI, schema, and mapping functions. |

-----

## Deployment Preparation

### Step 1: Configure Contract Details

Before running the setup script, you must update the subgraph configuration with your deployed contract information.

1.  **Fetch Details:** Locate your contract address and deployment block number from your project's deployment output (e.g., `deployments/base.json`).

    ```json
    {
      "contractAddress": "YOUR_CONTRACT_ADDRESS_HERE",
      "blockNumber": "YOUR_DEPLOYMENT_BLOCK_NUMBER",
      // ...
    }
    ```

2.  **Update Manifest:** Open `subgraph/subgraph.yaml` and update the `address` and `startBlock` fields under the `dataSources` section, and set the `network` field to your working network:

    ```yaml
      network: "YOUR_NETWORK_CONTRACT"
      source:
        address: "YOUR_CONTRACT_ADDRESS_HERE"
        abi: PlexusArchive
        startBlock: YOUR_DEPLOYMENT_BLOCK_NUMBER
    ```

3.  **Update `networks.json`:** Open `subgraph/networks.json` and update the `PlexusArchive` contract values for the network you are targeting (e.g., `base-sepolia`).

    ```json
    // In subgraph/networks.json
    "base-sepolia": {
      "PlexusArchive": {
        "address": "YOUR_CONTRACT_ADDRESS_HERE",
        "startBlock": YOUR_DEPLOYMENT_BLOCK_NUMBER
      }
    },
    // ...
    ```

### Step 2: Configure Project Name

Open `subgraph/package.json` and replace `"YOUR_PROJECT_NAME"` with the **exact slug/name** you plan to use in The Graph Studio (e.g., `plexus-archive-base`).

```json
{
  "name": "YOUR_PROJECT_NAME",
  "scripts": {
    "deploy": "graph deploy YOUR_PROJECT_NAME",
    // ...
  }
}
```

-----

## Local Setup and Build

This step uses the automated script to install the necessary tools, dependencies, and generate the final build files.

1.  **Grant Execution Permission:**

    ```bash
    chmod +x setup-subgraph.sh
    ```

2.  **Run Setup Script:**

    ```bash
    ./setup-subgraph.sh
    ```

    > ⚠️ **pnpm Setup Check:** If this is the first time you are using `pnpm` for global installs, the script will prompt you to run `pnpm setup` and then restart your terminal before trying again.

## Deployment to The Graph Studio

Once the script completes successfully, your subgraph is compiled and ready to be deployed.

1.  **Create Subgraph in Studio:**

      * Visit **[The Graph Studio](https://thegraph.com/studio/)** and connect your wallet.
      * Click **"Create a Subgraph"** and create a new project using the **exact name/slug** defined in your `package.json`.

2.  **Get Deploy Key:**

      * On your new subgraph's detail page, locate and **copy your unique Deploy Key**.

3.  **Authenticate CLI:**

      * Navigate into your subgraph directory:
        ```bash
        cd subgraph
        ```
      * Run the authentication command using the key you copied:
        ```bash
        graph auth <YOUR_DEPLOY_KEY>
        ```

4.  **Deploy the Subgraph:**

      * Run the deploy script defined in your `package.json`. The script will automatically use the project name you defined.
        ```bash
        pnpm run deploy
        # OR: graph deploy <YOUR_SUBGRAPH_NAME>
        ```
      * When prompted by the CLI, enter a **version label** (e.g., `v0.0.1`).

-----

## Final Steps

1.  **Monitor Status:** Return to The Graph Studio. Your subgraph should begin syncing almost immediately. Monitor the **Logs** tab for any errors.
2.  **Query Data:** Once the subgraph is fully synced (or partially synced past your start block), you can **Test queries** in the built-in GraphQL Playground.
3.  **Endpoint Ready:** You can now use your generated GraphQL endpoint to integrate the data into your application.
