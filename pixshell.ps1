#### Script By: Arman Pasha ####
# Draws the given image in the powershell terminal 
# Usage: & .\pixshell.ps1 <path or URL to the image> <ratio (optional)>
# Path can be local (e.g. C:\Users\Arman\Desktop\img.jpg) or online (e.g. www.image.com/img.jpg)
# Use ratio to resize the image. Larger ratio's result in smaller image outputs (Default is 10)
# For large images use large ratio or it will take a decade to print the image :D
# If the print output exceeds the terminal, use a larger ratio
# PNG images without background are supported


[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
cls
if($args.Length -lt 1){
    Write-Error "You must provide the image path"
    exit
}elseif ($args.Length -eq 1) {
    $file = $args[0]
    $ratio = 10;
}elseif ($args.Length -eq 2){
    $file = $args[0]
    $ratio = $args[1]
}

if($file.StartsWith('www') -or $file.StartsWith('http') -or $file.StartsWith('https')){
    $splitted = $file.Split("/")
    $tmp_out = $PWD.Path + "/" + $splitted[-1]
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($file, $tmp_out)
    $b = [System.Drawing.Bitmap]::FromFile((Resolve-Path $tmp_out).ProviderPath)
}else {
    $b = [System.Drawing.Bitmap]::FromFile((Resolve-Path $file).ProviderPath)
}

$pix = [char] 0x2588
$escape = [char]27 + '['
$resetAttributes = "$($escape)0m"

for ($i = 0; $i -lt $b.Height; $i+=$ratio) {
    for ($j = 0; $j -lt $b.Width; $j+=$ratio) {
        $pixel = $b.GetPixel($j, $i)
        if($pixel.A -eq 0){
            Write-Host " " -NoNewline
        }else{
            $foreground = "$($escape)38;2;$($pixel.R);$($pixel.G);$($pixel.B)m"
            Write-Host ($escape + $foreground + $pix + $resetAttributes) -NoNewline
        }
        
    }
    Write-Host
}

$b.dispose()
if($tmp_out){
    rm $tmp_out
}