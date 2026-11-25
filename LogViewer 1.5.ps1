#Requires -Version 5.1
# ============================================================
# LOGVIEWER - MONITORAMENTO DE LOGS
# Criado por Guilherme Analista Infra Seg
# ============================================================
$ErrorActionPreference = "Stop"
#Bibliotecas
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
# ============================================================
# DECLARACAO DE BOTOES, CAMINHOS, DATA, ETC.
# ============================================================
$script:LogRoot = '\\10.0.12.68\c$\temp\Logs OS Automatizados\LOGS'
$script:Hoje = (Get-Date).Date
$script:CultureEnglish = [Globalization.CultureInfo]::GetCultureInfo('en-US')
$script:CulturePortuguese = [Globalization.CultureInfo]::GetCultureInfo('pt-BR')
$script:LogButtons = @(
    [pscustomobject]@{Key='APL_UCC';Label='Serviços Gesthos';File='APLGesthos(10.0.0.201).txt';Description='Verificar execução das APL Gesthos UCC (Verificar no servidor 10.0.0.204\temp)';Group=1;Parser='APL'}
    [pscustomobject]@{Key='DISCOS_UCC';Label='Discos Gesthos';File='ArmazenamentoRestante(10.0.0.200-201).txt';Description='Verificar armazenamento discos Gesthos UCC (10.0.0.200/201)';Group=1;Parser='DISKS'}
    [pscustomobject]@{Key='BCK_UCC';Label='Backups Gesthos';File='BCK(10.0.0.226).txt';Description='Backups Gesthos UCC (Verificar no servidor 10.0.0.226\CobianAPL)';Group=1;Parser='BCK_UCC'}
    [pscustomobject]@{Key='FIREBIRD_UCC';Label='Sweep Firebird';File='Firebird(10.0.0.200).txt';Description='Verificação Sweep Firebird (Verificar no servidor 10.0.0.200\firebird.log)';Group=1;Parser='FIREBIRD_UCC'}
    [pscustomobject]@{Key='REPLICAS';Label='Saúde Replicas';File='ReplicasSaude(10.0.0.126-10.0.4.232).txt';Description='Verificação saúde das réplicas (Verificar no servidor 10.0.4.232)';Group=1;Parser='REPLICAS'}
    [pscustomobject]@{Key='APL_USL';Label='Serviços Gesthos';File='APLGesthos(10.0.8.201).txt';Description='Verificar execução das APL Gesthos USL (Verificar no servidor 10.0.8.201\temp)';Group=2;Parser='APL'}
    [pscustomobject]@{Key='APL_WTS';Label='Serviço WhatsApp';File='APLGesthos(10.0.11.251).txt';Description='Verificar execução da APL Whats/Gesthos USL (Verificar no servidor 10.0.11.251\temp)';Group=2;Parser='APL'}
    [pscustomobject]@{Key='DISCOS_USL';Label='Discos Gesthos';File='ArmazenamentoRestanteSL(10.0.8.200-201).txt';Description='Verificar armazenamento discos Gesthos USL (10.0.8.200/201)';Group=2;Parser='DISKS'}
    [pscustomobject]@{Key='BCK_USL';Label='Backups Gesthos';File='BCKGesthosSL(10.0.8.222).txt';Description='Backups Gesthos USL (Verificar no servidor 10.0.8.222)';Group=2;Parser='BCK_USL'}
    [pscustomobject]@{Key='FIREBIRD_USL';Label='Sweep Firebird';File='Firebird(10.0.8.200).txt';Description='Verificação Sweep Firebird (Verificar no servidor 10.0.8.200\firebird.log)';Group=2;Parser='FIREBIRD_USL'}
    [pscustomobject]@{Key='AR_USL';Label='Backup ARLAB';File='BCKArSistmsSL(10.0.8.222).txt';Description='Backups ARLAB USL (Verificar no servidor 10.0.8.222)';Group=2;Parser='AR_BCK'}
)
# ============================================================
# INTERFACE WPF
# ============================================================
[xml]$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="LogViewer" Width="760" Height="840"
        MinWidth="760" MinHeight="840"
		MaxWidth="960" MaxHeight="980"
        WindowStartupLocation="CenterScreen"
        Background="#F3F5F8" Foreground="#252A31"
        FontFamily="Segoe UI">

    <Window.Resources>

        <SolidColorBrush x:Key="BorderColor" Color="#E1E5EB"/>

        <Style TargetType="Button">
            <Setter Property="Foreground" Value="#252A31"/>
            <Setter Property="Background" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#D8DDE5"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="10,7"/>
            <Setter Property="FontSize" Value="11"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="B"
                                Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="7"
                                Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center"
                                              VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="B" Property="Background" Value="#A1E3E3"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="B" Property="Background" Value="#BAE1E3"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Opacity" Value="0.5"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

    </Window.Resources>

    <Grid Margin="14">

        <Grid.RowDefinitions>
            <RowDefinition Height="115"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="32"/>
        </Grid.RowDefinitions>

        <!-- CABECALHO -->
        <Border Grid.Row="0"
                Background="White"
                BorderBrush="#E1E5EB"
                BorderThickness="1"
				CornerRadius="10"
                Padding="20,12"
				MinHeight="100"
                Margin="0,0,0,10">

            <Grid>
                <StackPanel VerticalAlignment="Center">
                    <TextBlock Text="⌕ LogViewer"
                               FontSize="21"
                               FontWeight="Bold"
                               Foreground="#20242B"/>

                    <TextBlock Text="Monitoramento de backups e análise de logs"
                               FontSize="10"
                               Foreground="#7A8492"/>
                </StackPanel>

                <StackPanel Orientation="Horizontal"
                            HorizontalAlignment="Right"
                            VerticalAlignment="Center">

                    <Border Background="#F1F4F7"
                            CornerRadius="6"
                            Padding="9,7"
                            Margin="0,0,8,0">

                        <TextBlock x:Name="TxtConnection"
                                   Text="Acesso aos Backups de Sistemas"
                                   FontSize="10"
                                   Foreground="#525A65"/>
                    </Border>

                    <Button x:Name="BtnBackupsServidor"
                            Content="↗ Abrir Aplicação"
                            Background="#087F91"
                            Foreground="White"
                            BorderBrush="#087F91"/>
                </StackPanel>
            </Grid>
        </Border>

        <!-- SELECAO DE LOGS -->
        <Border Grid.Row="1"
                Background="White"
                BorderBrush="#E1E5EB"
                BorderThickness="1"
                CornerRadius="10"
                Padding="12"
                Margin="0,0,0,10">

            <StackPanel>

                <Grid Margin="0,0,0,8"
      HorizontalAlignment="Stretch">

    <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="Auto"/>
    </Grid.ColumnDefinitions>

    <TextBlock Grid.Column="0"
               Text="MONITORAMENTO"
               FontSize="11"
               FontWeight="Bold"
               Foreground="#454D59"
               VerticalAlignment="Center"
               HorizontalAlignment="Left"/>

    <Border Grid.Column="1"
            Background="#777F80"
            BorderBrush="#E1E5EB"
            BorderThickness="1"
            CornerRadius="8"
            Padding="12,6"
            HorizontalAlignment="Right">

        <StackPanel Orientation="Horizontal">

			<TextBlock x:Name="TxtUCC"
			   Text="UCC"
			   FontSize="10"
			   FontWeight="Bold"
			   Foreground="#FFFFFF"
			   Cursor="Hand"/>

			<TextBlock Text="  |  "
					   FontSize="10"
					   Foreground="#87909D"/>

			<TextBlock x:Name="TxtUSL"
			   Text="USL"
			   FontSize="10"
			   FontWeight="Bold"
			   Foreground="#B4F0EF"
			   Cursor="Hand"/>

		</StackPanel>

    </Border>

</Grid>

                <UniformGrid x:Name="GridBotoesLinha1"
                             Rows="1"
                             Columns="5"
                             Margin="0,0,0,5"/>

                <UniformGrid x:Name="GridBotoesLinha2"
                             Rows="1"
                             Columns="6"/>

            </StackPanel>
        </Border>

        <!-- RESULTADOS -->
        <Border Grid.Row="2"
                Background="White"
                BorderBrush="#E1E5EB"
                BorderThickness="1"
                CornerRadius="10"
                Padding="14"
                Margin="0,0,0,10">

            <Grid>

                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <!-- TITULO -->
                <Grid Grid.Row="0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>

                    <StackPanel>
                        <TextBlock Text="RESULTADOS DA ANÁLISE"
                                   FontSize="13"
                                   FontWeight="Bold"
                                   Foreground="#252A31"/>

                        <TextBlock x:Name="TxtResumo"
                                   Text="Selecione um monitoramento para iniciar."
                                   FontSize="10"
                                   Foreground="#7A8492"
                                   Margin="0,3,0,0"/>
                    </StackPanel>

                    <Button x:Name="BtnLimparResultados"
                            Grid.Column="1"
                            Content="Limpar resultados"
                            VerticalAlignment="Center"/>
                </Grid>

                <!-- ARQUIVO SELECIONADO -->
                <Border Grid.Row="1"
                        Background="#F4F7FA"
                        BorderBrush="#E3E8EE"
                        BorderThickness="1"
                        CornerRadius="7"
                        Padding="9"
                        Margin="0,12,0,10">

                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>

                        <StackPanel VerticalAlignment="Center">
                            <TextBlock Text="ARQUIVO MONITORADO"
                                       FontSize="9"
                                       FontWeight="Bold"
                                       Foreground="#7A8492"/>

                            <TextBlock x:Name="TxtArquivoSelecionado"
                                       Text="Nenhum arquivo selecionado"
                                       FontSize="11"
                                       FontWeight="SemiBold"
                                       Foreground="#343A43"
                                       Margin="0,3,0,0"/>
                        </StackPanel>

                        <Button x:Name="BtnAbrirLog"
                                Grid.Column="1"
                                Content="↗ Abrir log"
                                Background="#087F91"
                                Foreground="White"
                                BorderBrush="#087F91"
                                Padding="14,8"
                                VerticalAlignment="Center"
                                IsEnabled="False"
                                ToolTip="Abrir arquivo selecionado no Bloco de Notas"/>

                    </Grid>
                </Border>

                <!-- PAINEL DE RESULTADOS -->
                <ScrollViewer Grid.Row="2"
                              VerticalScrollBarVisibility="Auto"
                              HorizontalScrollBarVisibility="Disabled">

                    <StackPanel x:Name="PainelResultados"/>

                </ScrollViewer>

            </Grid>
        </Border>

        <!-- RODAPE -->
        <Border Grid.Row="3"
                Background="#E9EDF2"
                CornerRadius="6"
                Padding="9,5">

            <Grid>
                <TextBlock x:Name="TxtStatus"
                           Text="Status: Pronto"
                           FontSize="10"
                           Foreground="#555D68"/>

                <TextBlock Text="Desenv. Guilherme Augusto   | v1.5"
                           HorizontalAlignment="Right"
                           FontSize="10"
                           Foreground="#7A828D"/>
            </Grid>
        </Border>

    </Grid>
</Window>
"@
# ABERTURA XAML
$Reader = New-Object System.Xml.XmlNodeReader $Xaml
$Window = [Windows.Markup.XamlReader]::Load($Reader)
# Referencias dos controles
$GridBotoesLinha1 = $Window.FindName('GridBotoesLinha1')
$GridBotoesLinha2 = $Window.FindName('GridBotoesLinha2')
$TxtArquivoSelecionado = $Window.FindName('TxtArquivoSelecionado')
$PainelResultados = $Window.FindName('PainelResultados')
$TxtStatus = $Window.FindName('TxtStatus')
$TxtResumo = $Window.FindName('TxtResumo')
$TxtConnection = $Window.FindName('TxtConnection')
$BtnLimparResultados = $Window.FindName('BtnLimparResultados')
$BtnBackupsServidor = $Window.FindName('BtnBackupsServidor')
$BtnAbrirLog = $Window.FindName('BtnAbrirLog')
$script:SelectedLogPath = $null
$script:UccButtons = @()
$script:UslButtons = @()
$TxtUCC = $Window.FindName("TxtUCC")
$TxtUSL = $Window.FindName("TxtUSL")
# ============================================================
# FUNCOES VISUAIS
# ============================================================
# VISUAL DO CAMPO RESULTADO
function Add-ResultRow {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Text,
        [ValidateSet('Green','Red','Amber','Gray')]
        [string]$State = 'Gray'
    )
    $config = @{
        Green = @{
            Color = '#16834A'
            Background = '#EDF8F1'
            Border = '#CDEBD7'
            Label = 'SUCESSO'
            Symbol = '✓'
        }
        Red = @{
            Color = '#C73535'
            Background = '#FFF1F0'
            Border = '#F4D1CE'
            Label = 'ERRO'
            Symbol = '!'
        }
        Amber = @{
            Color = '#B7791F'
            Background = '#FFF8E8'
            Border = '#F1DFB5'
            Label = 'ATENÇÃO'
            Symbol = '!'
        }
        Gray = @{
            Color = '#687386'
            Background = '#F3F5F8'
            Border = '#E1E5EB'
            Label = 'INFORMAÇÃO'
            Symbol = 'i'
        }
    }
    $style = $config[$State]
    $card = New-Object System.Windows.Controls.Border
    $card.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString($style.Background)
    $card.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($style.Border)
    $card.BorderThickness = [System.Windows.Thickness]::new(1)
    $card.CornerRadius = [System.Windows.CornerRadius]::new(7)
    $card.Padding = '11,8'
    $card.Margin = '0,0,0,7'
    $grid = New-Object System.Windows.Controls.Grid
    $grid.ColumnDefinitions.Add(
        (New-Object System.Windows.Controls.ColumnDefinition -Property @{Width='32'})
    )
    $grid.ColumnDefinitions.Add(
        (New-Object System.Windows.Controls.ColumnDefinition -Property @{Width='*'})
    )
    $grid.ColumnDefinitions.Add(
        (New-Object System.Windows.Controls.ColumnDefinition -Property @{Width='Auto'})
    )
    $indicator = New-Object System.Windows.Controls.Border
    $indicator.Width = 23
    $indicator.Height = 23
    $indicator.CornerRadius = [System.Windows.CornerRadius]::new(12)
    $indicator.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString($style.Color)
    $indicator.VerticalAlignment = 'Center'
    $indicator.HorizontalAlignment = 'Left'
    $symbol = New-Object System.Windows.Controls.TextBlock
    $symbol.Text = $style.Symbol
    $symbol.Foreground = [System.Windows.Media.Brushes]::White
    $symbol.FontWeight = 'Bold'
    $symbol.FontSize = 13
    $symbol.HorizontalAlignment = 'Center'
    $symbol.VerticalAlignment = 'Center'
    $indicator.Child = $symbol
    [System.Windows.Controls.Grid]::SetColumn($indicator,0)
    [void]$grid.Children.Add($indicator)
    $description = New-Object System.Windows.Controls.TextBlock
    $description.Text = $Text
    $description.FontSize = 11
    $description.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#343A43')
    $description.TextWrapping = 'Wrap'
    $description.VerticalAlignment = 'Center'
    $description.Margin = '5,0,8,0'
    [System.Windows.Controls.Grid]::SetColumn($description,1)
    [void]$grid.Children.Add($description)
    $status = New-Object System.Windows.Controls.TextBlock
    $status.Text = $style.Label
    $status.FontSize = 9
    $status.FontWeight = 'Bold'
    $status.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($style.Color)
    $status.VerticalAlignment = 'Center'
    $status.Margin = '8,0,2,0'
    [System.Windows.Controls.Grid]::SetColumn($status,2)
    [void]$grid.Children.Add($status)
    $card.Child = $grid
    [void]$PainelResultados.Children.Add($card)
}
#CABECALHO
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
# ALERTA PARA LOGS CRIADOS SOMENTE SEGUNDA
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
# CONFIGURAR LOGS QUE SAO COLETADOS UM DIA ANTERIOR
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
# CONFIGURACAO LOG FIREBIRD - AJUSTE PARA BUSCAR SAB E DOM
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
# CONFIGURACAO LOG FIREBIRD - AJUSTE PARA VERIFICAR SE O SWEEP É ENCONTRADO NO TXT
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
    $lines = @($content -split "\r?\n")
    # Guarda o arquivo atualmente selecionado
    $script:SelectedLogPath = $path
    # Atualiza interface
    $TxtArquivoSelecionado.Text = $Definition.File
    $BtnAbrirLog.IsEnabled = $true
    # Continua a análise normalmente
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
        $TxtConnection.Text = 'Acesso aos Backups de Sistemas'
    } catch {
        $TxtLog.Text = ''
        Add-ResultRow -State Red -Text $_.Exception.Message
        $TxtResumo.Text = 'Falha ao carregar ou analisar o arquivo.'
        $TxtStatus.Text = 'Status: erro ao acessar o log.'
        $TxtConnection.Text = 'Acesso aos Backups de Sistemas'
		$script:SelectedLogPath = $null
		$BtnAbrirLog.IsEnabled = $false
		$TxtArquivoSelecionado.Text = 'Arquivo indisponível'
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
# TOOLTIP(COMENTARIO AO PASSAR O MOUSE) COM DELAY DE 2 SEGUNDOS
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
        $button.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#F5F5F5')
        $script:UccButtons += $button
        [void]$GridBotoesLinha1.Children.Add($button)
    } else {
        $button.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#EFFFFF')
        $button.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#EBEBEB')
        $script:UslButtons += $button
        [void]$GridBotoesLinha2.Children.Add($button)
    }
    $capturedDefinition = $definition
    $button.Add_Click({
        Invoke-LogSelection -Definition $capturedDefinition
    }.GetNewClosure())
}
# ============================================================
# INTERACAO UCC / USL
# ============================================================
# UCC - Linha 1
$TxtUCC.Add_MouseEnter({
    foreach ($button in $script:UccButtons) {
        $button.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#DCEBFA')
        $button.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#8CB9E8')
    }
})
$TxtUCC.Add_MouseLeave({
    foreach ($button in $script:UccButtons) {
        $button.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#FFFFFF')
        $button.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#F5F5F5')
    }
})
# USL - Linha 2
$TxtUSL.Add_MouseEnter({
    foreach ($button in $script:UslButtons) {
        $button.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#C8EEEE')
        $button.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#8BD8D5')
    }
})
$TxtUSL.Add_MouseLeave({
    foreach ($button in $script:UslButtons) {
        $button.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#EFFFFF')
        $button.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#EBEBEB')
    }
})
# ============================================================
# COPIAR CONTEUDO DO LOG
# ============================================================
$BtnAbrirLog.Add_Click({
    try {
        if (-not $script:SelectedLogPath -or
            -not (Test-Path -LiteralPath $script:SelectedLogPath -PathType Leaf)) {
            throw "Nenhum arquivo de log disponível para abrir."
        }
        Start-Process -FilePath "notepad.exe" `
            -ArgumentList ('"{0}"' -f $script:SelectedLogPath) `
            -ErrorAction Stop
    }
    catch {
        [System.Windows.MessageBox]::Show(
            $_.Exception.Message,
            'LogViewer - Abrir log',
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Warning
        ) | Out-Null
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
# BACKUPS SISTEMAS 
# DOWNLOAD E EXECUCAO AUTOMATICA - BAIXA DO GITHUB
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
                    $BtnBackupsServidor.Content = "↗ Abrir Aplicação"
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
        $BtnBackupsServidor.Content = "↗ Abrir Aplicação"
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
    $TxtConnection.Text = 'Acesso aos Backups de Sistemas'
} else {
    $TxtConnection.Text = 'Acesso aos Backups de Sistemas'
}
$Window.ShowDialog() | Out-Null
