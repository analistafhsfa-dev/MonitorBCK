```powershell
# ============================================================
# MONITOR DE BACKUPS
# PowerShell + WPF
# Sem C#
#
# Criado por Guilherme Analista Infra Seg
# ============================================================

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# ============================================================
# CONFIGURAÇÕES
# ============================================================

$ErrorActionPreference = "Stop"

# Sistemas monitorados
$SistemasFixos = @(
    "ARSistemas",
    "CCIH",
    "DES",
    "MedWare",
    "Nasajon",
    "PathControl",
    "Pixeon Aurora",
    "Pixeon Database",
    "Prodabel",
    "Senior VetorRH",
    "Senior EDocs"
)

# Sistemas que aparecem somente na segunda-feira
$SistemasSegunda = @(
    "Senior Glassfish",
    "Senior",
    "Senior Teste"
)

# Mapeamento dos servidores
$Servidores = @{
    "10.0.0.233"  = "Servidor Backup"
    "10.0.12.68"  = "Servidor SGBD"
}

# ============================================================
# XAML
# ============================================================

[xml]$Xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Monitor de Backups"
    Width="1000"
    Height="780"
    MinWidth="850"
    MinHeight="650"
    WindowStartupLocation="CenterScreen"
    Background="#1E1E1E"
    Foreground="#FFFFFF">

    <Window.Resources>

        <!-- Fundo dos controles -->
        <SolidColorBrush x:Key="PanelBrush" Color="#252526"/>
        <SolidColorBrush x:Key="PanelLightBrush" Color="#2D2D30"/>
        <SolidColorBrush x:Key="BorderBrushCustom" Color="#3F3F46"/>
        <SolidColorBrush x:Key="TextSecondary" Color="#BDBDBD"/>

        <!-- ScrollBar -->
        <Style TargetType="ScrollBar">
            <Setter Property="Width" Value="12"/>
        </Style>

        <!-- TextBox -->
        <Style TargetType="TextBox">
            <Setter Property="Background" Value="#252526"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#3F3F46"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="8"/>
            <Setter Property="FontSize" Value="13"/>
        </Style>

        <!-- Botão -->
        <Style TargetType="Button">
            <Setter Property="Background" Value="#333337"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#555555"/>
            <Setter Property="Padding" Value="12,6"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>

    </Window.Resources>

    <Grid Margin="15">

        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- ================================================= -->
        <!-- CABEÇALHO -->
        <!-- ================================================= -->

        <Border
            Grid.Row="0"
            Background="#252526"
            CornerRadius="5"
            Padding="15"
            Margin="0,0,0,12">

            <Grid>

                <StackPanel>

                    <TextBlock
                        Text="MONITOR DE BACKUPS"
                        FontSize="23"
                        FontWeight="Bold"/>

                    <TextBlock
                        Text="Análise automática do relatório de backups"
                        FontSize="12"
                        Foreground="#BDBDBD"
                        Margin="0,4,0,0"/>

                </StackPanel>

            </Grid>

        </Border>

        <!-- ================================================= -->
        <!-- ÁREA DE COLAGEM -->
        <!-- ================================================= -->

        <Border
            Grid.Row="1"
            Background="#252526"
            BorderBrush="#3F3F46"
            BorderThickness="1"
            CornerRadius="5"
            Padding="12"
            Margin="0,0,0,10">

            <Grid>

                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="125"/>
                </Grid.RowDefinitions>

                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <TextBlock
                    Grid.Row="0"
                    Text="COLE AQUI O RELATÓRIO"
                    FontSize="13"
                    FontWeight="Bold"
                    Margin="0,0,0,8"/>

                <StackPanel
                    Grid.Row="0"
                    Grid.Column="1"
                    Orientation="Horizontal">

                    <Button
                        x:Name="BtnColar"
                        Content="Colar"
                        Width="80"
                        Height="30"
                        Margin="5,0,0,0"/>

                    <Button
                        x:Name="BtnLimpar"
                        Content="Limpar"
                        Width="80"
                        Height="30"
                        Margin="5,0,0,0"/>

                </StackPanel>

                <TextBox
                    x:Name="TxtRelatorio"
                    Grid.Row="1"
                    Grid.ColumnSpan="2"
                    AcceptsReturn="True"
                    TextWrapping="NoWrap"
                    VerticalScrollBarVisibility="Auto"
                    HorizontalScrollBarVisibility="Auto"
                    VerticalContentAlignment="Top"
                    FontFamily="Consolas"
                    FontSize="12"/>

            </Grid>

        </Border>

        <!-- ================================================= -->
        <!-- SERVIDOR -->
        <!-- ================================================= -->

        <Border
            Grid.Row="2"
            Background="#252526"
            BorderBrush="#3F3F46"
            BorderThickness="1"
            CornerRadius="5"
            Padding="12"
            Margin="0,0,0,10">

            <Grid>

                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <TextBlock
                    Text="SERVIDOR:"
                    FontWeight="Bold"
                    FontSize="13"
                    VerticalAlignment="Center"/>

                <TextBlock
                    x:Name="TxtServidor"
                    Grid.Column="1"
                    Text="Aguardando relatório..."
                    Margin="15,0,0,0"
                    FontSize="14"
                    FontWeight="Bold"
                    Foreground="#BDBDBD"
                    VerticalAlignment="Center"/>

            </Grid>

        </Border>

        <!-- ================================================= -->
        <!-- LISTA DE BACKUPS -->
        <!-- ================================================= -->

        <Border
            Grid.Row="3"
            Background="#252526"
            BorderBrush="#3F3F46"
            BorderThickness="1"
            CornerRadius="5"
            Padding="12">

            <Grid>

                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="230"/>
                    <ColumnDefinition Width="35"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <TextBlock
                    Grid.Row="0"
                    Grid.Column="0"
                    Text="SISTEMA"
                    FontWeight="Bold"
                    Foreground="#BDBDBD"
                    Margin="5,0,0,10"/>

                <TextBlock
                    Grid.Row="0"
                    Grid.Column="1"
                    Text="LED"
                    FontWeight="Bold"
                    Foreground="#BDBDBD"
                    HorizontalAlignment="Center"
                    Margin="0,0,0,10"/>

                <TextBlock
                    Grid.Row="0"
                    Grid.Column="2"
                    Text="STATUS"
                    FontWeight="Bold"
                    Foreground="#BDBDBD"
                    Margin="10,0,0,10"/>

                <ScrollViewer
                    x:Name="ScrollBackups"
                    Grid.Row="1"
                    Grid.ColumnSpan="3"
                    VerticalScrollBarVisibility="Auto">

                    <StackPanel
                        x:Name="PainelBackups"/>

                </ScrollViewer>

            </Grid>

        </Border>

        <!-- ================================================= -->
        <!-- STATUS -->
        <!-- ================================================= -->

        <Border
            Grid.Row="4"
            Background="#252526"
            Padding="8"
            Margin="0,10,0,0">

            <Grid>

                <TextBlock
                    x:Name="TxtStatus"
                    Text="Status: Aguardando relatório..."
                    Foreground="#BDBDBD"
                    FontSize="12"/>

                <TextBlock
                    Text="PowerShell + WPF"
                    HorizontalAlignment="Right"
                    Foreground="#666666"
                    FontSize="11"/>

            </Grid>

        </Border>

    </Grid>

</Window>
"@

# ============================================================
# CARREGAMENTO DA JANELA
# ============================================================

$Reader = New-Object System.Xml.XmlNodeReader $Xaml
$Window = [Windows.Markup.XamlReader]::Load($Reader)

# Recupera controles pelo Name
$TxtRelatorio   = $Window.FindName("TxtRelatorio")
$BtnColar       = $Window.FindName("BtnColar")
$BtnLimpar      = $Window.FindName("BtnLimpar")
$TxtServidor    = $Window.FindName("TxtServidor")
$PainelBackups  = $Window.FindName("PainelBackups")
$TxtStatus      = $Window.FindName("TxtStatus")

# ============================================================
# FUNÇÃO - CRIAR LED
# ============================================================

function New-Led
{
    param(
        [string]$Cor = "#666666"
    )

    $Ellipse = New-Object System.Windows.Shapes.Ellipse

    $Ellipse.Width = 16
    $Ellipse.Height = 16
    $Ellipse.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString($Cor)
    $Ellipse.Stroke = [System.Windows.Media.Brushes]::Black
    $Ellipse.StrokeThickness = 1
    $Ellipse.HorizontalAlignment = "Center"
    $Ellipse.VerticalAlignment = "Center"

    return $Ellipse
}

# ============================================================
# FUNÇÃO - ATUALIZAR LED
# ============================================================

function Set-Led
{
    param(
        [System.Windows.Shapes.Ellipse]$Led,
        [string]$Cor
    )

    $Led.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString($Cor)
}

# ============================================================
# FUNÇÃO - CRIAR LINHA DO SISTEMA
# ============================================================

function New-SystemRow
{
    param(
        [string]$Nome
    )

    $Grid = New-Object System.Windows.Controls.Grid

    $Grid.Margin = "0,1,0,1"

    $Grid.Height = 35

    $Grid.ColumnDefinitions.Add(
        (New-Object System.Windows.Controls.ColumnDefinition)
    )

    $Grid.ColumnDefinitions[0].Width = "230"

    $Grid.ColumnDefinitions.Add(
        (New-Object System.Windows.Controls.ColumnDefinition)
    )

    $Grid.ColumnDefinitions[1].Width = "35"

    $Grid.ColumnDefinitions.Add(
        (New-Object System.Windows.Controls.ColumnDefinition)
    )

    $Grid.ColumnDefinitions[2].Width = "*"

    # --------------------------------------------------------
    # Nome
    # --------------------------------------------------------

    $TxtNome = New-Object System.Windows.Controls.TextBlock

    $TxtNome.Text = $Nome
    $TxtNome.FontSize = 13
    $TxtNome.VerticalAlignment = "Center"
    $TxtNome.Margin = "5,0,0,0"

    [System.Windows.Controls.Grid]::SetColumn($TxtNome, 0)

    $Grid.Children.Add($TxtNome) | Out-Null

    # --------------------------------------------------------
    # LED
    # --------------------------------------------------------

    $Led = New-Led "#666666"

    [System.Windows.Controls.Grid]::SetColumn($Led, 1)

    $Grid.Children.Add($Led) | Out-Null

    # --------------------------------------------------------
    # Status
    # --------------------------------------------------------

    $TxtStatusLinha = New-Object System.Windows.Controls.TextBlock

    $TxtStatusLinha.Text = "Aguardando dados..."
    $TxtStatusLinha.FontSize = 12
    $TxtStatusLinha.Foreground = [System.Windows.Media.Brushes]::LightGray
    $TxtStatusLinha.VerticalAlignment = "Center"
    $TxtStatusLinha.Margin = "10,0,0,0"

    [System.Windows.Controls.Grid]::SetColumn(
        $TxtStatusLinha,
        2
    )

    $Grid.Children.Add($TxtStatusLinha) | Out-Null

    # Guarda os objetos dentro do próprio controle
    $Grid.Tag = @{
        Nome   = $Nome
        Led    = $Led
        Status = $TxtStatusLinha
    }

    $PainelBackups.Children.Add($Grid) | Out-Null

    return $Grid
}

# ============================================================
# FUNÇÃO - MONTAR LISTA
# ============================================================

function Initialize-SystemList
{
    $PainelBackups.Children.Clear()

    # Sistemas normais
    foreach ($Sistema in $SistemasFixos)
    {
        New-SystemRow -Nome $Sistema | Out-Null
    }

    # Segunda-feira
    # DayOfWeek:
    # Sunday    = 0
    # Monday    = 1
    # Tuesday   = 2
    # Wednesday = 3
    # Thursday  = 4
    # Friday    = 5
    # Saturday  = 6

    if ((Get-Date).DayOfWeek -eq [DayOfWeek]::Monday)
    {
        foreach ($Sistema in $SistemasSegunda)
        {
            New-SystemRow -Nome $Sistema | Out-Null
        }
    }
}

# ============================================================
# FUNÇÃO - IDENTIFICAR SERVIDOR PELO IP
# ============================================================

function Get-ServerInformation
{
    param(
        [string]$Texto
    )

    # Procura IP depois de \\ em caminhos UNC
    $MatchesIP = [regex]::Matches(
        $Texto,
        '\\\\(?<IP>\d{1,3}(?:\.\d{1,3}){3})'
    )

    foreach ($Match in $MatchesIP)
    {
        $IP = $Match.Groups["IP"].Value

        if ($Servidores.ContainsKey($IP))
        {
            return @{
                IP   = $IP
                Nome = $Servidores[$IP]
            }
        }
    }

    # Caso seja encontrado outro IP
    if ($MatchesIP.Count -gt 0)
    {
        $IP = $MatchesIP[0].Groups["IP"].Value

        return @{
            IP   = $IP
            Nome = "Servidor não cadastrado"
        }
    }

    return $null
}

# ============================================================
# FUNÇÃO - LOCALIZAR DATA/HORA NA LINHA
# ============================================================

function Get-DateTimeFromLine
{
    param(
        [string]$Linha
    )

    # Aceita:
    #
    # 2026-09-21 20;00;40
    # 2026-09-21 20:00:40
    #
    # A hora pode utilizar ; ou :

    $Regex = '(?<Data>\d{4}-\d{2}-\d{2})\s+(?<Hora>\d{2})[:;](?<Minuto>\d{2})[:;](?<Segundo>\d{2})'

    $Match = [regex]::Match(
        $Linha,
        $Regex
    )

    if (-not $Match.Success)
    {
        return $null
    }

    $DataTexto = $Match.Groups["Data"].Value
    $Hora      = $Match.Groups["Hora"].Value
    $Minuto    = $Match.Groups["Minuto"].Value
    $Segundo   = $Match.Groups["Segundo"].Value

    try
    {
        return [datetime]::ParseExact(
            "$DataTexto $Hora`:$Minuto`:$Segundo",
            "yyyy-MM-dd HH:mm:ss",
            [Globalization.CultureInfo]::InvariantCulture
        )
    }
    catch
    {
        return $null
    }
}

# ============================================================
# FUNÇÃO - EXTRAIR REGISTROS DE BACKUP
# ============================================================

function Get-BackupRecords
{
    param(
        [string]$Texto
    )

    $Resultado = @()

    $Linhas = $Texto -split "`r?`n"

    foreach ($Linha in $Linhas)
    {
        $LinhaAtual = $Linha.Trim()

        if ([string]::IsNullOrWhiteSpace($LinhaAtual))
        {
            continue
        }

        # Só processa linhas que começam com Nome:
        if ($LinhaAtual -notmatch '^\s*Nome\s*:')
        {
            continue
        }

        $DataHora = Get-DateTimeFromLine -Linha $LinhaAtual

        if ($null -eq $DataHora)
        {
            continue
        }

        # Remove "Nome:"
        $NomeParte = $LinhaAtual -replace '^\s*Nome\s*:\s*', ''

        # Remove data/hora do final
        $NomeSistema = $NomeParte -replace '\s+\d{4}-\d{2}-\d{2}\s+\d{2}[:;]\d{2}[:;]\d{2}.*$', ''

        $NomeSistema = $NomeSistema.Trim()

        if ([string]::IsNullOrWhiteSpace($NomeSistema))
        {
            continue
        }

        $Resultado += [PSCustomObject]@{
            Nome     = $NomeSistema
            DataHora = $DataHora
            Linha    = $LinhaAtual
        }
    }

    return $Resultado
}

# ============================================================
# FUNÇÃO - ENCONTRAR BACKUP DO SISTEMA
# ============================================================

function Find-BackupForSystem
{
    param(
        [string]$Sistema,
        [array]$Registros
    )

    $Encontrados = @(
        $Registros | Where-Object {
            $_.Nome.Trim() -ieq $Sistema.Trim()
        }
    )

    if ($Encontrados.Count -eq 0)
    {
        return $null
    }

    # Se houver mais de um registro do mesmo sistema,
    # utiliza o backup mais recente.
    return $Encontrados |
        Sort-Object DataHora -Descending |
        Select-Object -First 1
}

# ============================================================
# FUNÇÃO - AVALIAR BACKUP
# ============================================================

function Get-BackupStatus
{
    param(
        [datetime]$DataBackup
    )

    $Hoje = (Get-Date).Date
    $Data  = $DataBackup.Date

    $Diferenca = ($Hoje - $Data).Days

    switch ($Diferenca)
    {
        0
        {
            return @{
                Cor       = "#00C853"
                Texto     = "Backup realizado hoje às {0}" -f $DataBackup.ToString("HH:mm")
                Categoria = "Hoje"
            }
        }

        1
        {
            return @{
                Cor       = "#FFD600"
                Texto     = "Backup realizado ontem às {0}" -f $DataBackup.ToString("HH:mm")
                Categoria = "Ontem"
            }
        }

        2
        {
            return @{
                Cor       = "#FF1744"
                Texto     = "Backup realizado anteontem às {0}" -f $DataBackup.ToString("HH:mm")
                Categoria = "Anteontem"
            }
        }

        default
        {
            if ($Diferenca -gt 2)
            {
                return @{
                    Cor       = "#AA00FF"
                    Texto     = "Atenção - Verificar o backup"
                    Categoria = "Antigo"
                }
            }

            # Backup com data futura
            return @{
                Cor       = "#FF9800"
                Texto     = "Data do backup posterior à data atual"
                Categoria = "Futuro"
            }
        }
    }
}

# ============================================================
# FUNÇÃO - PROCESSAR RELATÓRIO
# ============================================================

function Process-Report
{
    param(
        [string]$Texto
    )

    if ([string]::IsNullOrWhiteSpace($Texto))
    {
        $TxtServidor.Text = "Aguardando relatório..."
        $TxtServidor.Foreground = [System.Windows.Media.Brushes]::Gray

        Initialize-SystemList

        $TxtStatus.Text = "Status: Aguardando relatório..."

        return
    }

    # --------------------------------------------------------
    # SERVIDOR
    # --------------------------------------------------------

    $ServidorInfo = Get-ServerInformation -Texto $Texto

    if ($null -ne $ServidorInfo)
    {
        $TxtServidor.Text = "$($ServidorInfo.Nome) - $($ServidorInfo.IP)"
        $TxtServidor.Foreground = [System.Windows.Media.Brushes]::White
    }
    else
    {
        $TxtServidor.Text = "Servidor não identificado"
        $TxtServidor.Foreground = [System.Windows.Media.Brushes]::Orange
    }

    # --------------------------------------------------------
    # REGISTROS
    # --------------------------------------------------------

    $Registros = @(Get-BackupRecords -Texto $Texto)

    # --------------------------------------------------------
    # ATUALIZA CADA LINHA
    # --------------------------------------------------------

    $Total = 0
    $Hoje = 0
    $Ontem = 0
    $Anteontem = 0
    $Antigos = 0
    $NaoEncontrados = 0

    foreach ($Controle in $PainelBackups.Children)
    {
        if ($null -eq $Controle.Tag)
        {
            continue
        }

        $Dados = $Controle.Tag

        $Sistema = $Dados.Nome
        $Led = $Dados.Led
        $Status = $Dados.Status

        $Backup = Find-BackupForSystem `
            -Sistema $Sistema `
            -Registros $Registros

        if ($null -eq $Backup)
        {
            Set-Led -Led $Led -Cor "#666666"

            $Status.Text = "Backup não localizado no relatório"
            $Status.Foreground = [System.Windows.Media.Brushes]::Gray

            $NaoEncontrados++

            continue
        }

        $Avaliacao = Get-BackupStatus `
            -DataBackup $Backup.DataHora

        Set-Led `
            -Led $Led `
            -Cor $Avaliacao.Cor

        $Status.Text = $Avaliacao.Texto

        switch ($Avaliacao.Categoria)
        {
            "Hoje"
            {
                $Status.Foreground = [System.Windows.Media.Brushes]::LightGreen
                $Hoje++
            }

            "Ontem"
            {
                $Status.Foreground = [System.Windows.Media.Brushes]::Yellow
                $Ontem++
            }

            "Anteontem"
            {
                $Status.Foreground = [System.Windows.Media.Brushes]::Red
                $Anteontem++
            }

            "Antigo"
            {
                $Status.Foreground = [System.Windows.Media.Brushes]::Violet
                $Antigos++
            }

            "Futuro"
            {
                $Status.Foreground = [System.Windows.Media.Brushes]::Orange
            }
        }

        $Total++
    }

    # --------------------------------------------------------
    # STATUS GERAL
    # --------------------------------------------------------

    $DataProcessamento = Get-Date -Format "dd/MM/yyyy HH:mm:ss"

    $TxtStatus.Text =
        "Status: $Total backup(s) localizado(s) | " +
        "Hoje: $Hoje | " +
        "Ontem: $Ontem | " +
        "Anteontem: $Anteontem | " +
        "Antigos: $Antigos | " +
        "Não localizado: $NaoEncontrados | " +
        "Processado: $DataProcessamento"
}

# ============================================================
# EVENTO - TEXTCHANGED
# ============================================================

$script:TimerProcessamento = New-Object System.Windows.Threading.DispatcherTimer

$script:TimerProcessamento.Interval =
    [TimeSpan]::FromMilliseconds(350)

$script:TimerProcessamento.Add_Tick({

    $script:TimerProcessamento.Stop()

    Process-Report -Texto $TxtRelatorio.Text
})

$TxtRelatorio.Add_TextChanged({

    # Sempre que o conteúdo mudar, reinicia o timer.
    # Isso evita processar o relatório dezenas de vezes
    # durante uma colagem grande.

    $script:TimerProcessamento.Stop()
    $script:TimerProcessamento.Start()
})

# ============================================================
# BOTÃO COLAR
# ============================================================

$BtnColar.Add_Click({

    try
    {
        if ([System.Windows.Clipboard]::ContainsText())
        {
            $TxtRelatorio.Text =
                [System.Windows.Clipboard]::GetText()

            $TxtRelatorio.Focus()

            $TxtRelatorio.CaretIndex =
                $TxtRelatorio.Text.Length
        }
        else
        {
            [System.Windows.MessageBox]::Show(
                "A área de transferência não contém texto.",
                "Monitor de Backups",
                "OK",
                "Information"
            )
        }
    }
    catch
    {
        [System.Windows.MessageBox]::Show(
            "Não foi possível acessar a área de transferência.`n`n$($_.Exception.Message)",
            "Erro",
            "OK",
            "Error"
        )
    }
})

# ============================================================
# BOTÃO LIMPAR
# ============================================================

$BtnLimpar.Add_Click({

    $script:TimerProcessamento.Stop()

    $TxtRelatorio.Clear()

    Initialize-SystemList

    $TxtServidor.Text = "Aguardando relatório..."
    $TxtServidor.Foreground =
        [System.Windows.Media.Brushes]::Gray

    $TxtStatus.Text =
        "Status: Aguardando relatório..."

    $TxtRelatorio.Focus()
})

# ============================================================
# CTRL + V
# ============================================================

$TxtRelatorio.Add_PreviewKeyDown({

    param($Sender, $EventArgs)

    if (
        $EventArgs.Key -eq
        [System.Windows.Input.Key]::V -and
        (
            [System.Windows.Input.Keyboard]::IsKeyDown(
                [System.Windows.Input.Key]::LeftCtrl
            ) -or
            [System.Windows.Input.Keyboard]::IsKeyDown(
                [System.Windows.Input.Key]::RightCtrl
            )
        )
    )
    {
        # O TextBox já possui suporte normal ao Ctrl+V.
        # O evento TextChanged cuidará do processamento.
    }
})

# ============================================================
# INICIALIZAÇÃO
# ============================================================

Initialize-SystemList

$TxtRelatorio.Focus()

# ============================================================
# EXIBIR
# ============================================================

$Window.ShowDialog() | Out-Null
```
