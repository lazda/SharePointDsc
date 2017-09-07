function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Url,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $OwnerAlias,

        [Parameter(Mandatory = $false)] 
        [System.UInt32] 
        $CompatibilityLevel,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $ContentDatabase,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $Description,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $HostHeaderWebApplication,

        [Parameter(Mandatory = $false)] 
        [System.UInt32] 
        $Language,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $Name,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $OwnerEmail,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $QuotaTemplate,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $SecondaryEmail,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $SecondaryOwnerAlias,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $Template,

        [Parameter(Mandatory = $false)] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting site collection $Url"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $site = Get-SPSite -Identity $params.Url `
                           -ErrorAction SilentlyContinue
        
        if ($null -eq $site) 
        { 
            return $null 
        } 
        else 
        {
            if ($site.HostHeaderIsSiteName) 
            { 
                $HostHeaderWebApplication = $site.WebApplication.Url 
            } 

            if ($null -eq $site.Owner) 
            {
                $owner = $null
            } 
            else 
            {
                if ($site.WebApplication.UseClaimsAuthentication) 
                {
                    $owner = (New-SPClaimsPrincipal -Identity $site.Owner.UserLogin `
                                                    -IdentityType "EncodedClaim").Value
                } 
                else 
                {
                    $owner = $site.Owner.UserLogin
                }
            }
            
            if ($null -eq $site.SecondaryContact) 
            {
                $secondaryOwner = $null
            } 
            else 
            {
                if ($site.WebApplication.UseClaimsAuthentication) 
                {
                    $secondaryOwner = (New-SPClaimsPrincipal -Identity $site.SecondaryContact.UserLogin `
                                                             -IdentityType "EncodedClaim").Value
                } 
                else 
                {
                    $secondaryOwner = $site.SecondaryContact.UserLogin
                }
            }

            $admService = Get-SPDSCContentService
            $quota = ($admService.QuotaTemplates | `
                      Where-Object -FilterScript {
                          $_.QuotaID -eq $site.Quota.QuotaID
                      }).Name
            
            return @{
                Url = $site.Url
                OwnerAlias = $owner
                CompatibilityLevel = $site.CompatibilityLevel
                ContentDatabase = $site.ContentDatabase.Name
                Description = $site.RootWeb.Description
                HostHeaderWebApplication = $HostHeaderWebApplication
                Language = $site.RootWeb.Language
                Name = $site.RootWeb.Name
                OwnerEmail = $site.Owner.Email
                QuotaTemplate = $quota
                SecondaryEmail = $site.SecondaryContact.Email
                SecondaryOwnerAlias = $secondaryOwner
                Template = "$($site.RootWeb.WebTemplate)#$($site.RootWeb.Configuration)"
                InstallAccount = $params.InstallAccount
            }
        }
    }
    return $result
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Url,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $OwnerAlias,

        [Parameter(Mandatory = $false)] 
        [System.UInt32] 
        $CompatibilityLevel,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $ContentDatabase,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $Description,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $HostHeaderWebApplication,

        [Parameter(Mandatory = $false)] 
        [System.UInt32] 
        $Language,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $Name,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $OwnerEmail,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $QuotaTemplate,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $SecondaryEmail,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $SecondaryOwnerAlias,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $Template,

        [Parameter(Mandatory = $false)] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting site collection $Url"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
        
        $params.Remove("InstallAccount") | Out-Null

        $site = Get-SPSite -Identity $params.Url -ErrorAction SilentlyContinue

        if ($null -eq $site) 
        {
            New-SPSite @params | Out-Null
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Url,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $OwnerAlias,

        [Parameter(Mandatory = $false)] 
        [System.UInt32] 
        $CompatibilityLevel,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $ContentDatabase,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $Description,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $HostHeaderWebApplication,

        [Parameter(Mandatory = $false)] 
        [System.UInt32] 
        $Language,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $Name,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $OwnerEmail,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $QuotaTemplate,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $SecondaryEmail,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $SecondaryOwnerAlias,

        [Parameter(Mandatory = $false)] 
        [System.String] 
        $Template,

        [Parameter(Mandatory = $false)] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Testing site collection $Url"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues) 
    { 
        return $false 
    }
    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("Url")
}

Export-ModuleMember -Function *-TargetResource
