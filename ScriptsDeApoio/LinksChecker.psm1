using namespace System.Diagnostics
using namespace System.Text.Json

class LinksChecker {
    [string]$LinksCheckerPath
    [string]$HtmlDir

    LinksChecker([string]$linksCheckerPath, [string]$htmlDir) {
        $this.LinksCheckerPath = $linksCheckerPath
        $this.HtmlDir = $htmlDir
    }

    [string] Run() {
        $startInfo = [ProcessStartInfo]::new()
        $startInfo.FileName = $this.LinksCheckerPath
        $startInfo.Arguments = "-htmlDir `"$($this.HtmlDir)`""
        $startInfo.RedirectStandardOutput = $true
        $startInfo.UseShellExecute = $false
        $startInfo.CreateNoWindow = $true

        $process = [Process]::new()
        $process.StartInfo = $startInfo
        $process.Start() | Out-Null

        $output = $process.StandardOutput.ReadToEnd()
        $process.WaitForExit()

        # Print the output for debugging
        Write-Host "Output from LinksChecker:"
        Write-Host $output

        return $output
    }
}