# Manifest za modul KorisneWindowsTools
@{
    # Verzija modula
    ModuleVersion = '0.2.0'

    # Identifikacioni GUID modula
    GUID = '4c2a5d7e-7a76-4d2d-82d2-43f65fe9d8d1'

    # Autor modula
    Author = 'o0o0o0o'

    # Kompanija / Organizacija
    CompanyName = 'o0o0o0o'

    # Autorska prava
    Copyright = 'Copyright (c) 2026 o0o0o0o. Sva prava zadržana.'

    # Opis modula
    Description = 'Sveobuhvatan toolkit za Windows optimizaciju, čišćenje, bezbednost i mrežnu administraciju.'

    # Minimalna verzija PowerShell-a
    PowerShellVersion = '5.1'

    # Glavni fajl modula (.psm1)
    RootModule = 'KorisneWindowsTools.psm1'

    # Funkcije koje se izvoze iz modula
    FunctionsToExport = @('*-Kwt*')

    # Cmdleti koji se izvoze iz modula
    CmdletsToExport = '*'

    # Varijable koje se izvoze iz modula
    VariablesToExport = '*'

    # Alijasi koji se izvoze iz modula
    AliasesToExport = '*'

    # Privatni podaci modula
    PrivateData = @{
        PSData = @{
            # Tagovi za PowerShell Gallery
            Tags = @('Windows', 'PowerShell', 'Serbian', 'Utility', 'Security', 'Admin')
            # Licenca
            LicenseUri = 'https://github.com/zoxknez/KorisneWindowsPowerShellSkripte/blob/main/LICENSE'
            # Projekat
            ProjectUri = 'https://github.com/zoxknez/KorisneWindowsPowerShellSkripte'
        }
    }
}


