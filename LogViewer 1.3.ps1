#Requires -Version 5.1
# ============================================================
# LOGVIEWER - MONITORAMENTO DE LOGS
# Criado por Guilherme Analista Infra Seg
# ============================================================

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# ============================================================
# CONFIGURACOES
# ============================================================

$script:LogRoot = '\\10.0.12.68\c$\temp\Logs OS Automatizados\LOGS'
$script:Hoje = (Get-Date).Date

$script:CultureEnglish = [Globalization.CultureInfo]::GetCultureInfo('en-US')
$script:CulturePortuguese = [Globalization.CultureInfo]::GetCultureInfo('pt-BR')

$script:LogButtons = @(
    [pscustomobject]@{Key='APL_UCC';Label='Serviços Gesthos';File='APLGesthos(10.0.0.201).txt';Description='Verificar execução das APL Gesthos UCC (Erros verificar no servidor 10.0.0.204\temp)';Group=1;Parser='APL'}
    [pscustomobject]@{Key='DISCOS_UCC';Label='Discos Gesthos';File='ArmazenamentoRestante(10.0.0.200-201).txt';Description='Verificar armazenamento discos Gesthos UCC (10.0.0.200/201)';Group=1;Parser='DISKS'}
    [pscustomobject]@{Key='BCK_UCC';Label='Backups Gesthos';File='BCK(10.0.0.226).txt';Description='Backups Gesthos UCC (Erros verificar no servidor 10.0.0.226\CobianAPL)';Group=1;Parser='BCK_UCC'}
    [pscustomobject]@{Key='FIREBIRD_UCC';Label='Sweep Firebird';File='Firebird(10.0.0.200).txt';Description='Verificação Sweep Firebird (Erros verificar no servidor 10.0.0.200\firebird.log)';Group=1;Parser='FIREBIRD_UCC'}
    [pscustomobject]@{Key='REPLICAS';Label='Saúde Replicas';File='ReplicasSaude(10.0.0.126-10.0.4.232).txt';Description='Verificação saúde das réplicas (Erros verificar no servidor 10.0.4.232)';Group=1;Parser='REPLICAS'}
    [pscustomobject]@{Key='APL_USL';Label='Serviços Gesthos';File='APLGesthos(10.0.8.201).txt';Description='Verificar execução das APL Gesthos USL (Erros verificar no servidor 10.0.8.201\temp)';Group=2;Parser='APL'}
    [pscustomobject]@{Key='APL_WTS';Label='Serviço WhatsApp';File='APLGesthos(10.0.11.251).txt';Description='Verificar execução da APL Whats/Gesthos USL (Erros verificar no servidor 10.0.11.251\temp)';Group=2;Parser='APL'}
    [pscustomobject]@{Key='DISCOS_USL';Label='Discos Gesthos';File='ArmazenamentoRestanteSL(10.0.8.200-201).txt';Description='Verificar armazenamento discos Gesthos USL (10.0.8.200/201)';Group=2;Parser='DISKS'}
    [pscustomobject]@{Key='BCK_USL';Label='Backups Gesthos';File='BCKGesthosSL(10.0.8.222).txt';Description='Backups Gesthos USL (Erros verificar no servidor 10.0.8.222)';Group=2;Parser='BCK_USL'}
    [pscustomobject]@{Key='FIREBIRD_USL';Label='Sweep Firebird';File='Firebird(10.0.8.200).txt';Description='Verificação Sweep Firebird (Erros verificar no servidor 10.0.8.200\firebird.log)';Group=2;Parser='FIREBIRD_USL'}
    [pscustomobject]@{Key='AR_USL';Label='Backup ARLAB';File='BCKArSistmsSL(10.0.8.222).txt';Description='Backups ARLAB USL (Erros verificar no servidor 10.0.8.222)';Group=2;Parser='AR_BCK'}
)

# ============================================================
# INTERFACE WPF
# ============================================================

[xml]$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="LogViewer" Width="1180" Height="850" MinWidth="920" MinHeight="680"
        WindowStartupLocation="CenterScreen" Background="#F4F5F7" Foreground="#252A31"
        FontFamily="Segoe UI">

    <Window.Resources>
        <SolidColorBrush x:Key="Ink" Color="#252A31"/>
        <SolidColorBrush x:Key="Muted" Color="#6B7280"/>
        <SolidColorBrush x:Key="Border" Color="#D8DCE2"/>
        <SolidColorBrush x:Key="Card" Color="#FFFFFF"/>

        <Style TargetType="Button">
            <Setter Property="Foreground" Value="#252A31"/>
            <Setter Property="Background" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#C9CED6"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12,9"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>

            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="ButtonBorder"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="9"
                                Padding="{TemplateBinding Padding}">

                            <ContentPresenter HorizontalAlignment="Center"
                                              VerticalAlignment="Center"/>
                        </Border>

                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="ButtonBorder" Property="Background" Value="#E8EBEF"/>
                                <Setter TargetName="ButtonBorder" Property="BorderBrush" Value="#AEB5BF"/>
                            </Trigger>

                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="ButtonBorder" Property="Background" Value="#DDE1E7"/>
                            </Trigger>

                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Opacity" Value="0.55"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="TextBox">
            <Setter Property="Background" Value="#FFFFFF"/>
            <Setter Property="Foreground" Value="#252A31"/>
            <Setter Property="BorderBrush" Value="#D8DCE2"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="10"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontFamily" Value="Consolas"/>
        </Style>
    </Window.Resources>

    <Grid Margin="18">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <Border Grid.Row="0" Background="#FFFFFF" BorderBrush="#D8DCE2"
                BorderThickness="1" CornerRadius="12" Padding="18" Margin="0,0,0,14">

            <Grid>
                <StackPanel>
                    <TextBlock Text="⌕ LogViewer" FontSize="27"
                               FontWeight="Bold" Foreground="#20242B"/>

                    <TextBlock Text="Painel de monitoramento dos logs diários"
                               FontSize="12" Foreground="#6B7280"
                               Margin="1,4,0,0"/>
                </StackPanel>

                <StackPanel Orientation="Horizontal"
                            HorizontalAlignment="Right"
                            VerticalAlignment="Center">

                    <Border Background="#F1F3F5" BorderBrush="#D8DCE2"
                            BorderThickness="1" CornerRadius="8"
                            Padding="10,6" Margin="0,0,10,0">

                        <TextBlock x:Name="TxtConnection"
                                   Text="Origem: aguardando acesso"
                                   FontSize="11" Foreground="#525A65"/>
                    </Border>

                    <Button x:Name="BtnBackupsServidor"
                            Content="Backups Sistemas"
                            Padding="12,8" FontSize="11"
                            Background="#087F91" Foreground="White"
                            BorderBrush="#087F91"
                            FontWeight="SemiBold"
                            ToolTip="Executar o Monitor de Backups do servidor"/>
                </StackPanel>
            </Grid>
        </Border>

        <Border Grid.Row="1" Background="#FFFFFF" BorderBrush="#D8DCE2"
                BorderThickness="1" CornerRadius="12" Padding="14"
                Margin="0,0,0,12">

            <StackPanel>
                <TextBlock Text="SELECIONE O LOG :              [ 1ª LINHA >> UCC    \    2ª LINHA >> USL ]"
                           FontSize="11" FontWeight="Bold"
                           Foreground="#6B7280" Margin="2,0,0,10"/>

                <UniformGrid x:Name="GridBotoesLinha1"
                             Rows="1" Columns="5" Margin="0,0,0,8"/>

                <UniformGrid x:Name="GridBotoesLinha2"
                             Rows="1" Columns="6"/>
            </StackPanel>
        </Border>

        <Border Grid.Row="2" Background="#FFFFFF" BorderBrush="#D8DCE2"
                BorderThickness="1" CornerRadius="12" Padding="14"
                Margin="0,0,0,12">

            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="95"/>
                </Grid.RowDefinitions>

                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <TextBlock Text="CONTEÚDO DO LOG (somente leitura — clique no campo copia o conteudo)"
                           FontSize="11" FontWeight="Bold"
                           Foreground="#6B7280" Margin="1,0,0,8"/>

                <TextBlock x:Name="TxtArquivoSelecionado"
                           Grid.Column="1"
                           Text="Nenhum arquivo selecionado"
                           Foreground="#6B7280" FontSize="11"
                           VerticalAlignment="Center" Margin="10,0,0,8"/>

                <TextBox x:Name="TxtLog" Grid.Row="1"
                         Grid.ColumnSpan="2" IsReadOnly="True"
                         AcceptsReturn="True" TextWrapping="NoWrap"
                         VerticalScrollBarVisibility="Auto"
                         HorizontalScrollBarVisibility="Auto"
                         VerticalContentAlignment="Top"/>
            </Grid>
        </Border>

        <Border Grid.Row="3" Background="#FFFFFF" BorderBrush="#D8DCE2"
                BorderThickness="1" CornerRadius="12" Padding="14"
                Margin="0,0,0,12">

            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>

                    <StackPanel>
                        <TextBlock Text="RESULTADOS DA ANÁLISE"
                                   FontSize="12" FontWeight="Bold"
                                   Foreground="#343A43"/>

                        <TextBlock x:Name="TxtResumo"
                                   Text="Selecione um botão para carregar e analisar o log."
                                   FontSize="11" Foreground="#6B7280"
                                   Margin="0,4,0,0"/>
                    </StackPanel>

                    <Button x:Name="BtnLimparResultados"
                            Grid.Column="1"
                            Content="Limpar resultados"
                            Padding="12,7" FontSize="11"
                            VerticalAlignment="Center"/>
                </Grid>

                <ScrollViewer Grid.Row="1" Margin="0,12,0,0"
                              VerticalScrollBarVisibility="Auto"
                              HorizontalScrollBarVisibility="Auto">

                    <StackPanel x:Name="PainelResultados"/>
                </ScrollViewer>
            </Grid>
        </Border>

        <Border Grid.Row="4" Background="#ECEFF2" BorderBrush="#D8DCE2"
                BorderThickness="1" CornerRadius="8" Padding="9,7">

            <Grid>
                <TextBlock x:Name="TxtStatus"
                           Text="Status: Pronto"
                           FontSize="11" Foreground="#555D68"/>

                <TextBlock Text="LogViewer • v1.0"
                           HorizontalAlignment="Right"
                           FontSize="11" Foreground="#7A828D"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$Reader = New-Object System.Xml.XmlNodeReader $Xaml
$Window = [Windows.Markup.XamlReader]::Load($Reader)

# Referencias dos controles
$GridBotoesLinha1 = $Window.FindName('GridBotoesLinha1')
$GridBotoesLinha2 = $Window.FindName('GridBotoesLinha2')
$TxtLog = $Window.FindName('TxtLog')
$TxtArquivoSelecionado = $Window.FindName('TxtArquivoSelecionado')
$PainelResultados = $Window.FindName('PainelResultados')
$TxtStatus = $Window.FindName('TxtStatus')
$TxtResumo = $Window.FindName('TxtResumo')
$TxtConnection = $Window.FindName('TxtConnection')
$BtnLimparResultados = $Window.FindName('BtnLimparResultados')
$BtnBackupsServidor = $Window.FindName('BtnBackupsServidor')

# ============================================================
# FUNCOES VISUAIS
# ============================================================

function Add-ResultRow {
    param(
        [Parameter(Mandatory=$true)][string]$Text,
        [ValidateSet('Green','Red','Amber','Gray')]
        [string]$State = 'Gray'
    )

    $colors = @{
        Green='#21A366'
        Red='#D64545'
        Amber='#D99A24'
        Gray='#9299A3'
    }

    $row = New-Object System.Windows.Controls.Grid
    $row.Margin = '0,0,0,6'
    $row.MinHeight = 34

    $colLed = New-Object System.Windows.Controls.ColumnDefinition
    $colLed.Width = '28'

    $colText = New-Object System.Windows.Controls.ColumnDefinition
    $colText.Width = '*'

    [void]$row.ColumnDefinitions.Add($colLed)
    [void]$row.ColumnDefinitions.Add($colText)

    $led = New-Object System.Windows.Shapes.Ellipse
    $led.Width = 11
    $led.Height = 11
    $led.VerticalAlignment = 'Center'
    $led.HorizontalAlignment = 'Center'
    $led.Stroke = [System.Windows.Media.Brushes]::White
    $led.StrokeThickness = 1
    $led.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString($colors[$State])

    [System.Windows.Controls.Grid]::SetColumn($led,0)
    [void]$row.Children.Add($led)

    $textBlock = New-Object System.Windows.Controls.TextBlock
    $textBlock.Text = $Text
    $textBlock.TextWrapping = 'Wrap'
    $textBlock.VerticalAlignment = 'Center'
    $textBlock.FontSize = 12
    $textBlock.Foreground = [System.Windows.Media.Brushes]::DarkSlateGray
    $textBlock.Margin = '4,5,4,5'

    [System.Windows.Controls.Grid]::SetColumn($textBlock,1)
    [void]$row.Children.Add($textBlock)

    $card = New-Object System.Windows.Controls.Border
    $card.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#F8F9FA')
    $card.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#E2E5E9')
    $card.BorderThickness = [System.Windows.Thickness]::new(1)
    $card.CornerRadius = [System.Windows.CornerRadius]::new(6)
    $card.Padding = '7,2'
    $card.Child = $row

    [void]$PainelResultados.Children.Add($card)
}

function Add-ResultHeader {
    param([string]$Text)

    $header = New-Object System.Windows.Controls.TextBlock
    $header.Text = $Text
    $header.FontSize = 12
    $header.FontWeight = 'Bold'
    $header.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#4B5563')
    $header.Margin = '2,8,0,8'

    [void]$PainelResultados.Children.Add($header)
}

# ============================================================
# FUNCOES AUXILIARES
# ============================================================

function Show-NonMondayNotice {
    if ((Get-Date).DayOfWeek -ne [DayOfWeek]::Monday) {
        [System.Windows.MessageBox]::Show(
            'Logs são gerados as SEGUNDAS-FEIRAS',
            'Aviso sobre a geração dos logs',
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Information
        ) | Out-Null
    }
}

function Get-LastWeekday {
    param(
        [Parameter(Mandatory=$true)][datetime]$FromDate,
        [Parameter(Mandatory=$true)][DayOfWeek]$Day
    )

    $date = $FromDate.Date
    while ($date.DayOfWeek -ne $Day) {
        $date = $date.AddDays(-1)
    }

    return $date
}

function Convert-FirebirdDate {
    param([string]$Line)

    $pattern = '^\s*(?<host>\S+)\s+(?<dow>Mon|Tue|Wed|Thu|Fri|Sat|Sun)\s+(?<month>[A-Za-z]{3})\s+(?<day>\d{1,2})\s+(?<time>\d{2}:\d{2}:\d{2})\s+(?<year>\d{4})'

    $m = [regex]::Match($Line,$pattern)
    if (-not $m.Success) { return $null }

    $dateText = '{0} {1} {2} {3}' -f $m.Groups['month'].Value,$m.Groups['day'].Value,$m.Groups['year'].Value,$m.Groups['time'].Value

    try {
        return [datetime]::ParseExact($dateText,'MMM d yyyy HH:mm:ss',$script:CultureEnglish)
    } catch {
        return $null
    }
}

function Test-FirebirdSweep {
    param(
        [string[]]$Lines,
        [string]$ExpectedHost,
        [DayOfWeek]$ExpectedDay,
        [string]$DayLabel
    )

    $expectedDate = Get-LastWeekday -FromDate (Get-Date).Date -Day $ExpectedDay
    $found = $false

    for ($i=0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match "^\s*$([regex]::Escape($ExpectedHost))\s+") {

            $date = Convert-FirebirdDate -Line $Lines[$i]
            $finished = ($i + 1 -lt $Lines.Count -and $Lines[$i+1] -match 'Sweep is finished')

            if ($date -and $date.Date -eq $expectedDate -and $finished) {
                Add-ResultRow -State Green -Text ("Sweep Concluído no {0} - {1}" -f $DayLabel,$date.ToString('dd/MM/yyyy HH:mm:ss'))
                $found = $true
                break
            }
        }
    }

    if (-not $found) {
        Add-ResultRow -State Red -Text ("Erro no Sweep no {0} (data esperada: {1})" -f $DayLabel,$expectedDate.ToString('dd/MM/yyyy'))
    }
}

# ============================================================
# ANALISADOR DE REPLICAS
# ============================================================

function Analyze-Replicas {
    param([string[]]$Lines)

    Show-NonMondayNotice

    $dateLine = $Lines |
        Where-Object { $_ -match 'Data/Hora:\s*(?<date>\d{2}/\d{2}/\d{4})' } |
        Select-Object -Last 1

    $logDate = $null

    if ($dateLine -and $dateLine -match 'Data/Hora:\s*(\d{2}/\d{2}/\d{4})') {
        try {
            $logDate = [datetime]::ParseExact($Matches[1],'dd/MM/yyyy',$script:CulturePortuguese)
        } catch {}
    }

    if ($logDate) {
        $state = if ($logDate.Date -eq (Get-Date).Date) {'Green'} else {'Red'}
        Add-ResultRow -State $state -Text ("Data/Hora do relatório: {0}" -f $dateLine.Trim())
    } else {
        Add-ResultRow -State Red -Text 'Data/Hora do relatório não encontrada.'
    }

    $replicaLines = @($Lines | Where-Object { $_ -match '\bReplicating\b' })

    if ($replicaLines.Count -eq 0) {
        Add-ResultRow -State Red -Text 'Nenhuma linha com Replicating foi encontrada.'
        return
    }

    foreach ($line in $replicaLines) {
        $m = [regex]::Match($line,'^\s*(?<vm>\S+)\s+Replicating\s+(?<health>\S+)\s+(?<last>.+?)\s*$')

        if (-not $m.Success) {
            Add-ResultRow -State Red -Text ("Linha de réplica não reconhecida: {0}" -f $line.Trim())
            continue
        }

        $vm = $m.Groups['vm'].Value
        $health = $m.Groups['health'].Value
        $last = $m.Groups['last'].Value.Trim()

        if ($health -ieq 'Normal') {
            Add-ResultRow -State Green -Text ("{0} Replica Funcional - {1}" -f $vm,$last)
        } else {
            Add-ResultRow -State Red -Text ("{0} Replica Falhando ({1}) - {2}" -f $vm,$health,$last)
        }
    }
}

# ============================================================
# ANALISADOR FIREBIRD
# ============================================================

function Analyze-Firebird {
    param(
        [string[]]$Lines,
        [string]$HostName
    )

    Show-NonMondayNotice

    Test-FirebirdSweep -Lines $Lines -ExpectedHost $HostName -ExpectedDay ([DayOfWeek]::Saturday) -DayLabel 'sábado'
    Test-FirebirdSweep -Lines $Lines -ExpectedHost $HostName -ExpectedDay ([DayOfWeek]::Sunday) -DayLabel 'domingo'
}

# ============================================================
# ANALISADOR DE DISCOS
# ============================================================

function Analyze-Disks {
    param([string[]]$Lines)

    $blocks = New-Object System.Collections.Generic.List[object]
    $currentDate = $null
    $currentIp = $null

    foreach ($line in $Lines) {

        if ($line -match 'Data/Hora:\s*(?<date>\d{2}/\d{2}/\d{4}\s+\d{1,2}:\d{2}:\d{2},\d+)') {

            $dateText = $Matches['date'].Trim()
            $currentDate = $null

            foreach ($format in @('dd/MM/yyyy H:mm:ss,ff','dd/MM/yyyy HH:mm:ss,ff','dd/MM/yyyy H:mm:ss,f','dd/MM/yyyy HH:mm:ss,f')) {
                try {
                    $currentDate = [datetime]::ParseExact($dateText,$format,$script:CulturePortuguese)
                    break
                } catch {}
            }

            if (-not $currentDate) {
                $dateOnly = [regex]::Match($dateText,'\d{2}/\d{2}/\d{4}')
                if ($dateOnly.Success) {
                    try {
                        $currentDate = [datetime]::ParseExact($dateOnly.Value,'dd/MM/yyyy',$script:CulturePortuguese)
                    } catch {}
                }
            }

            continue
        }

        if ($line -match '(?<ip>\d{1,3}(?:\.\d{1,3}){3})\s*-\s*Armazenamento restante') {

            $currentIp = $Matches['ip']

            if ($currentDate) {
                $blocks.Add([pscustomobject]@{
                    Date=$currentDate
                    IP=$currentIp
                    Lines=(New-Object System.Collections.Generic.List[string])
                })
            }

            continue
        }

        if ($blocks.Count -gt 0 -and $currentIp) {

            $lastBlock = $blocks[$blocks.Count-1]

            if ($line -match '^\s*[CD]:\s*-') {
                $lastBlock.Lines.Add($line.Trim())
            } elseif ($line -match '^\s*-{3,}\s*$') {
                $currentIp = $null
            }
        }
    }

    if ($blocks.Count -eq 0) {
        Add-ResultRow -State Red -Text 'Não foi possível interpretar blocos de armazenamento no arquivo.'
        return
    }

    foreach ($block in $blocks) {

        $dateState = if ($block.Date.Date -eq (Get-Date).Date) {'Green'} else {'Red'}

        Add-ResultRow -State $dateState -Text ("Data/Hora: {0}" -f $block.Date.ToString('dd/MM/yyyy HH:mm:ss,ff'))

        foreach ($diskLine in $block.Lines) {

            $pattern = '^\s*(?<disk>[CD]):\s*-\s*(?<total>[\d\.,]+)\s*GB\s*total\s*/\s*(?<free>[\d\.,]+)\s*GB\s*livre'

            $m = [regex]::Match($diskLine,$pattern,'IgnoreCase')

            if (-not $m.Success) {
                Add-ResultRow -State Red -Text ("{0} - não foi possível interpretar o espaço livre" -f $block.IP)
                continue
            }

            try {
                $total = [double]::Parse($m.Groups['total'].Value,[Globalization.NumberStyles]::Any,$script:CulturePortuguese)
                $free = [double]::Parse($m.Groups['free'].Value,[Globalization.NumberStyles]::Any,$script:CulturePortuguese)

                $percent = if ($total -gt 0) { ($free/$total)*100 } else { 100 }

                # Verde: menos de 90% livre.
                # Vermelho: 90% ou mais livre.

                $state = if ($percent -lt 90) {'Green'} else {'Red'}

                Add-ResultRow -State $state -Text (
                    "{0} - {1} GB livre ({2:N1}% de {3} GB) — disco {4}" -f
                    $block.IP,$m.Groups['free'].Value,$percent,
                    $m.Groups['total'].Value,$m.Groups['disk'].Value
                )

            } catch {
                Add-ResultRow -State Red -Text ("{0} - valor de armazenamento inválido: {1}" -f $block.IP,$diskLine)
            }
        }
    }
}

# ============================================================
# ANALISADOR UNIFICADO DE BACKUPS UCC / USL
# ============================================================

function Analyze-Backup {
    param(
        [string[]]$Lines,
        [array]$Rules
    )

    foreach ($rule in $Rules) {

        $found = $false

        for ($i=0; $i -lt $Lines.Count; $i++) {

            if ($Lines[$i] -notmatch [regex]::Escape($rule.Pattern)) {
                continue
            }

            $date = $null
            $size = $null

            if ($i -gt 0 -and $Lines[$i-1] -match '\[(?<date>\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2}:\d{2})\]') {
                try {
                    $date = [datetime]::ParseExact($Matches['date'],'dd/MM/yyyy HH:mm:ss',$script:CulturePortuguese)
                } catch {}
            }

            if ($i + 1 -lt $Lines.Count -and $Lines[$i+1] -match '^\s*Tamanho\s*:\s*(?<size>.+?)\s*$') {
                $size = $Matches['size'].Trim()
            }

            $expected = (Get-Date).Date.AddDays($rule.DateOffset)

            if ($date -and $date.Date -eq $expected -and $size) {

                Add-ResultRow -State Green -Text (
                    "{0} - {1} - {2}" -f
                    $rule.Label,$date.ToString('dd/MM/yyyy HH:mm:ss'),$size
                )

            } else {
                Add-ResultRow -State Red -Text ("{0} - verificar o backup" -f $rule.Label)
            }

            $found = $true
            break
        }

        if (-not $found) {
            Add-ResultRow -State Red -Text ("{0} - verificar o backup (não encontrado)" -f $rule.Label)
        }
    }
}

# ============================================================
# ANALISADOR BACKUP ARLAB
# ============================================================

function Analyze-ARBackup {
    param([string[]]$Lines)

    $date = $null
    $size = $null

    for ($i=0; $i -lt $Lines.Count; $i++) {

        if ($Lines[$i] -match '^\s*Criado em:\s*(?<date>\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2}:\d{2})') {

            try {
                $date = [datetime]::ParseExact($Matches['date'],'dd/MM/yyyy HH:mm:ss',$script:CulturePortuguese)
            } catch {}

            if ($i + 1 -lt $Lines.Count -and $Lines[$i+1] -match '^\s*Tamanho:\s*(?<size>.+?)\s*$') {
                $size = $Matches['size'].Trim()
            }

            break
        }
    }

    $today = (Get-Date).Date

    if ($date -and $size -and ($date.Date -eq $today -or $date.Date -eq $today.AddDays(-1))) {
        Add-ResultRow -State Green -Text ("BCK AR Realizado - {0} - {1}" -f $date.ToString('dd/MM/yyyy HH:mm:ss'),$size)
    } else {
        Add-ResultRow -State Red -Text 'BCK AR não realizado, verifique!'
    }
}

# ============================================================
# ANALISADOR APLICACOES GESTHOS
# ============================================================

function Analyze-APL {
    param(
        [string[]]$Lines,
        [string]$ServerHint
    )

    $badMessages = @(
        'não possui linhas suficientes para penúltima',
        'não possui linhas suficientes',
        'não foi modificado hoje',
        'não encontrado'
    )

    $count = 0

    foreach ($line in $Lines) {

        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }

        $nameMatch = [regex]::Match($line,'^(?<name>.*?\.txt)')
        $dateMatches = [regex]::Matches($line,'\[(?<date>\d{2}/\d{2}/\d{4})\]')

        if (-not $nameMatch.Success -or $dateMatches.Count -eq 0) {
            Add-ResultRow -State Red -Text ("Linha inválida — Erro no log, verificar{0}" -f $ServerHint)
            $count++
            continue
        }

        $name = [IO.Path]::GetFileName($nameMatch.Groups['name'].Value.Trim())
        $dateText = $dateMatches[0].Groups['date'].Value

        $message = $line.Substring(
            $dateMatches[$dateMatches.Count-1].Index +
            $dateMatches[$dateMatches.Count-1].Length
        ).Trim()

        $date = $null

        try {
            $date = [datetime]::ParseExact($dateText,'dd/MM/yyyy',$script:CulturePortuguese)
        } catch {}

        $hasBadMessage = $false

        foreach ($bad in $badMessages) {
            if ($line.IndexOf($bad,[StringComparison]::OrdinalIgnoreCase) -ge 0) {
                $hasBadMessage = $true
                break
            }
        }

        if ($date -and $date.Date -eq (Get-Date).Date -and -not $hasBadMessage -and -not [string]::IsNullOrWhiteSpace($message)) {

            Add-ResultRow -State Green -Text ("{0} - {1} - {2}" -f $name,$dateText,$message)

        } else {
            Add-ResultRow -State Red -Text ("{0} - Erro no log, verificar{1}" -f $name,$ServerHint)
        }

        $count++
    }

    if ($count -eq 0) {
        Add-ResultRow -State Red -Text 'Nenhuma linha de log válida encontrada.'
    }
}

# ============================================================
# CARREGAR E ANALISAR ARQUIVOS
# ============================================================

function Invoke-LogSelection {
    param(
        [Parameter(Mandatory=$true)]$Definition
    )

    $PainelResultados.Children.Clear()

    $TxtResumo.Text = "Arquivo selecionado: $($Definition.File)"
    $TxtStatus.Text = "Status: lendo $($Definition.File)..."
    $TxtArquivoSelecionado.Text = $Definition.File

    $path = Join-Path -Path $script:LogRoot -ChildPath $Definition.File

    try {

        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Arquivo não encontrado ou sem acesso:`n$path"
        }

        $content = Get-Content -LiteralPath $path -Raw -ErrorAction Stop

        $TxtLog.Text = $content
        $lines = @($content -split "\r?\n")

        Add-ResultHeader -Text ("ANÁLISE: {0}" -f $Definition.Label)

        switch ($Definition.Parser) {

            'REPLICAS' {
                Analyze-Replicas -Lines $lines
            }

            'FIREBIRD_UCC' {
                Analyze-Firebird -Lines $lines -HostName 'SERVFHSFA4B'
            }

            'FIREBIRD_USL' {
                Analyze-Firebird -Lines $lines -HostName 'GESTHOSDB'
            }

            'DISKS' {
                Analyze-Disks -Lines $lines
            }

            'BCK_UCC' {
                Analyze-Backup -Lines $lines -Rules @(
                    [pscustomobject]@{Pattern='BCK_GESTHOS_U_CC-';Label='BCK_GESTHOS_U_CC';DateOffset=-1}
                    [pscustomobject]@{Pattern='BCK_GESTHOS_IMP_U_CC-';Label='BCK_GESTHOS_IMP_U_CC';DateOffset=0}
                    [pscustomobject]@{Pattern='BCK_GESTHOS_UCC_NOHARM-';Label='BCK_GESTHOS_UCC_NOHARM';DateOffset=0}
                    [pscustomobject]@{Pattern='BCK_GESTHOS_LOG_U_CC-';Label='BCK_GESTHOS_LOG_U_CC';DateOffset=0}
                )
            }

            'BCK_USL' {
                Analyze-Backup -Lines $lines -Rules @(
                    [pscustomobject]@{Pattern='Bck_GestHos_Imp_USL-';Label='Bck_GestHos_Imp_USL';DateOffset=-1}
                    [pscustomobject]@{Pattern='Bck_GestHos_USL-';Label='Bck_GestHos_USL';DateOffset=0}
                )
            }

            'AR_BCK' {
                Analyze-ARBackup -Lines $lines
            }

            'APL' {
                $serverHint = switch ($Definition.Key) {
                    'APL_UCC' { ' no 10.0.0.204.' }
                    default { '.' }
                }

                Analyze-APL -Lines $lines -ServerHint $serverHint
            }

            default {
                Add-ResultRow -State Amber -Text 'Não há analisador configurado para este log.'
            }
        }

        $resultCount = $PainelResultados.Children.Count - 1

        $TxtResumo.Text = "Análise concluída para $($Definition.Label). Itens exibidos: $resultCount."
        $TxtStatus.Text = "Status: log carregado e analisado às $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
        $TxtConnection.Text = 'Origem: Compartilhamento de rede'

    } catch {

        $TxtLog.Text = ''

        Add-ResultRow -State Red -Text $_.Exception.Message

        $TxtResumo.Text = 'Falha ao carregar ou analisar o arquivo.'
        $TxtStatus.Text = 'Status: erro ao acessar o log.'
        $TxtConnection.Text = 'Origem: indisponível'

        [System.Windows.MessageBox]::Show(
            $_.Exception.Message,
            'LogViewer — erro ao carregar arquivo',
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        ) | Out-Null
    }
}

# ============================================================
# CRIACAO DINAMICA DOS BOTOES
# TOOLTIP COM DELAY DE 2 SEGUNDOS
# ============================================================

foreach ($definition in $script:LogButtons) {

    $button = New-Object System.Windows.Controls.Button

    $button.Content = $definition.Label
    $button.Margin = '4'
    $button.MinHeight = 43
    $button.ToolTip = $definition.Description

    [System.Windows.Controls.ToolTipService]::SetInitialShowDelay($button,2000)
    [System.Windows.Controls.ToolTipService]::SetShowDuration($button,15000)

    if ($definition.Group -eq 1) {

        $button.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#FFFFFF')
        $button.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#BFC5CE')

        [void]$GridBotoesLinha1.Children.Add($button)

    } else {

        $button.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#E8EBEF')
        $button.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#000000')

        [void]$GridBotoesLinha2.Children.Add($button)
    }

    $capturedDefinition = $definition

    $button.Add_Click({
        Invoke-LogSelection -Definition $capturedDefinition
    }.GetNewClosure())
}

# ============================================================
# COPIAR CONTEUDO DO LOG
# ============================================================

$TxtLog.Add_PreviewMouseLeftButtonDown({

    if (-not [string]::IsNullOrEmpty($TxtLog.Text)) {

        try {

            [System.Windows.Clipboard]::SetText($TxtLog.Text)

            $TxtStatus.Text = 'Status: conteúdo do log copiado para a área de transferência.'

        } catch {

            [System.Windows.MessageBox]::Show(
                "Não foi possível copiar o conteúdo.`n$($_.Exception.Message)",
                'LogViewer',
                [System.Windows.MessageBoxButton]::OK,
                [System.Windows.MessageBoxImage]::Warning
            ) | Out-Null
        }
    }
})

# ============================================================
# LIMPAR RESULTADOS
# ============================================================

$BtnLimparResultados.Add_Click({

    $PainelResultados.Children.Clear()

    $TxtResumo.Text = 'Resultados limpos. Selecione um botão para analisar outro log.'
    $TxtStatus.Text = 'Status: pronto'
})

# ============================================================
# BACKUPS SERVIDOR
# DOWNLOAD E EXECUCAO AUTOMATICA
# ============================================================

$BtnBackupsServidor.Add_Click({

    $url = "https://github.com/analistafhsfa-dev/MonitorBCK/raw/refs/heads/main/MonitorBCK2.0.exe"

    $tempFile = Join-Path $env:TEMP "MonitorBCK2.0_$([guid]::NewGuid().ToString('N')).exe"

    $BtnBackupsServidor.IsEnabled = $false
    $BtnBackupsServidor.Content = "Carregando..."

    $TxtStatus.Text = "Status: baixando Monitor de Backups..."

    $Window.Cursor = [System.Windows.Input.Cursors]::Wait

    try {

        # Compatibilidade TLS com GitHub
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        Invoke-WebRequest -Uri $url -OutFile $tempFile -UseBasicParsing -ErrorAction Stop

        if (-not (Test-Path -LiteralPath $tempFile -PathType Leaf)) {
            throw "Não foi possível localizar o executável baixado."
        }

        if ((Get-Item -LiteralPath $tempFile).Length -eq 0) {
            throw "O arquivo baixado está vazio."
        }

        $TxtStatus.Text = "Status: iniciando Monitor de Backups..."

        $process = Start-Process -FilePath $tempFile -PassThru -ErrorAction Stop

        $TxtStatus.Text = "Status: Monitor de Backups em execução."

        $Window.Cursor = [System.Windows.Input.Cursors]::Arrow

        $timer = New-Object System.Windows.Threading.DispatcherTimer
        $timer.Interval = [TimeSpan]::FromSeconds(2)

        $timer.Add_Tick({

            if ($process.HasExited) {

                $timer.Stop()

                try {

                    $process.Dispose()

                    if (Test-Path -LiteralPath $tempFile) {
                        Remove-Item -LiteralPath $tempFile -Force -ErrorAction Stop
                    }

                    $TxtStatus.Text = "Status: Monitor de Backups encerrado. Arquivo temporário removido."

                } catch {

                    $TxtStatus.Text = "Status: programa encerrado, mas não foi possível remover o arquivo temporário."

                } finally {

                    $BtnBackupsServidor.IsEnabled = $true
                    $BtnBackupsServidor.Content = "Backups Sistemas"
                }
            }

        }.GetNewClosure())

        $timer.Start()

    } catch {

        if (Test-Path -LiteralPath $tempFile) {
            Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
        }

        $Window.Cursor = [System.Windows.Input.Cursors]::Arrow

        $TxtStatus.Text = "Status: erro ao iniciar Monitor de Backups."

        $BtnBackupsServidor.IsEnabled = $true
        $BtnBackupsServidor.Content = "Backups Sistemas"

        [System.Windows.MessageBox]::Show(
            "Não foi possível baixar ou executar o Monitor de Backups.`n`n$($_.Exception.Message)",
            "LogViewer - Backups Servidor",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        ) | Out-Null
    }
})

# ============================================================
# INICIALIZACAO
# ============================================================

if (Test-Path -LiteralPath $script:LogRoot) {

    $TxtConnection.Text = 'Origem: Compartilhamento SGBD 10.0.12.68 - acessível'

} else {

    $TxtConnection.Text = 'Origem: aguardando acesso à rede'
}

$Window.ShowDialog() | Out-Null

# ============================================================
# FIM - LOGVIEWER
# ============================================================