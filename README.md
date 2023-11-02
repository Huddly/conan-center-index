<p align="center">
    <img src="assets/JFrogConanCenter.png" width="600"/>
</p>

Huddly fork of conan-center-index. This represents a snapshot of recipes from the [ConanCenter](https://conan.io/center) package repository for use in falcon and guppy projects. Some recipes may have small modifications over the conan-center version of the recipe. For larger modifications, it is recommended to add the recipe to **falcon-dependencies** or **guppy-dependencies**

## Conan 1 falcon-dependencies

When building **falcon-dependencies** with conan1, it will pull recipes from the **huddly_conan** branch, which will be the main branch for Huddly projects.

## Updating conan2 remote repository

The conan2 build will pull these recipes from the **conan-center-local** remote. When modifying recipes, they will need to be upload to the remote in order to be used.

Use the Python script **export_recipes.py** to export and upload recipes.

Export and upload all recipes from the repository (only new versions or recipes will be uploaded):
```
python export_recipes.py
```
Export and upload all recipes (force reupload of all recipes)
```
python export_recipes.py --force
```
Export and upload a single recipe
```
python export_recipes.py --recipe _recipename_
```
