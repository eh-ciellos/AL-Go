# Deliver
Deliver App to deliveryTarget (AppSource, Storage, or...)

## INPUT

### ENV variables
none

### Parameters
| Name | Required | Description | Default value |
| :-- | :-: | :-- | :-- |
| shell | | The shell (powershell or pwsh) in which the PowerShell script in this action should run | powershell |
| actor | | The GitHub actor running the action | github.actor |
| token | | The GitHub token running the action | github.token |
| parentTelemetryScopeJson | | Specifies the parent telemetry scope for the telemetry signal | {} |
| projects | | Comma separated list of projects to deliver | * |
| deliveryTarget | Yes | Delivery target (AppSource, Storage, GitHubPackages,...) | |
| artifacts | Yes | The artifacts to deliver | |
| type | | Type of delivery (CD or Release) | CD |
| atypes | | Artifact types to deliver | Apps,Dependencies,TestApps |
| goLive | | Only relevant for AppSource delivery type. Promote AppSource App to Go Live? | N |

## OUTPUT
none
