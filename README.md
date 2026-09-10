# Yeeps Map Loader -- BETA!

A Unity Editor tool that fetches real Yeeps room data and loads it into unity, ready to export as an FBX for Blender. (you can update the **`YeepsMapLoaderData`** with fixes if you see any)

## Install

1. Get an AssetRipper export of Yeeps. Inside it you'll have a folder like `ExportedProject`.
2. Download the **`YeepsMapLoaderSetup`** folder from this repo and put it **next to** `ExportedProject`, not inside it:
   ```
   AssetRipper_export_.../
   ├── ExportedProject/
   └── YeepsMapLoaderSetup/   <- put it here
   ```
3. Double-click **`setup.bat`** inside `YeepsMapLoaderSetup`. Leave the window open until it says **Done**.
4. Open `ExportedProject` in Unity and wait for it to finish importing (this can take a while the first time).
5. In Unity's top menu: **Window > TextMeshPro > Import TMP Essential Resources** > **Import**.
6. In Unity's top menu: **Yeeps > Map Loader**. That's the tool.
