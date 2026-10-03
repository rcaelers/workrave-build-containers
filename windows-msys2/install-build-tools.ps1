$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

Invoke-WebRequest -UseBasicParsing -Uri 'https://aka.ms/vs/17/release/vs_buildtools.exe' -OutFile C:/build-tools.exe
$signature = Get-AuthenticodeSignature C:/build-tools.exe
if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'Microsoft Corporation') {
    throw 'Visual Studio Build Tools signature is invalid'
}
$installerArguments = '--quiet --wait --norestart --nocache --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.26100'
$installer = Start-Process C:/build-tools.exe -ArgumentList $installerArguments -Wait -PassThru
if ($installer.ExitCode -notin 0, 3010) {
    Get-Content "$env:TEMP/dd_setup_*errors.log" -ErrorAction SilentlyContinue
    throw "Visual Studio Build Tools installation failed: $($installer.ExitCode)"
}
Remove-Item C:/build-tools.exe
