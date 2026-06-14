@{
    Severity = @('Error', 'Warning')
    IncludeRules = @(
        'PSAvoidUsingInvokeExpression',
        'PSAvoidUsingPlainTextForPassword',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSAvoidUsingWriteHost',
        'PSUseApprovedVerbs',
        'PSAvoidDefaultValueSwitchParameter'
    )
    ExcludeRules = @(
        # Dozvoljavamo Write-Host u Start-KwtMenu.ps1 za renders menija
    )
}
