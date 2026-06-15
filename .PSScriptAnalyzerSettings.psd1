@{
    Severity = @('Error', 'Warning')
    IncludeRules = @(
        'PSAvoidUsingInvokeExpression',
        'PSAvoidUsingPlainTextForPassword',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSUseApprovedVerbs',
        'PSAvoidDefaultValueSwitchParameter'
    )
    ExcludeRules = @(
        'PSAvoidUsingWriteHost'
    )
}
