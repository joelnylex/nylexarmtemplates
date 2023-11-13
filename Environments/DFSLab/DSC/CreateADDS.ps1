#https://learn.microsoft.com/en-us/powershell/dsc/configurations/configurations?view=dsc-1.1
Configuration CreateADDS
{
    param
    (
        [Parameter(Mandatory)]
        [String]$hostName,

        [Parameter(Mandatory)]
        [String]$domainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$adminCreds
    )
    
    Import-DscResource -ModuleName xActiveDirectory


    Node $hostName {
        WindowsFeature ADDSInstall {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        }
        WindowsFeature DNS {
            Ensure = 'Present'
            Name = 'DNS'
        }
        WindowsFeature DnsTools {
            Ensure    = "Present"
            Name      = "RSAT-DNS-Server"
            DependsOn = "[WindowsFeature]DNS"
        }
        WindowsFeature ADDSTools {
            Ensure    = "Present"
            Name      = "RSAT-ADDS-Tools"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xADDomain FirstDS 
        {
            DomainName                    = $domainName
            DomainAdministratorCredential = $adminCreds
            SafemodeAdministratorPassword = $adminCreds
            DatabasePath                  = "C:\NTDS"
            LogPath                       = "C:\NTDS"
            SysvolPath                    = "C:\SYSVOL"
            DependsOn                     = "[WindowsFeature]ADDSInstall"
        } 
    }
}
CreateADDS