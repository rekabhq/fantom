# Fantom

Fantom is a cli tool for generating API layer based on OpenAPI Spec.


## Usage
1. Install `fantom`
    ```shell
    $ dart pub global activate fantom
    ```
2. Generate API client
    ```shell
    $ fantom generate openapi.yaml --dir=lib/src/network 
    ```
   **Note:** it will generates models in `lib/src/network/model` directory and APIs in `lib/src/network/api` directory
    
### **More Advanced Options**

- Separate models and APIs directories
    ```shell
    $ fantom generate openapi.yaml --model-dir=lib/src/model --api-dir=lib/src/network
    ```    
- Generate API layer as a standalone dart package
    ```shell
    $ fantom generate openapi.yaml --package=packages/network
    ```
    
    **Note:** it will generates a package called `network` inside `packages/network` from where `fantom generate` command runs.
    
 - Define configs inside `pubspec.yaml`
     ```shell
    $ fantom generate 
    # or
    $ fantom generate pubspec.yaml
    ```
    Your `pubspec.yaml` file:
    ```yaml
    fantom:
      - openapi: openapi.yaml   
      - api-dir: lib/src/network
      - model-dir: lib/src/model
    # or
    fantom: 
      - openapi: openapi.yaml
      - dir: lib/src/network
    # or
    fantom: 
      - openapi: openapi.yaml
      - package: packages/network  
    ```        

## Activate from Source
Activate `fantom` from source code:

```shell
$ export PATH="$PATH":"$HOME/.pub-cache/bin"

$ dart pub global activate --source path path_to/fantom
```

To deactive:
```bash
$ dart pub global deactivate fantom
```
