# ============================================================
# MONITOR DE BACKUPS 1.5
# Criado por Guilherme Analista Infra Seg
# ============================================================

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$ErrorActionPreference = "Stop"

# ============================================================
# Declaracao dos sistemas\pastas
# ============================================================

# Sistemas principais
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

# Para buscar somente segunda-feira
$SistemasSegunda = @(
    "Senior Glassfish",
    "Senior",
    "Senior Teste"
)

# Sistemas que aparecem somente no servidor 10.0.12.68
$SistemasSGBD = @(
    "ARSistemas USL",
    "Prodabel USL"
)

# ============================================================
# SERVIDORES
# ============================================================

$Servidores = @{
    "10.0.0.233" = "Servidor Backup"
    "10.0.12.68" = "Servidor SGBD"
}

# ============================================================
# MAPEAMENTO DOS SISTEMAS
# ============================================================

$MapeamentoSistemas = @{
    "arsistemas"       = "ARSistemas"
    "ccih"              = "CCIH"
    "des"               = "DES"
    "medware"           = "MedWare"
    "nasajon"           = "Nasajon"
    "nasajon-sql"       = "Nasajon"
    "pathcontrol"       = "PathControl"
    "pathocontrol"      = "PathControl"
    "pixeon aurora"     = "Pixeon Aurora"
    "pixeon database"   = "Pixeon Database"
    "prodabel"          = "Prodabel"
    "prodabel sl"       = "Prodabel USL"
    "senior vetorhr"    = "Senior VetorRH"
    "senior edocs"      = "Senior EDocs"
    "senior glassfish"  = "Senior Glassfish"
    "senior"            = "Senior"
    "senior teste"      = "Senior Teste"
}

# ============================================================
# XAML - INTERFACE DARK ENTERPRISE
# ============================================================

[xml]$Xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Monitor de Backups | Infraestrutura"
    Width="900"
    Height="850"
    MinWidth="900"
    MinHeight="700"
    WindowStartupLocation="CenterScreen"
    Background="#101827"
    Foreground="#E5EAF2"
    FontFamily="Segoe UI">

    <Window.Resources>

        <!-- CORES -->
        <SolidColorBrush x:Key="BackgroundBrush" Color="#101827"/>
        <SolidColorBrush x:Key="PanelBrush" Color="#182437"/>
        <SolidColorBrush x:Key="PanelLightBrush" Color="#202F45"/>
        <SolidColorBrush x:Key="BorderBrushCustom" Color="#2B3C53"/>
        <SolidColorBrush x:Key="AccentBrush" Color="#19B5C5"/>
        <SolidColorBrush x:Key="TextSecondary" Color="#91A2B8"/>

        <!-- BOTAO PADRAO -->
        <Style x:Key="ActionButton" TargetType="Button">

            <Setter Property="Background" Value="#263950"/>
            <Setter Property="Foreground" Value="#EAF2FA"/>
            <Setter Property="BorderBrush" Value="#354D68"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Height" Value="38"/>
            <Setter Property="MinWidth" Value="105"/>
            <Setter Property="Padding" Value="16,0"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Margin" Value="4,0,0,0"/>

            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">

                        <Border
                            x:Name="ButtonBorder"
                            Background="{TemplateBinding Background}"
                            BorderBrush="{TemplateBinding BorderBrush}"
                            BorderThickness="{TemplateBinding BorderThickness}"
                            CornerRadius="6"
                            Padding="{TemplateBinding Padding}">

                            <ContentPresenter
                                HorizontalAlignment="Center"
                                VerticalAlignment="Center"/>

                        </Border>

                        <ControlTemplate.Triggers>

                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter
                                    TargetName="ButtonBorder"
                                    Property="Background"
                                    Value="#314B68"/>
                                <Setter
                                    TargetName="ButtonBorder"
                                    Property="BorderBrush"
                                    Value="#19B5C5"/>
                            </Trigger>

                            <Trigger Property="IsPressed" Value="True">
                                <Setter
                                    TargetName="ButtonBorder"
                                    Property="Background"
                                    Value="#172A40"/>
                            </Trigger>

                            <Trigger Property="IsEnabled" Value="False">
                                <Setter
                                    TargetName="ButtonBorder"
                                    Property="Opacity"
                                    Value="0.4"/>
                            </Trigger>

                        </ControlTemplate.Triggers>

                    </ControlTemplate>
                </Setter.Value>
            </Setter>

        </Style>

        <!-- BOTAO DE DESTAQUE -->
        <Style
            x:Key="PrimaryButton"
            TargetType="Button"
            BasedOn="{StaticResource ActionButton}">

            <Setter Property="Background" Value="#087F91"/>
            <Setter Property="BorderBrush" Value="#119EAE"/>
            <Setter Property="Foreground" Value="#FFFFFF"/>

        </Style>

        <!-- BOTAO DE LIMPEZA -->
        <Style
            x:Key="DangerButton"
            TargetType="Button"
            BasedOn="{StaticResource ActionButton}">

            <Setter Property="Background" Value="#382B38"/>
            <Setter Property="BorderBrush" Value="#654052"/>
            <Setter Property="Foreground" Value="#F0B7C4"/>

        </Style>

        <!-- TEXTBOX -->
        <Style TargetType="TextBox">

            <Setter Property="Background" Value="#111D2D"/>
            <Setter Property="Foreground" Value="#DCE7F3"/>
            <Setter Property="BorderBrush" Value="#30445E"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="12"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="CaretBrush" Value="#19B5C5"/>
            <Setter Property="SelectionBrush" Value="#087F91"/>

        </Style>

        <!-- SCROLLBAR -->
        <Style TargetType="ScrollBar">
            <Setter Property="Width" Value="10"/>
        </Style>

    </Window.Resources>

    <Grid Margin="20">

        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- ================================================= -->
        <!-- CABECALHO -->
        <!-- ================================================= -->

        <Border
            Grid.Row="0"
            Background="#182437"
            BorderBrush="#2B3C53"
            BorderThickness="1"
            CornerRadius="10"
            Padding="22"
            Margin="0,0,0,15">

            <Grid>

                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <StackPanel VerticalAlignment="Center">

                    <StackPanel Orientation="Horizontal">

                        <Border
                            Width="4"
                            Height="30"
                            Background="#19B5C5"
                            CornerRadius="2"
                            Margin="0,0,12,0"/>

                        <TextBlock
                            Text="MONITOR DE BACKUPS"
                            FontSize="23"
                            FontWeight="Bold"
                            Foreground="#F0F5FC"
                            VerticalAlignment="Center"/>

                    </StackPanel>

                    <TextBlock
                        Text="CENTRAL DE MONITORAMENTO DA INFRAESTRUTURA"
                        FontSize="10"
                        FontWeight="SemiBold"
                        Foreground="#91A2B8"
                        Margin="16,7,0,0"/>

                </StackPanel>

                <Border
                    Grid.Column="1"
                    Background="#123744"
                    BorderBrush="#176477"
                    BorderThickness="1"
                    CornerRadius="6"
                    Padding="14,8"
                    VerticalAlignment="Center">

                    <StackPanel Orientation="Horizontal">

                        <Ellipse
                            Width="8"
                            Height="8"
                            Fill="#19B5C5"
                            Margin="0,0,8,0"
                            VerticalAlignment="Center"/>

                        <TextBlock
                            Text="BACKUP MONITOR"
                            FontSize="10"
                            FontWeight="Bold"
                            Foreground="#8DE3E9"
                            VerticalAlignment="Center"/>

                    </StackPanel>

                </Border>

            </Grid>

        </Border>

        <!-- ================================================= -->
        <!-- AREA DO RELATORIO -->
        <!-- ================================================= -->

        <Border
            Grid.Row="1"
            Background="#182437"
            BorderBrush="#2B3C53"
            BorderThickness="1"
            CornerRadius="10"
            Padding="16"
            Margin="0,0,0,12">

            <Grid>

                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="135"/>
                </Grid.RowDefinitions>

                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <StackPanel
                    Grid.Row="0"
                    Orientation="Horizontal"
                    VerticalAlignment="Center">

                    <TextBlock
                        Text="RELATORIO DE BACKUP"
                        FontSize="12"
                        FontWeight="Bold"
                        Foreground="#E5EAF2"
                        VerticalAlignment="Center"/>

                    <TextBlock
                        Text="  |  Entrada de dados"
                        FontSize="11"
                        Foreground="#71869F"
                        VerticalAlignment="Center"/>

                </StackPanel>

                <StackPanel
                    Grid.Row="0"
                    Grid.Column="1"
                    Orientation="Horizontal">

                    <Button
                        x:Name="BtnSGBD"
                        Content="SGBD"
                        Style="{StaticResource ActionButton}"/>

                    <Button
                        x:Name="BtnFILE"
                        Content="FILE"
                        Style="{StaticResource ActionButton}"/>

                    <Button
                        x:Name="BtnColar"
                        Content="COLAR"
                        Style="{StaticResource PrimaryButton}"/>

                    <Button
                        x:Name="BtnLimpar"
                        Content="LIMPAR"
                        Style="{StaticResource DangerButton}"/>

                </StackPanel>

                <TextBox
                    x:Name="TxtRelatorio"
                    Grid.Row="1"
                    Grid.ColumnSpan="2"
                    Margin="0,12,0,0"
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
        <!-- SERVIDOR IDENTIFICADO -->
        <!-- ================================================= -->

        <Border
            Grid.Row="2"
            Background="#182437"
            BorderBrush="#2B3C53"
            BorderThickness="1"
            CornerRadius="10"
            Padding="16"
            Margin="0,0,0,12">

            <Grid>

                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <Border
                    Width="34"
                    Height="34"
                    Background="#123744"
                    CornerRadius="7"
                    VerticalAlignment="Center">

                    <TextBlock
                        Text="▣"
                        FontSize="17"
                        Foreground="#19B5C5"
                        HorizontalAlignment="Center"
                        VerticalAlignment="Center"/>

                </Border>

                <StackPanel
                    Grid.Column="1"
                    Margin="12,0,0,0"
                    VerticalAlignment="Center">

                    <TextBlock
                        Text="SERVIDOR IDENTIFICADO"
                        FontSize="10"
                        FontWeight="Bold"
                        Foreground="#71869F"/>

                    <TextBlock
                        x:Name="TxtServidor"
                        Text="Aguardando relatorio..."
                        FontSize="14"
                        FontWeight="SemiBold"
                        Foreground="#E5EAF2"
                        Margin="0,3,0,0"/>

                </StackPanel>

            </Grid>

        </Border>

        <!-- ================================================= -->
        <!-- LISTA DE BACKUPS -->
        <!-- ================================================= -->

        <Border
            Grid.Row="3"
            Background="#182437"
            BorderBrush="#2B3C53"
            BorderThickness="1"
            CornerRadius="10"
            Padding="16">

            <Grid>

                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>

                <!-- CABECALHO DA LISTA -->

                <Grid
                    Grid.Row="0"
                    Margin="0,0,0,12">

                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="230"/>
                        <ColumnDefinition Width="35"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <TextBlock
                        Grid.Column="0"
                        Text="SISTEMA"
                        FontSize="10"
                        FontWeight="Bold"
                        Foreground="#71869F"
                        Margin="10,0,0,0"/>

                    <TextBlock
                        Grid.Column="1"
                        Text="LED"
                        FontSize="10"
                        FontWeight="Bold"
                        Foreground="#71869F"
                        HorizontalAlignment="Center"/>

                    <TextBlock
                        Grid.Column="2"
                        Text="SITUACAO DO BACKUP"
                        FontSize="10"
                        FontWeight="Bold"
                        Foreground="#71869F"
                        Margin="12,0,0,0"/>

                </Grid>

                <ScrollViewer
                    x:Name="ScrollBackups"
                    Grid.Row="1"
                    VerticalScrollBarVisibility="Auto"
                    HorizontalScrollBarVisibility="Disabled">

                    <StackPanel
                        x:Name="PainelBackups"/>

                </ScrollViewer>

            </Grid>

        </Border>

        <!-- ================================================= -->
        <!-- RODAPE -->
        <!-- ================================================= -->

        <Border
            Grid.Row="4"
            Background="#182437"
            BorderBrush="#2B3C53"
            BorderThickness="1"
            CornerRadius="7"
            Padding="12"
            Margin="0,12,0,0">

            <Grid>

                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <TextBlock
                    x:Name="TxtStatus"
                    Text="Status: Aguardando relatorio..."
                    FontSize="11"
                    Foreground="#91A2B8"
                    VerticalAlignment="Center"/>

                <TextBlock
                    Grid.Column="1"
                    Text="MONITOR DE BACKUPS  |  v1.5"
                    FontSize="10"
                    FontWeight="SemiBold"
                    Foreground="#60748C"
                    VerticalAlignment="Center"/>

            </Grid>

        </Border>

    </Grid>

</Window>
"@

# ============================================================
# CARREGAMENTO DA JANELA
# ============================================================

$Reader =
    New-Object System.Xml.XmlNodeReader $Xaml

$Window =
    [Windows.Markup.XamlReader]::Load($Reader)

# ============================================================
# Local para adicionar Caixas, Botoes
# ============================================================

$TxtRelatorio  =
    $Window.FindName("TxtRelatorio")

$BtnSGBD =
    $Window.FindName("BtnSGBD")

$BtnFILE =
    $Window.FindName("BtnFILE")

$BtnColar =
    $Window.FindName("BtnColar")

$BtnLimpar =
    $Window.FindName("BtnLimpar")

$TxtServidor =
    $Window.FindName("TxtServidor")

$PainelBackups =
    $Window.FindName("PainelBackups")

$TxtStatus =
    $Window.FindName("TxtStatus")

# ============================================================
# FUNCAO - CRIAR LED
# ============================================================

function New-Led
{
    param(
        [string]$Cor = "#666666"
    )

    $Ellipse =
        New-Object System.Windows.Shapes.Ellipse

    $Ellipse.Width =
        16

    $Ellipse.Height =
        16

    $Ellipse.Fill =
        [System.Windows.Media.BrushConverter]::new().ConvertFromString($Cor)

    $Ellipse.Stroke =
        [System.Windows.Media.Brushes]::Black

    $Ellipse.StrokeThickness =
        1

    $Ellipse.HorizontalAlignment =
        "Center"

    $Ellipse.VerticalAlignment =
        "Center"

    return $Ellipse
}

# ============================================================
# FUNCAO - ALTERAR LED
# ============================================================

function Set-Led
{
    param(
        [System.Windows.Shapes.Ellipse]$Led,

        [string]$Cor
    )

    $Led.Fill =
        [System.Windows.Media.BrushConverter]::new().ConvertFromString($Cor)
}

# ============================================================
# FUNCAO - CRIAR LINHA DO SISTEMA
# ============================================================

function New-SystemRow
{
    param(
        [string]$Nome
    )

    $Grid =
        New-Object System.Windows.Controls.Grid

    $Grid.Margin =
        "0,1,0,1"

    $Grid.Height =
        35

    # --------------------------------------------------------
    # COLUNAS
    # --------------------------------------------------------

    $ColunaNome =
        New-Object System.Windows.Controls.ColumnDefinition

    $ColunaNome.Width =
        "230"

    $ColunaLed =
        New-Object System.Windows.Controls.ColumnDefinition

    $ColunaLed.Width =
        "35"

    $ColunaStatus =
        New-Object System.Windows.Controls.ColumnDefinition

    $ColunaStatus.Width =
        "*"

    $Grid.ColumnDefinitions.Add(
        $ColunaNome
    )

    $Grid.ColumnDefinitions.Add(
        $ColunaLed
    )

    $Grid.ColumnDefinitions.Add(
        $ColunaStatus
    )

    # --------------------------------------------------------
    # NOME
    # --------------------------------------------------------

    $TxtNome =
        New-Object System.Windows.Controls.TextBlock

    $TxtNome.Text =
        $Nome

    $TxtNome.FontSize =
        13

    $TxtNome.VerticalAlignment =
        "Center"

    $TxtNome.Margin =
        "5,0,0,0"

    [System.Windows.Controls.Grid]::SetColumn(
        $TxtNome,
        0
    )

    $Grid.Children.Add(
        $TxtNome
    ) | Out-Null

    # --------------------------------------------------------
    # LED
    # --------------------------------------------------------

    $Led =
        New-Led "#666666"

    [System.Windows.Controls.Grid]::SetColumn(
        $Led,
        1
    )

    $Grid.Children.Add(
        $Led
    ) | Out-Null

    # --------------------------------------------------------
    # STATUS
    # --------------------------------------------------------

    $TxtStatusLinha =
        New-Object System.Windows.Controls.TextBlock

    $TxtStatusLinha.Text =
        "Aguardando dados..."

    $TxtStatusLinha.FontSize =
        12

    $TxtStatusLinha.Foreground =
        [System.Windows.Media.Brushes]::LightGray

    $TxtStatusLinha.VerticalAlignment =
        "Center"

    $TxtStatusLinha.Margin =
        "10,0,0,0"

    [System.Windows.Controls.Grid]::SetColumn(
        $TxtStatusLinha,
        2
    )

    $Grid.Children.Add(
        $TxtStatusLinha
    ) | Out-Null

    # --------------------------------------------------------
    # ARMAZENA REFERENCIAS
    # --------------------------------------------------------

    $Grid.Tag = @{
        Nome   = $Nome
        Led    = $Led
        Status = $TxtStatusLinha
    }

    $PainelBackups.Children.Add(
        $Grid
    ) | Out-Null

    return $Grid
}

# ============================================================

function Initialize-SystemList
{
    param(
        [string]$IPServidor
    )

    $PainelBackups.Children.Clear()

    # ========================================================
    # SISTEMAS FIXOS
    # ========================================================

    foreach ($Sistema in $SistemasFixos)
    {
        New-SystemRow `
            -Nome $Sistema |
            Out-Null
    }

    # ========================================================
    # SISTEMAS EXCLUSIVOS DO SGBD
    # ========================================================

    if (
        $IPServidor -eq "10.0.12.68"
    )
    {
        foreach ($Sistema in $SistemasSGBD)
        {
            New-SystemRow `
                -Nome $Sistema |
                Out-Null
        }
    }

    # ========================================================
    # SISTEMAS DE SEGUNDA-FEIRA
    #
    # Somente para o servidor de backup 10.0.0.233
    # ========================================================

    if (
        $IPServidor -eq "10.0.0.233"
    )
    {
        if (
            (Get-Date).DayOfWeek -eq
    		[DayOfWeek]::Wednesday
        )
        {
            foreach ($Sistema in $SistemasSegunda)
            {
                New-SystemRow `
                    -Nome $Sistema |
                    Out-Null
            }
        }
    }
}

# ============================================================
# FUNCAO - IDENTIFICAR SERVIDOR
# ============================================================

function Get-ServerInformation
{
    param(
        [string]$Texto
    )

    # ========================================================
    # PROCURA IP APOS \\
    # ========================================================

    $MatchesIP =
        [regex]::Matches(
            $Texto,
            '\\\\(?<IP>\d{1,3}(?:\.\d{1,3}){3})'
        )

    foreach ($Match in $MatchesIP)
    {
        $IP =
            $Match.Groups["IP"].Value

        if (
            $Servidores.ContainsKey($IP)
        )
        {
            return @{
                IP   = $IP
                Nome = $Servidores[$IP]
            }
        }
    }

    # ========================================================
    # CASO TENHA IP NAO CADASTRADO
    # ========================================================

    if (
        $MatchesIP.Count -gt 0
    )
    {
        $IP =
            $MatchesIP[0].Groups["IP"].Value

        return @{
            IP   = $IP
            Nome = "Servidor nao cadastrado"
        }
    }

    return $null
}

# ============================================================
# FUNCAO - EXTRAIR DATA E HORA DA LINHA NOME
# ============================================================

function Get-DateTimeFromNameLine
{
    param(
        [string]$Linha
    )

    # Aceita:
    #
    # Nome: TERCA-FEIRA 2026-09-22 00;30;06
    #
    # Nome: Backup 2026-09-22 10:19:51
    #
    # O separador de hora pode ser : ou ;

    $Regex =
        '(?<Data>\d{4}-\d{2}-\d{2})\s+' +
        '(?<Hora>\d{2})[:;]' +
        '(?<Minuto>\d{2})[:;]' +
        '(?<Segundo>\d{2})'

    $Match =
        [regex]::Match(
            $Linha,
            $Regex
        )

    if (
        -not $Match.Success
    )
    {
        return $null
    }

    $DataTexto =
        $Match.Groups["Data"].Value

    $Hora =
        $Match.Groups["Hora"].Value

    $Minuto =
        $Match.Groups["Minuto"].Value

    $Segundo =
        $Match.Groups["Segundo"].Value

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
# FUNCAO - EXTRAIR TAMANHO
# ============================================================

function Get-BackupSize
{
    param(
        [string]$Linha
    )

    if (
        $Linha -match
        '^\s*Tamanho\s*:\s*(.+?)\s*$'
    )
    {
        $Tamanho =
            $Matches[1].Trim()

        # ====================================================
        # SEM TAMANHO
        #
        # Exemplos:
        # -
        # vazio
        # -- 
        # ====================================================

        if (
            [string]::IsNullOrWhiteSpace(
                $Tamanho
            )
        )
        {
            return $null
        }

        if (
            $Tamanho -eq "-"
        )
        {
            return $null
        }

        return $Tamanho
    }

    return $null
}

# ============================================================
# FUNCAO - IDENTIFICAR SISTEMA PELO BLOCO
#
# Esta funcao trata:
#
# 10.0.0.233 -> Pasta:
#
# 10.0.12.68 -> Caminho:
#
# ============================================================

function Get-SystemFromBackupBlock
{
    param(
        [string]$Pasta,
        [string]$Nome,
        [string]$IPServidor
    )

    if (
        [string]::IsNullOrWhiteSpace(
            $Pasta
        )
    )
    {
        return $null
    }

    $PastaNormalizada =
        $Pasta.ToLowerInvariant().Trim()

    $NomeNormalizado =
        ""

    if (
        -not [string]::IsNullOrWhiteSpace(
            $Nome
        )
    )
    {
        # Remove Nome: do inicio

        $NomeNormalizado =
            $Nome -replace '^\s*Nome\s*:\s*', ''

        $NomeNormalizado =
            $NomeNormalizado.ToLowerInvariant().Trim()
    }

    # ========================================================
    # SERVIDOR SGBD
    #
    # 10.0.12.68
    #
    # Neste servidor busca por Caminho:
    # ========================================================

    if (
        $IPServidor -eq "10.0.12.68"
    )
    {
        # ====================================================
        # ARSISTEMAS
        #
        # ...\AR\UCC
        # ====================================================

        if (
            $PastaNormalizada -match
            '\\ar\\ucc\s*$'
        )
        {
            return "ARSistemas"
        }

        # ====================================================
        # ARSISTEMAS USL
        #
        # ...\AR\USL
        # ====================================================

        if (
            $PastaNormalizada -match
            '\\ar\\usl\s*$'
        )
        {
            return "ARSistemas USL"
        }

        # ====================================================
        # CCIH
        # ====================================================

        if (
            $PastaNormalizada -match
            '\\ccih\s*$'
        )
        {
            return "CCIH"
        }

        # ====================================================
        # DES
        # ====================================================

        if (
            $PastaNormalizada -match
            '\\des\s*$'
        )
        {
            return "DES"
        }

        # ====================================================
        # MEDWARE
        # ====================================================

        if (
            $PastaNormalizada -match
            '\\medware\s*$'
        )
        {
            return "MedWare"
        }

        # ====================================================
        # NASAJON
        # ====================================================

        if (
            $PastaNormalizada -match
            '\\nasajon\s*$'
        )
        {
            return "Nasajon"
        }

        # ====================================================
        # PATHCONTROL
        # ====================================================

        if (
            $PastaNormalizada -match
            '\\pathocontrol\s*$'
        )
        {
            return "PathControl"
        }

        if (
            $PastaNormalizada -match
            '\\pathcontrol\s*$'
        )
        {
            return "PathControl"
        }

        # ====================================================
        # PIXEON AURORA
        #
        # Pasta:
        # ...\Pixeon
        #
        # Nome:
        # Aurora...
        # ====================================================

        if (
            $PastaNormalizada -match
            '\\pixeon\s*$'
        )
        {
            if (
                $NomeNormalizado -match
                '^\s*aurora'
            )
            {
                return "Pixeon Aurora"
            }
        }

        # ====================================================
        # PIXEON DATABASE
        #
        # Pasta:
        # ...\Pixeon
        #
        # Nome:
        # Database...
        # ====================================================

        if (
            $PastaNormalizada -match
            '\\pixeon\s*$'
        )
        {
            if (
                $NomeNormalizado -match
                '^\s*(database|base)\b'
            )
            {
                return "Pixeon Database"
            }
        }

        # ====================================================
        # PRODABEL
        #
        # ...\Prodabel
        # ====================================================

        if (
            $PastaNormalizada -match
            '\\prodabel\s*$'
        )
        {
            return "Prodabel"
        }

        # ====================================================
        # PRODABEL USL
        #
        # ...\Prodabel SL
        # ====================================================

        if (
            $PastaNormalizada -match
            '\\prodabel\s+sl\s*$'
        )
        {
            return "Prodabel USL"
        }

        # ====================================================
        # SENIOR VETORRH
        #
        # Pasta:
        # ...\Senior
        #
        # Nome:
        # Backup - Vetorh
        # ====================================================

        if (
            $PastaNormalizada -match
            '\\senior\s*$'
        )
        {
            if (
                $NomeNormalizado -match
                'vetorh'
            )
            {
                return "Senior VetorRH"
            }
        }

        # ====================================================
        # SENIOR EDOCS
        #
        # Pasta:
        # ...\Senior
        #
        # Nome:
        # Backup - Edocs
        # ====================================================

        if (
            $PastaNormalizada -match
            '\\senior\s*$'
        )
        {
            if (
                $NomeNormalizado -match
                'edocs'
            )
            {
                return "Senior EDocs"
            }
        }

        # ====================================================
        # Nota:
        #
        # Ñ usar Regras genericas do 10.0.0.233.
        #
        # Impede que algum diretorio do SGBD seja
        # confundido com outro sistema.
        # ====================================================

        return $null
    }

    # ========================================================
    # SERVIDOR 10.0.0.233
    #
    # MANTIDA A LOGICA ORIGINAL
    # ========================================================

    # ========================================================
    # NASAJON
    # ========================================================

    if (
        $PastaNormalizada -match
        'nasajon-sql'
    )
    {
        return "Nasajon"
    }

    # ========================================================
    # PIXEON AURORA
    # ========================================================

    if (
        $PastaNormalizada -match
        '\\pixeon\s*$'
    )
    {
        if (
            $NomeNormalizado -match
            '^\s*auroradatabase\b'
        )
        {
            return "Pixeon Aurora"
        }
    }

    # ========================================================
    # PIXEON DATABASE
    # ========================================================

    if (
        $PastaNormalizada -match
        '\\pixeon\s*$'
    )
    {
        if (
            $NomeNormalizado -match
            '^\s*(database|base)\b'
        )
        {
            return "Pixeon Database"
        }
    }

    # ========================================================
    # SENIOR EDOCS
    # ========================================================

    if (
        $PastaNormalizada -match
        'senior_db'
    )
    {
        if (
            $PastaNormalizada -match
            'backup\s*-\s*edocs'
        )
        {
            return "Senior EDocs"
        }
    }

    # ========================================================
    # SENIOR VETORRH
    # ========================================================

    if (
        $PastaNormalizada -match
        'senior_db'
    )
    {
        if (
            $PastaNormalizada -match
            'backup\s*-\s*vetorh'
        )
        {
            return "Senior VetorRH"
        }
    }


	# ========================================================
# SENIOR GLASSFISH
#
# Pasta:
# ...\senior_db\Backup - Aplicação
#
# Nome:
# glassfish40 ...
# ========================================================

if (
    $PastaNormalizada -match
    'senior_db'
)
{
    if (
        $PastaNormalizada -match
        'backup\s*-\s*aplica'
    )
    {
        if (
            $NomeNormalizado -match
            '^\s*glassfish40\b'
        )
        {
            return "Senior Glassfish"
        }
    }
}

# ========================================================
# SENIOR
#
# Pasta:
# ...\senior_db\Backup - Aplicação
#
# Nome:
# Senior ...
# ========================================================

if (
    $PastaNormalizada -match
    'senior_db'
)
{
    if (
        $PastaNormalizada -match
        'backup\s*-\s*aplica'
    )
    {
        if (
            $NomeNormalizado -match
            '^\s*senior\b'
        )
        {
            return "Senior"
        }
    }
}

# ========================================================
# SENIOR TESTE
#
# Pasta:
# ...\senior_db\Backup - Aplicação
#
# Nome:
# Senior_teste ...
# ========================================================

if (
    $PastaNormalizada -match
    'senior_db'
)
{
    if (
        $PastaNormalizada -match
        'backup\s*-\s*aplica'
    )
    {
        if (
            $NomeNormalizado -match
            '^\s*senior[_\s-]*teste\b'
        )
        {
            return "Senior Teste"
        }
    }
}

    # ========================================================
    # REGRAS PADRAO DO 10.0.0.233
    # ========================================================

    $Caminho =
        $Pasta.Trim().TrimEnd('\')

    $Partes =
        $Caminho -split '\\'

    if (
        $Partes.Count -eq 0
    )
    {
        return $null
    }

    $Ultimo =
        $Partes[-1].Trim()

    if (
        [string]::IsNullOrWhiteSpace(
            $Ultimo
        )
    )
    {
        return $null
    }

    $Chave =
        $Ultimo.ToLowerInvariant()

    if (
        $MapeamentoSistemas.ContainsKey(
            $Chave
        )
    )
    {
        return $MapeamentoSistemas[$Chave]
    }

    return $null
}

# ============================================================
# FUNCAO - EXTRAIR TODOS OS BLOCOS DE BACKUP
#
# 10.0.0.233:
# Nome:
# Tamanho:
# Pasta:
#
# 10.0.12.68:
# Nome:
# Tamanho:
# Caminho:
#
# ============================================================

function Get-BackupRecords
{
    param(
        [string]$Texto,

        [string]$IPServidor
    )

    $Resultado =
        @()

    $Linhas =
        $Texto -split "`r?`n"

    for (
        $i = 0;
        $i -lt $Linhas.Count;
        $i++
    )
    {
        $LinhaAtual =
            $Linhas[$i].Trim()

        # ====================================================
        # PROCURA LINHA NOME
        # ====================================================

        if (
            $LinhaAtual -notmatch
            '^\s*Nome\s*:'
        )
        {
            continue
        }

        # ====================================================
        # DATA E HORA
        # ====================================================

        $DataHora =
            Get-DateTimeFromNameLine `
                -Linha $LinhaAtual

        if (
            $null -eq $DataHora
        )
        {
            continue
        }

        # ====================================================
        # VARIAVEIS
        # ====================================================

        $Tamanho =
            $null

        $PastaLinha =
            $null

        # ====================================================
        # PROCURA TAMANHO E PASTA/CAMINHO
        # ====================================================

        for (
            $j = $i + 1;
            $j -lt $Linhas.Count;
            $j++
        )
        {
            $LinhaBloco =
                $Linhas[$j].Trim()

            # ------------------------------------------------
            # SE COMECOU OUTRO BLOCO
            # ------------------------------------------------

            if (
                $LinhaBloco -match
                '^\s*Nome\s*:'
            )
            {
                break
            }

            # ------------------------------------------------
            # TAMANHO
            # ------------------------------------------------

            if (
                $LinhaBloco -match
                '^\s*Tamanho\s*:'
            )
            {
                $Tamanho =
                    Get-BackupSize `
                        -Linha $LinhaBloco
            }

            # ------------------------------------------------
            # SERVIDOR 10.0.0.233
            #
            # Pasta:
            # ------------------------------------------------

            if (
                $LinhaBloco -match
                '^\s*Pasta\s*:'
            )
            {
                $PastaLinha =
                    $LinhaBloco

                break
            }

            # ------------------------------------------------
            # SERVIDOR 10.0.12.68
            #
            # Caminho:
            # ------------------------------------------------

            if (
                $LinhaBloco -match
                '^\s*Caminho\s*:'
            )
            {
                $PastaLinha =
                    $LinhaBloco

                break
            }
        }

        # ====================================================
        # SEM PASTA/CAMINHO
        # ====================================================

        if (
            $null -eq $PastaLinha
        )
        {
            continue
        }

        # ====================================================
        # IDENTIFICAR SISTEMA
        # ====================================================

        $Sistema =
            Get-SystemFromBackupBlock `
                -Pasta $PastaLinha `
                -Nome $LinhaAtual `
                -IPServidor $IPServidor

        if (
            [string]::IsNullOrWhiteSpace(
                $Sistema
            )
        )
        {
            continue
        }

        # ====================================================
        # IDENTIFICAR IP
        # ====================================================

        $IP =
            $null

        if (
            $PastaLinha -match
            '\\\\(?<IP>\d{1,3}(?:\.\d{1,3}){3})'
        )
        {
            $IP =
                $Matches["IP"]
        }

        # ====================================================
        # SE NAO ENCONTROU IP, USA O SERVIDOR DETECTADO
        # ====================================================

        if (
            [string]::IsNullOrWhiteSpace(
                $IP
            )
        )
        {
            $IP =
                $IPServidor
        }

        # ====================================================
        # SEM TAMANHO
        # ====================================================

        if (
            [string]::IsNullOrWhiteSpace(
                $Tamanho
            )
        )
        {
            $Tamanho =
                "Backup Pasta"
        }

        # ====================================================
        # CRIAR REGISTRO
        # ====================================================

        $Resultado +=
            [PSCustomObject]@{
                Nome      = $Sistema
                DataHora  = $DataHora
                Tamanho   = $Tamanho
                IP        = $IP
                Pasta     = $PastaLinha
                LinhaNome = $LinhaAtual
            }
    }

    return $Resultado
}

# ============================================================
# FUNCAO - ENCONTRAR BACKUP DO SISTEMA
# ============================================================

function Find-BackupForSystem
{
    param(
        [string]$Sistema,

        [array]$Registros
    )

    $Encontrados =
        @(
            $Registros |
            Where-Object {
                $_.Nome.Trim() -ieq
                $Sistema.Trim()
            }
        )

    if (
        $Encontrados.Count -eq 0
    )
    {
        return $null
    }

    # ========================================================
    # Pegar smp backup mais recente.
    # ========================================================

    return $Encontrados |
        Sort-Object DataHora -Descending |
        Select-Object -First 1
}

# ============================================================
# FUNCAO - AVALIAR BACKUP
# ============================================================

function Get-BackupStatus
{
    param(
        [datetime]$DataBackup,

        [string]$Tamanho
    )

    $Hoje =
        (Get-Date).Date

    $Data =
        $DataBackup.Date

    $Diferenca =
        ($Hoje - $Data).Days

    switch ($Diferenca)
    {
        # ====================================================
        # HOJE
        # ====================================================

        0
        {
            return @{
                Cor =
                    "#00C853"

                Texto =
                    "Backup realizado hoje as {0} - {1}" -f `
                    $DataBackup.ToString("HH:mm"),
                    $Tamanho

                Categoria =
                    "Hoje"
            }
        }

        # ====================================================
        # ONTEM
        # ====================================================

        1
        {
            return @{
                Cor =
                    "#FFD600"

                Texto =
                    "Backup realizado ontem as {0} - {1}" -f `
                    $DataBackup.ToString("HH:mm"),
                    $Tamanho

                Categoria =
                    "Ontem"
            }
        }

        # ====================================================
        # ANTEONTEM
        # ====================================================

        2
        {
            return @{
                Cor =
                    "#FF6400"

                Texto =
                    "Backup realizado anteontem as {0} - {1}" -f `
                    $DataBackup.ToString("HH:mm"),
                    $Tamanho

                Categoria =
                    "Anteontem"
            }
        }

        # ====================================================
        # MAIS ANTIGO
        # ====================================================

        default
        {
            if (
                $Diferenca -gt 2
            )
            {
                return @{
                    Cor =
                        "#FF0000"

                    Texto =
                        "Atencao - Verificar o backup - {0}" -f `
                        $Tamanho

                    Categoria =
                        "Antigo"
                }
            }

            # =================================================
            # DATA FUTURA
            # =================================================

            return @{
                Cor =
                    "#0000FF"

                Texto =
                    "Data do backup posterior a data atual - {0}" -f `
                    $Tamanho

                Categoria =
                    "Futuro"
            }
        }
    }
}

# ============================================================
# FUNCAO - PROCESSAR RELATORIO
# ============================================================

function Process-Report
{
    param(
        [string]$Texto
    )

    # ========================================================
    # RELATORIO VAZIO
    # ========================================================

    if (
        [string]::IsNullOrWhiteSpace(
            $Texto
        )
    )
    {
        Initialize-SystemList `
            -IPServidor $null

        $TxtServidor.Text =
            "Aguardando relatorio..."

        $TxtServidor.Foreground =
            [System.Windows.Media.Brushes]::Gray

        $TxtStatus.Text =
            "Status: Aguardando relatorio..."

        return
    }

    # ========================================================
    # IDENTIFICAR SERVIDOR PRIMEIRO
    # ========================================================

    $ServidorInfo =
        Get-ServerInformation `
            -Texto $Texto

    if (
        $null -ne $ServidorInfo
    )
    {
        $IPServidor =
            $ServidorInfo.IP

        $NomeServidor =
            $ServidorInfo.Nome

        $TxtServidor.Text =
            "$NomeServidor - $IPServidor"

        $TxtServidor.Foreground =
            [System.Windows.Media.Brushes]::White
    }
    else
    {
        $IPServidor =
            $null

        $TxtServidor.Text =
            "Servidor nao identificado"

        $TxtServidor.Foreground =
            [System.Windows.Media.Brushes]::Orange
    }

    # ========================================================
    # MONTA LISTA CORRETA PARA O SERVIDOR
    # ========================================================

    Initialize-SystemList `
        -IPServidor $IPServidor

    # ========================================================
    # EXTRAIR BACKUPS
    # ========================================================

    $Registros =
        @(
            Get-BackupRecords `
                -Texto $Texto `
                -IPServidor $IPServidor
        )

    # ========================================================
    # CONTADORES
    # ========================================================

    $Total =
        0

    $Hoje =
        0

    $Ontem =
        0

    $Anteontem =
        0

    $Antigos =
        0

    $NaoEncontrados =
        0

    # ========================================================
    # ATUALIZAR CADA SISTEMA
    # ========================================================

    foreach (
        $Controle in $PainelBackups.Children
    )
    {
        if (
            $null -eq $Controle.Tag
        )
        {
            continue
        }

        $Dados =
            $Controle.Tag

        $Sistema =
            $Dados.Nome

        $Led =
            $Dados.Led

        $Status =
            $Dados.Status

        # ----------------------------------------------------
        # ENCONTRAR BACKUP
        # ----------------------------------------------------

        $Backup =
            Find-BackupForSystem `
                -Sistema $Sistema `
                -Registros $Registros

        # ----------------------------------------------------
        # NAO ENCONTRADO
        # ----------------------------------------------------

        if (
            $null -eq $Backup
        )
        {
            Set-Led `
                -Led $Led `
                -Cor "#666666"

            $Status.Text =
                "Backup nao localizado no relatorio"

            $Status.Foreground =
                [System.Windows.Media.Brushes]::Gray

            $NaoEncontrados++

            continue
        }

        # ----------------------------------------------------
        # AVALIAR BACKUP
        # ----------------------------------------------------

        $Avaliacao =
            Get-BackupStatus `
                -DataBackup $Backup.DataHora `
                -Tamanho $Backup.Tamanho

        Set-Led `
            -Led $Led `
            -Cor $Avaliacao.Cor

        $Status.Text =
            $Avaliacao.Texto

        # ----------------------------------------------------
        # COR DO TEXTO
        # ----------------------------------------------------

        switch (
            $Avaliacao.Categoria
        )
        {
            "Hoje"
            {
                $Status.Foreground =
                    [System.Windows.Media.Brushes]::LightGreen

                $Hoje++
            }

            "Ontem"
            {
                $Status.Foreground =
                    [System.Windows.Media.Brushes]::Yellow

                $Ontem++
            }

            "Anteontem"
            {
                $Status.Foreground =
                    [System.Windows.Media.Brushes]::Orange

                $Anteontem++
            }

            "Antigo"
            {
                $Status.Foreground =
                    [System.Windows.Media.Brushes]::Red

                $Antigos++
            }

            "Futuro"
            {
                $Status.Foreground =
                    [System.Windows.Media.Brushes]::Blue
            }
        }

        $Total++
    }

    # ========================================================
    # STATUS GERAL
    # ========================================================

    $DataProcessamento =
        Get-Date -Format "dd/MM/yyyy HH:mm:ss"

    $TxtStatus.Text =
        "Status: $Total backup(s) localizado(s) | " +
        "Hoje: $Hoje | " +
        "Ontem: $Ontem | " +
        "Anteontem: $Anteontem | " +
        "Antigos: $Antigos | " +
        "Nao localizado: $NaoEncontrados | " +
        "Processado: $DataProcessamento"
}

# ============================================================
# TIMER DE PROCESSAMENTO
# ============================================================

$script:TimerProcessamento =
    New-Object System.Windows.Threading.DispatcherTimer

$script:TimerProcessamento.Interval =
    [TimeSpan]::FromMilliseconds(350)

$script:TimerProcessamento.Add_Tick({

    $script:TimerProcessamento.Stop()

    Process-Report `
        -Texto $TxtRelatorio.Text
})

# ============================================================
# EVENTO TEXTCHANGED
# ============================================================

$TxtRelatorio.Add_TextChanged({

    $script:TimerProcessamento.Stop()

    $script:TimerProcessamento.Start()
})

# ============================================================
# CARREGAR LOG DE UM SERVIDOR
# Le diretamente o arquivo na origem e exibe/processa o texto,
# sem copiar o TXT para uma pasta local.
# ============================================================

function Import-LogServidor
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$Origem,

        [Parameter(Mandatory = $true)]
        [string]$NomeArquivo
    )

    try
    {
        if (-not (Test-Path -LiteralPath $Origem -PathType Leaf))
        {
            throw "O arquivo de origem nao foi encontrado ou nao esta acessivel:`n$Origem"
        }

        # Le o conteudo diretamente do caminho de rede.
        $Conteudo = Get-Content -LiteralPath $Origem -Raw -ErrorAction Stop

        $script:TimerProcessamento.Stop()
        $TxtRelatorio.Text = $Conteudo
        [void]$TxtRelatorio.Focus()
        $TxtRelatorio.CaretIndex = $TxtRelatorio.Text.Length

        $TxtStatus.Text = "Status: Log carregado de $NomeArquivo"
    }
    catch
    {
        [System.Windows.MessageBox]::Show(
            "Nao foi possivel carregar o log diretamente da origem.`n`n$($_.Exception.Message)",
            "Erro ao carregar log",
            "OK",
            "Error"
        ) | Out-Null
    }
}

# ============================================================
# BOTAO SGBD
# ============================================================

$BtnSGBD.Add_Click({
    Import-LogServidor `
        -Origem '\\10.0.12.68\c$\temp\Logs OS Automatizados\LOGS\BCK(10.0.12.68).txt' `
        -NomeArquivo 'BCK(10.0.12.68).txt'
})

# ============================================================
# BOTAO FILE
# ============================================================

$BtnFILE.Add_Click({
    Import-LogServidor `
        -Origem '\\10.0.12.68\c$\temp\Logs OS Automatizados\LOGS\BCK(10.0.0.233).txt' `
        -NomeArquivo 'BCK(10.0.0.233).txt'
})

# ============================================================
# BOTAO COLAR
# ============================================================

$BtnColar.Add_Click({

    try
    {
        if (
            [System.Windows.Clipboard]::ContainsText()
        )
        {
            $TxtRelatorio.Text =
                [System.Windows.Clipboard]::GetText()

            [void]$TxtRelatorio.Focus()

            $TxtRelatorio.CaretIndex =
                $TxtRelatorio.Text.Length
        }
        else
        {
            [System.Windows.MessageBox]::Show(
                "A area de transferencia nao contem texto.",
                "Monitor de Backups",
                "OK",
                "Information"
            )
        }
    }
    catch
    {
        [System.Windows.MessageBox]::Show(
            "Nao foi possivel acessar a area de transferencia.`n`n$($_.Exception.Message)",
            "Erro",
            "OK",
            "Error"
        )
    }
})

# ============================================================
# BOTAO LIMPAR
# ============================================================

$BtnLimpar.Add_Click({

    $script:TimerProcessamento.Stop()

    $TxtRelatorio.Clear()

    Initialize-SystemList `
        -IPServidor $null

    $TxtServidor.Text =
        "Aguardando relatorio..."

    $TxtServidor.Foreground =
        [System.Windows.Media.Brushes]::Gray

    $TxtStatus.Text =
        "Status: Aguardando relatorio..."

    [void]$TxtRelatorio.Focus()
})

# ============================================================
# INICIALIZACAO
# ============================================================

Initialize-SystemList -IPServidor $null

[void]$TxtRelatorio.Focus()

# ============================================================
# EXIBIR JANELA
# ============================================================

$Window.ShowDialog() | Out-Null