
######################################################################################
# The Get-TargetResource cmdlet.
# This function will get the present list of IP Address DSC Resource schema variables on the system
######################################################################################
function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$NetworkSubnet,

		[parameter(Mandatory = $true)]
		[System.String]
		$NetworkPrefix,

        [parameter(Mandatory = $false)]
		[System.String]
		$NetworkName,

        [parameter(Mandatory = $false)]
		[System.String]
		$NetworkMetric,

        [parameter(Mandatory = $false)]
		[ValidateSet("1","2","3")]
        [System.String]
		$NetworkRole,

        [ValidateSet("IPv4", "IPv6")]
        [String]$AddressFamily = "IPv4"
	)

    switch ($AddressFamily) {
    IPv4 {
            $returnValue = @{
                NetworkName = (Get-ClusterNetwork | where-object { $_.Ipv4Addresses -eq $NetworkSubnet -and $_.Ipv4PrefixLengths -eq $NetworkPrefix}).Name
                NetworkSubnet = $NetworkSubnet
                NetworkPrefix = $NetworkPrefix
                AddressFamily = $AddressFamily
                NetworkMetric = (Get-ClusterNetwork | where-object { $_.Ipv4Addresses -eq $NetworkSubnet -and $_.Ipv4PrefixLengths -eq $NetworkPrefix}).Metric
                NetworkRole = (Get-ClusterNetwork | where-object { $_.Ipv4Addresses -eq $NetworkSubnet -and $_.Ipv4PrefixLengths -eq $NetworkPrefix}).Role
	            }
         }
    IPv6 {
            $returnValue = @{
                NetworkName = (Get-ClusterNetwork | where-object { $_.Ipv6Addresses -eq $NetworkSubnet -and $_.Ipv6PrefixLengths -eq $NetworkPrefix}).Name
                NetworkSubnet = $NetworkSubnet
                NetworkPrefix = $NetworkPrefix
                AddressFamily = $AddressFamily
                NetworkMetric = (Get-ClusterNetwork | where-object { $_.Ipv6Addresses -eq $NetworkSubnet -and $_.Ipv6PrefixLengths -eq $NetworkPrefix}).Metric
                NetworkRole = (Get-ClusterNetwork | where-object { $_.Ipv6Addresses -eq $NetworkSubnet -and $_.Ipv6PrefixLengths -eq $NetworkPrefix}).Role
	            }
         }
         }
	$returnValue
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$NetworkSubnet,

		[parameter(Mandatory = $true)]
		[System.String]
		$NetworkPrefix,

		[ValidateSet("IPv4","IPv6")]
		[System.String]
		$AddressFamily,

		[System.String]
		$NetworkName,

		[System.String]
		$NetworkMetric,

        [ValidateSet("1","2","3")]
		[System.String]
		$NetworkRole
	)

	 ValidateProperties @PSBoundParameters -Apply

}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$NetworkSubnet,

		[parameter(Mandatory = $true)]
		[System.String]
		$NetworkPrefix,

		[ValidateSet("IPv4","IPv6")]
		[System.String]
		$AddressFamily,

		[System.String]
		$NetworkName,

		[System.String]
		$NetworkMetric,

        [ValidateSet("1","2","3")]
        [System.String]
		$NetworkRole
	)

	 ValidateProperties @PSBoundParameters

}

#######################################################################################
#  Helper function that validates the Cluster Network. If the switch parameter
# "Apply" is set, then it will set the properties after a test
#######################################################################################
function ValidateProperties
{
    param
    (
		[parameter(Mandatory = $true)]
		[System.String]
		$NetworkSubnet,

		[parameter(Mandatory = $true)]
		[System.String]
		$NetworkPrefix,

		[ValidateSet("IPv4","IPv6")]
		[System.String]
		$AddressFamily = "IPv4",

		[System.String]
		$NetworkName,

		[System.String]
		$NetworkMetric,

        [ValidateSet("1","2","3")]
        [System.String]
		$NetworkRole,

        [Switch]$Apply
    )

    $ConfigurationValid = 1
    try
    {        
        #Get the current ClusterNetwork values based on the parameters given.
        switch ($AddressFamily){
            IPv4 {$currentName = (Get-ClusterNetwork | where-object { $_.Ipv4Addresses -eq $NetworkSubnet -and $_.Ipv4PrefixLengths -eq $NetworkPrefix}).Name}
            IPv6 {$currentName = (Get-ClusterNetwork | where-object { $_.Ipv6Addresses -eq $NetworkSubnet -and $_.Ipv6PrefixLengths -eq $NetworkPrefix}).Name}
            }
        $currentMetric = (Get-ClusterNetwork -Name $currentName).Metric
        $currentRole = (Get-ClusterNetwork -Name $currentName).Role

        #Test if the ClusterName passed is equal to the Desired ClusterName
        Write-Verbose -Message "Checking the ClusterNetwork Name ..."
        if(!($currentName -eq $NetworkName) -and $NetworkName)
        {
            Write-Verbose -Message "ClusterNetwork Name not correct. Expected $NetworkName, actual $CurrentName"
            $Parameters = @{}

            #Apply is true in the case of set - target resource - in which case, it will set the new ClusterName
            if($Apply)
            {
                Write-Verbose -Message "Setting ClusterNetwork Name ..."
                (Get-ClusterNetwork -Name $currentName).Name = $NetworkName
                Write-Verbose -Message "ClusterNetwork Name is set to $NetworkName."
                $currentName = $NetworkName
            }
            else {$ConfigurationValid = 0}
        }
        else
        {
            Write-Verbose -Message "ClusterNetwork Name is correct."
        }

        #Test if the ClusterMetric passed is equal to the Desired ClusterMetric
        Write-Verbose -Message "Checking the ClusterNetwork Metric ..."
        if(!($currentMetric -eq $NetworkMetric) -and $NetworkMetric)
        {
            Write-Verbose -Message "ClusterNetwork Metric not correct. Expected $NetworkMetric, actual $CurrentMetric"
            $Parameters = @{}

            #Apply is true in the case of set - target resource - in which case, it will set the new ClusterMetric
            if($Apply)
            {
                Write-Verbose -Message "Setting ClusterNetwork Metric ..."
                (Get-ClusterNetwork -Name $currentName).Metric = $NetworkMetric
                Write-Verbose -Message "ClusterMetric is set to $NetworkMetric."
            }
            else {$ConfigurationValid = 0}
        }
        else
        {
            Write-Verbose -Message "ClusterNetwork Metric is correct."
        }

        #Test if the ClusterNetwork Role passed is equal to the Desired ClusterRole
        Write-Verbose -Message "Checking the ClusterNetwork Role ..."
        if(!($currentRole -eq $NetworkRole) -and $NetworkRole)
        {
            Write-Verbose -Message "ClusterNetwork Role not correct. Expected $NetworkRole, actual $CurrentRole"
            $Parameters = @{}

            #Apply is true in the case of set - target resource - in which case, it will set the new ClusterRole
            if($Apply)
            {
                Write-Verbose -Message "Setting ClusterNetwork Role ..."
                (Get-ClusterNetwork -Name $currentName).Role = $NetworkRole
                Write-Verbose -Message "ClusterNetwork Role is set to $NetworkRole."
            }
            else {$ConfigurationValid = 0}
        }
        else
        {
            Write-Verbose -Message "ClusterNetwork Role is correct."
        }
        switch ($ConfigurationValid) {
            0 {return $false}
            1 {return $true}
        }
    }
    catch
    {
       Write-Verbose -Message $_
       throw "Can not set or find valid ClusterNetwork using NetworkSubnet $NetworkSubnet and PrefixLength $NetworkPrefix"
    }
}

Export-ModuleMember -Function *-TargetResource

