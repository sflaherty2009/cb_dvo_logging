# Changelog - build_cookbook

All notable changes to this project will be documented in this file.

## [Unreleased]

### Changed

## [0.1.4] - 2018-11-2

### Modified

- Fixed a reference to the workflow cookbook name. It was conflicting with a built in reference.

## [0.1.3] - 2018-11-2

### Added

- This changelog file.

### Modified

- Switched to the AzureRM backend for Terraform templates.
- Moved some Terraform credentials into environment variables.
- Separated provision and deprovision steps. Deprovision now occours in the functional phase.
