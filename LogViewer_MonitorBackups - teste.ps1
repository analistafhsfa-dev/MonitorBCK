# ============================================================
# LogViewer + Monitor de Backups 1.5
# Criado por Guilherme Analista Infra Seg
# Execução padrão: abre o LogViewer.
# Botão 'Monitor de Backups': abre o Monitor em outro processo.
# ============================================================
param(
    [switch]$MonitorBackups
)
if ($MonitorBackups) {
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
$TxtRelatorio=$Window.FindName("TxtRelatorio")
$BtnSGBD=$Window.FindName("BtnSGBD")
$BtnFILE=$Window.FindName("BtnFILE")
$BtnColar=$Window.FindName("BtnColar")
$BtnLimpar=$Window.FindName("BtnLimpar")
$TxtServidor=$Window.FindName("TxtServidor")
$PainelBackups=$Window.FindName("PainelBackups")
$TxtStatus=$Window.FindName("TxtStatus")
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
# ===========================================================
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
        $TxtRelatorio.Focus()
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
            $TxtRelatorio.Focus()
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
    $TxtRelatorio.Focus()
})
# ============================================================
# INICIALIZACAO
# ============================================================
Initialize-SystemList `
    -IPServidor $null
$TxtRelatorio.Focus()
# ============================================================
# EXIBIR JANELA
# ============================================================
$Window.ShowDialog() | Out-Null
    return
}
#==========================================================
# INICIO LogViewer
# ============================================================
# LogViewer - Monitora de logs
# Criado por Guilherme Analista Infra Seg
# ============================================================
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
# ------------------------------------------------------------
# CONFIGURACAO
# ------------------------------------------------------------
# Origem
$script:LogRoot = '\\10.0.12.68\c$\temp\Logs OS Automatizados\LOGS'
$script:Hoje = (Get-Date).Date
# chama Classes .Net para configura datas com base no idioma
$script:CultureEnglish = [Globalization.CultureInfo]::GetCultureInfo('en-US')
$script:CulturePortuguese = [Globalization.CultureInfo]::GetCultureInfo('pt-BR')
# SET botoes aos caminhos
$script:LogButtons = @(
    [pscustomobject]@{ Key='APL_UCC';       Label='Serviços Gesthos'; File='APLGesthos(10.0.0.201).txt'; Description='Verificar execução das APL Gesthos UCC (Erros verificar no servidor 10.0.0.204\temp)'; Group=1; Parser='APL' }
    [pscustomobject]@{ Key='DISCOS_UCC';    Label='Discos Gesthos';     File='ArmazenamentoRestante(10.0.0.200-201).txt'; Description='Verificar armazenamento discos Gesthos UCC (10.0.0.200/201)'; Group=1; Parser='DISKS' }
    [pscustomobject]@{ Key='BCK_UCC';       Label='Backups Gesthos';     File='BCK(10.0.0.226).txt'; Description='Backups Gesthos UCC (Erros verificar no servidor 10.0.0.226\CobianAPL)'; Group=1; Parser='BCK_UCC' }
    [pscustomobject]@{ Key='FIREBIRD_UCC';  Label='Sweep Firebird';   File='Firebird(10.0.0.200).txt'; Description='Verificação Sweep Firebird (Erros verificar no servidor 10.0.0.200\firebird.log)'; Group=1; Parser='FIREBIRD_UCC' }
    [pscustomobject]@{ Key='REPLICAS';      Label='Saúde Replicas';      File='ReplicasSaude(10.0.0.126-10.0.4.232).txt'; Description='Verificação saúde das réplicas (Erros verificar no servidor 10.0.4.232)'; Group=1; Parser='REPLICAS' }
    [pscustomobject]@{ Key='APL_USL';       Label='Serviços Gesthos';File='APLGesthos(10.0.8.201).txt'; Description='Verificar execução das APL Gesthos Gesthos USL (Erros verificar no servidor 10.0.8.201\temp)'; Group=2; Parser='APL' }
    [pscustomobject]@{ Key='APL_WTS';       Label='Serviço WhatsApp';File='APLGesthos(10.0.11.251).txt'; Description='Verificar execução da APL Whats/Gesthos USL (Erros verificar no servidor 10.0.11.251\temp)'; Group=2; Parser='APL' }
    [pscustomobject]@{ Key='DISCOS_USL';    Label='Discos Gesthos';    File='ArmazenamentoRestanteSL(10.0.8.200-201).txt'; Description='Verificar armazenamento discos Gesthos USL (10.0.8.200/201)'; Group=2; Parser='DISKS' }
    [pscustomobject]@{ Key='BCK_USL';       Label='Backups Gesthos';    File='BCKGesthosSL(10.0.8.222).txt'; Description='Backups Gesthos USL (Erros verificar no servidor 10.0.8.222)'; Group=2; Parser='BCK_USL' }
    [pscustomobject]@{ Key='FIREBIRD_USL';  Label='Sweep Firebird';   File='Firebird(10.0.8.200).txt'; Description='Verificação Sweep Firebird (Erros verificar no servidor 10.0.8.200\firebird.log)'; Group=2; Parser='FIREBIRD_USL' }
    [pscustomobject]@{ Key='AR_USL';        Label='Backup ARLAB';    File='BCKArSistmsSL(10.0.8.222).txt'; Description='Backups ARLAB USL (Erros verificar no servidor 10.0.8.222)'; Group=2; Parser='AR_BCK' }
)
# ------------------------------------------------------------
# INTERFACE
# ------------------------------------------------------------
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
                        <Border x:Name="ButtonBorder" Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="9" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
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

        <Border Grid.Row="0" Background="#FFFFFF" BorderBrush="#D8DCE2" BorderThickness="1"
                CornerRadius="12" Padding="18" Margin="0,0,0,14">
            <Grid>
                <StackPanel>
                    <TextBlock Text="⌕ LogViewer" FontSize="27" FontWeight="Bold" Foreground="#20242B"/>
                    <TextBlock Text="Painel de monitoramento dos logs diários" FontSize="12"
                               Foreground="#6B7280" Margin="1,4,0,0"/>
                </StackPanel>
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
                    <Border Background="#F1F3F5" BorderBrush="#D8DCE2" BorderThickness="1"
                            CornerRadius="8" Padding="10,6" Margin="0,0,8,0">
                        <TextBlock x:Name="TxtConnection" Text="Origem: aguardando acesso" FontSize="11" Foreground="#525A65"/>
                    </Border>
                    <Button x:Name="BtnMonitorBackups"
                            Content="Monitor de Backups"
                            Background="#087F91"
                            Foreground="White"
                            BorderBrush="#087F91"
                            Padding="12,8"
                            FontSize="11"
                            FontWeight="SemiBold"
                            ToolTip="Abrir o Monitor de Backups 1.5"/>
                </StackPanel>
            </Grid>
        </Border>

        <Border Grid.Row="1" Background="#FFFFFF" BorderBrush="#D8DCE2" BorderThickness="1"
                CornerRadius="12" Padding="14" Margin="0,0,0,12">
            <StackPanel>
                <TextBlock Text="SELECIONE O LOG :              [ 1ª LINHA >> UCC    \    2ª LINHA >> USL ]" FontSize="11" FontWeight="Bold" Foreground="#6B7280"
                           Margin="2,0,0,10"/>
                <UniformGrid x:Name="GridBotoesLinha1" Rows="1" Columns="5" Margin="0,0,0,8"/>
                <UniformGrid x:Name="GridBotoesLinha2" Rows="1" Columns="6"/>
            </StackPanel>
        </Border>

        <Border Grid.Row="2" Background="#FFFFFF" BorderBrush="#D8DCE2" BorderThickness="1"
                CornerRadius="12" Padding="14" Margin="0,0,0,12">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="95"/>
                </Grid.RowDefinitions>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <TextBlock Text="CONTEÚDO DO LOG (somente leitura — clique no campo copia o conteudo)" FontSize="11"
                           FontWeight="Bold" Foreground="#6B7280" Margin="1,0,0,8"/>
                <TextBlock x:Name="TxtArquivoSelecionado" Grid.Column="1" Text="Nenhum arquivo selecionado"
                           Foreground="#6B7280" FontSize="11" VerticalAlignment="Center" Margin="10,0,0,8"/>
                <TextBox x:Name="TxtLog" Grid.Row="1" Grid.ColumnSpan="2" IsReadOnly="True"
                         AcceptsReturn="True" TextWrapping="NoWrap" VerticalScrollBarVisibility="Auto"
                         HorizontalScrollBarVisibility="Auto" VerticalContentAlignment="Top"/>
            </Grid>
        </Border>

        <Border Grid.Row="3" Background="#FFFFFF" BorderBrush="#D8DCE2" BorderThickness="1"
                CornerRadius="12" Padding="14" Margin="0,0,0,12">
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
                        <TextBlock Text="RESULTADOS DA ANÁLISE" FontSize="12" FontWeight="Bold" Foreground="#343A43"/>
                        <TextBlock x:Name="TxtResumo" Text="Selecione um botão para carregar e analisar o log."
                                   FontSize="11" Foreground="#6B7280" Margin="0,4,0,0"/>
                    </StackPanel>
                    <Button x:Name="BtnLimparResultados" Grid.Column="1" Content="Limpar resultados"
                            Padding="12,7" FontSize="11" VerticalAlignment="Center"/>
                </Grid>
                <ScrollViewer Grid.Row="1" Margin="0,12,0,0" VerticalScrollBarVisibility="Auto"
                              HorizontalScrollBarVisibility="Auto">
                    <StackPanel x:Name="PainelResultados"/>
                </ScrollViewer>
            </Grid>
        </Border>

        <Border Grid.Row="4" Background="#ECEFF2" BorderBrush="#D8DCE2" BorderThickness="1"
                CornerRadius="8" Padding="9,7">
            <Grid>
                <TextBlock x:Name="TxtStatus" Text="Status: Pronto" FontSize="11" Foreground="#555D68"/>
                <TextBlock Text="LogViewer • v1.0" HorizontalAlignment="Right" FontSize="11" Foreground="#7A828D"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@
$Reader = New-Object System.Xml.XmlNodeReader $Xaml
$Window = [Windows.Markup.XamlReader]::Load($Reader)
$GridBotoesLinha1 = $Window.FindName('GridBotoesLinha1')
$GridBotoesLinha2 = $Window.FindName('GridBotoesLinha2')
$TxtLog = $Window.FindName('TxtLog')
$TxtArquivoSelecionado = $Window.FindName('TxtArquivoSelecionado')
$PainelResultados = $Window.FindName('PainelResultados')
$TxtStatus = $Window.FindName('TxtStatus')
$TxtResumo = $Window.FindName('TxtResumo')
$TxtConnection = $Window.FindName('TxtConnection')
$BtnMonitorBackups = $Window.FindName('BtnMonitorBackups')
$CaminhoScriptPrincipal = $PSCommandPath

# Abre o modo Monitor de Backups em outro processo PowerShell.
# O processo separado evita conflito entre as variáveis e janelas WPF dos dois módulos.
$BtnMonitorBackups.Add_Click({
    try {
        if ([string]::IsNullOrWhiteSpace($CaminhoScriptPrincipal) -or
            -not (Test-Path -LiteralPath $CaminhoScriptPrincipal -PathType Leaf)) {
            throw "Não foi possível identificar o arquivo PS1 integrado."
        }

        $PowerShellExe = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
        $Argumentos = '-NoProfile -STA -ExecutionPolicy Bypass -File "{0}" -MonitorBackups' -f $CaminhoScriptPrincipal

        Start-Process -FilePath $PowerShellExe -ArgumentList $Argumentos
        $TxtStatus.Text = 'Status: Monitor de Backups iniciado.'
    }
    catch {
        [System.Windows.MessageBox]::Show(
            $_.Exception.Message,
            'Erro ao abrir Monitor de Backups',
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Error
        ) | Out-Null
    }
}.GetNewClosure())
$BtnLimparResultados = $Window.FindName('BtnLimparResultados')
# ------------------------------------------------------------
# FUNCOES VISUAIS
# ------------------------------------------------------------
function Add-ResultRow {
    param(
        [Parameter(Mandatory=$true)][string]$Text,
        [ValidateSet('Green','Red','Amber','Gray')][string]$State = 'Gray'
    )
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
    switch ($State) {
        'Green' { $led.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#21A366') }
        'Red'   { $led.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#D64545') }
        'Amber' { $led.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#D99A24') }
        default { $led.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#9299A3') }
    }
    [System.Windows.Controls.Grid]::SetColumn($led, 0)
    [void]$row.Children.Add($led)
    $textBlock = New-Object System.Windows.Controls.TextBlock
    $textBlock.Text = $Text
    $textBlock.TextWrapping = 'Wrap'
    $textBlock.VerticalAlignment = 'Center'
    $textBlock.FontSize = 12
    $textBlock.Foreground = [System.Windows.Media.Brushes]::DarkSlateGray
    $textBlock.Margin = '4,5,4,5'
    [System.Windows.Controls.Grid]::SetColumn($textBlock, 1)
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
#PopUP para Firebird, Replicas
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
    while ($date.DayOfWeek -ne $Day) { $date = $date.AddDays(-1) }
    return $date
}
function Convert-FirebirdDate {
    param([string]$Line)
    # Exemplo: SERVFHSFA4B Sat Oct 17 02:00:07 2026
    $m = [regex]::Match($Line, '^\s*(?<host>\S+)\s+(?<dow>Mon|Tue|Wed|Thu|Fri|Sat|Sun)\s+(?<month>[A-Za-z]{3})\s+(?<day>\d{1,2})\s+(?<time>\d{2}:\d{2}:\d{2})\s+(?<year>\d{4})')
    if (-not $m.Success) { return $null }
    $dateText = '{0} {1} {2} {3}' -f $m.Groups['month'].Value, $m.Groups['day'].Value, $m.Groups['year'].Value, $m.Groups['time'].Value
    try {
        return [datetime]::ParseExact($dateText, 'MMM d yyyy HH:mm:ss', $script:CultureEnglish)
    } catch { return $null }
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
    foreach ($i in 0..([Math]::Max(0, $Lines.Count - 1))) {
        if ($i -ge $Lines.Count) { continue }
        $line = $Lines[$i]
        if ($line -match "^\s*$([regex]::Escape($ExpectedHost))\s+") {
            $date = Convert-FirebirdDate -Line $line
            $sweepFinished = ($i + 1 -lt $Lines.Count -and $Lines[$i + 1] -match 'Sweep is finished')
            if ($date -and $date.Date -eq $expectedDate -and $sweepFinished) {
                Add-ResultRow -State Green -Text ("Sweep Concluído no {0} - {1}" -f $DayLabel, $date.ToString('dd/MM/yyyy HH:mm:ss'))
                $found = $true
                break
            }
        }
    }
    if (-not $found) {
        Add-ResultRow -State Red -Text ("Erro no Sweep no {0} (data esperada: {1})" -f $DayLabel, $expectedDate.ToString('dd/MM/yyyy'))
    }
}
# ------------------------------------------------------------
# ANALISADORES DOS LOGS
# ------------------------------------------------------------
#replicas
function Analyze-Replicas {
    param([string[]]$Lines)
    Show-NonMondayNotice
    $dateLine = $Lines | Where-Object { $_ -match 'Data/Hora:\s*(?<date>\d{2}/\d{2}/\d{4})' } | Select-Object -Last 1
    $logDate = $null
    if ($dateLine -and $dateLine -match 'Data/Hora:\s*(\d{2}/\d{2}/\d{4})') {
        try { $logDate = [datetime]::ParseExact($Matches[1], 'dd/MM/yyyy', $script:CulturePortuguese) } catch {}
    }
    if ($logDate) {
        Add-ResultRow -State $(if ($logDate.Date -eq (Get-Date).Date) {'Green'} else {'Red'}) -Text ("Data/Hora do relatório: {0}" -f $dateLine.Trim())
    } else {
        Add-ResultRow -State Red -Text 'Data/Hora do relatório não encontrada.'
    }
    $replicaLines = @($Lines | Where-Object { $_ -match '\bReplicating\b' })
    if ($replicaLines.Count -eq 0) {
        Add-ResultRow -State Red -Text 'Nenhuma linha com Replicating foi encontrada.'
        return
    }
    foreach ($line in $replicaLines) {
        $m = [regex]::Match($line, '^\s*(?<vm>\S+)\s+Replicating\s+(?<health>\S+)\s+(?<last>.+?)\s*$')
        if (-not $m.Success) {
            Add-ResultRow -State Red -Text ("Linha de réplica não reconhecida: {0}" -f $line.Trim())
            continue
        }
        $vm = $m.Groups['vm'].Value
        $health = $m.Groups['health'].Value
        $last = $m.Groups['last'].Value.Trim()
        if ($health -ieq 'Normal') {
            Add-ResultRow -State Green -Text ("{0} Replica Funcional - {1}" -f $vm, $last)
        } else {
            Add-ResultRow -State Red -Text ("{0} Replica Falhando ({1}) - {2}" -f $vm, $health, $last)
        }
    }
}
#Firebird
function Analyze-Firebird {
    param([string[]]$Lines, [string]$HostName)
    Show-NonMondayNotice
    Test-FirebirdSweep -Lines $Lines -ExpectedHost $HostName -ExpectedDay ([DayOfWeek]::Saturday) -DayLabel 'sábado'
    Test-FirebirdSweep -Lines $Lines -ExpectedHost $HostName -ExpectedDay ([DayOfWeek]::Sunday) -DayLabel 'domingo'
}
#Discos
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
                try { $currentDate = [datetime]::ParseExact($dateText, $format, $script:CulturePortuguese); break } catch {}
            }
            if (-not $currentDate) {
                $dateOnly = [regex]::Match($dateText, '\d{2}/\d{2}/\d{4}')
                if ($dateOnly.Success) { try { $currentDate = [datetime]::ParseExact($dateOnly.Value, 'dd/MM/yyyy', $script:CulturePortuguese) } catch {} }
            }
            continue
        }
        if ($line -match '(?<ip>\d{1,3}(?:\.\d{1,3}){3})\s*-\s*Armazenamento restante') {
            $currentIp = $Matches['ip']
            if ($currentDate) {
                $blocks.Add([pscustomobject]@{ Date=$currentDate; IP=$currentIp; Lines=(New-Object System.Collections.Generic.List[string]) })
            }
            continue
        }
        if ($blocks.Count -gt 0 -and $currentIp) {
            $lastBlock = $blocks[$blocks.Count - 1]
            if ($line -match '^\s*[CD]:\s*-') { $lastBlock.Lines.Add($line.Trim()) }
            elseif ($line -match '^\s*-{3,}\s*$') { $currentIp = $null }
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
            $m = [regex]::Match($diskLine, '^\s*(?<disk>[CD]):\s*-\s*(?<total>[\d\.,]+)\s*GB\s*total\s*/\s*(?<free>[\d\.,]+)\s*GB\s*livre', 'IgnoreCase')
            if (-not $m.Success) {
                Add-ResultRow -State Red -Text ("{0} - não foi possível interpretar o espaço livre" -f $block.IP)
                continue
            }
            $totalText = $m.Groups['total'].Value
            $freeText = $m.Groups['free'].Value
            try {
                $total = [double]::Parse($totalText, [Globalization.NumberStyles]::Any, $script:CulturePortuguese)
                $free = [double]::Parse($freeText, [Globalization.NumberStyles]::Any, $script:CulturePortuguese)
                $percent = if ($total -gt 0) { ($free / $total) * 100 } else { 100 }
                # Critério solicitado: verde se menos de 90% livre; vermelho se 90% ou mais.
                $state = if ($percent -lt 90) {'Green'} else {'Red'}
                Add-ResultRow -State $state -Text ("{0} - {1} GB livre ({2:N1}% de {3} GB) — disco {4}" -f $block.IP, $freeText, $percent, $totalText, $m.Groups['disk'].Value)
            } catch {
                Add-ResultRow -State Red -Text ("{0} - valor de armazenamento inválido: {1}" -f $block.IP, $diskLine)
            }
        }
    }
}
#BackupGesthosUCC
function Analyze-BackupUCC {
    param([string[]]$Lines)
    $rules = @(
        [pscustomobject]@{ Pattern='BCK_GESTHOS_U_CC-'; Label='BCK_GESTHOS_U_CC'; DateOffset=-1 },
        [pscustomobject]@{ Pattern='BCK_GESTHOS_IMP_U_CC-'; Label='BCK_GESTHOS_IMP_U_CC'; DateOffset=0 },
        [pscustomobject]@{ Pattern='BCK_GESTHOS_UCC_NOHARM-'; Label='BCK_GESTHOS_UCC_NOHARM'; DateOffset=0 },
        [pscustomobject]@{ Pattern='BCK_GESTHOS_LOG_U_CC-'; Label='BCK_GESTHOS_LOG_U_CC'; DateOffset=0 }
    )
    foreach ($rule in $rules) {
        $found = $false
        for ($i=0; $i -lt $Lines.Count; $i++) {
            if ($Lines[$i] -match [regex]::Escape($rule.Pattern)) {
                $date = $null
                $size = $null
                if ($i -gt 0 -and $Lines[$i-1] -match '\[(?<date>\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2}:\d{2})\]') {
                    try { $date = [datetime]::ParseExact($Matches['date'], 'dd/MM/yyyy HH:mm:ss', $script:CulturePortuguese) } catch {}
                }
                if ($i + 1 -lt $Lines.Count -and $Lines[$i+1] -match '^\s*Tamanho\s*:\s*(?<size>.+?)\s*$') { $size = $Matches['size'].Trim() }
                $expected = (Get-Date).Date.AddDays($rule.DateOffset)
                if ($date -and $date.Date -eq $expected -and $size) {
                    Add-ResultRow -State Green -Text ("{0} - {1} - {2}" -f $rule.Label, $date.ToString('dd/MM/yyyy HH:mm:ss'), $size)
                } else {
                    Add-ResultRow -State Red -Text ("{0} - verificar o backup" -f $rule.Label)
                }
                $found = $true
                break
            }
        }
        if (-not $found) { Add-ResultRow -State Red -Text ("{0} - verificar o backup (não encontrado)" -f $rule.Label) }
    }
}
#BackupGesthosUSL
function Analyze-BackupUSL {
    param([string[]]$Lines)
    $rules = @(
        [pscustomobject]@{ Pattern='Bck_GestHos_Imp_USL-'; Label='Bck_GestHos_Imp_USL'; DateOffset=-1 },
        [pscustomobject]@{ Pattern='Bck_GestHos_USL-'; Label='Bck_GestHos_USL'; DateOffset=0 }
    )
    foreach ($rule in $rules) {
        $found = $false
        for ($i=0; $i -lt $Lines.Count; $i++) {
            if ($Lines[$i] -match [regex]::Escape($rule.Pattern)) {
                $date = $null; $size = $null
                if ($i -gt 0 -and $Lines[$i-1] -match '\[(?<date>\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2}:\d{2})\]') {
                    try { $date = [datetime]::ParseExact($Matches['date'], 'dd/MM/yyyy HH:mm:ss', $script:CulturePortuguese) } catch {}
                }
                if ($i + 1 -lt $Lines.Count -and $Lines[$i+1] -match '^\s*Tamanho\s*:\s*(?<size>.+?)\s*$') { $size = $Matches['size'].Trim() }
                $expected = (Get-Date).Date.AddDays($rule.DateOffset)
                if ($date -and $date.Date -eq $expected -and $size) {
                    Add-ResultRow -State Green -Text ("{0} - {1} - {2}" -f $rule.Label, $date.ToString('dd/MM/yyyy HH:mm:ss'), $size)
                } else {
                    Add-ResultRow -State Red -Text ("{0} - verificar o backup" -f $rule.Label)
                }
                $found = $true
                break
            }
        }
        if (-not $found) { Add-ResultRow -State Red -Text ("{0} - verificar o backup (não encontrado)" -f $rule.Label) }
    }
}
#ARBACKUP
function Analyze-ARBackup {
    param([string[]]$Lines)
    $date = $null
    $size = $null
    for ($i=0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -match '^\s*Criado em:\s*(?<date>\d{2}/\d{2}/\d{4}\s+\d{2}:\d{2}:\d{2})') {
            try { $date = [datetime]::ParseExact($Matches['date'], 'dd/MM/yyyy HH:mm:ss', $script:CulturePortuguese) } catch {}
            if ($i + 1 -lt $Lines.Count -and $Lines[$i+1] -match '^\s*Tamanho:\s*(?<size>.+?)\s*$') { $size = $Matches['size'].Trim() }
            break
        }
    }
    $today = (Get-Date).Date
    if ($date -and $size -and ($date.Date -eq $today -or $date.Date -eq $today.AddDays(-1))) {
        Add-ResultRow -State Green -Text ("BCK AR Realizado - {0} - {1}" -f $date.ToString('dd/MM/yyyy HH:mm:ss'), $size)
    } else {
        Add-ResultRow -State Red -Text 'BCK AR não realizado, verifique!'
    }
}
#AplicacoesGesthos
function Analyze-APL {
    param([string[]]$Lines, [string]$ServerHint)
    $badMessages = @(
        'não possui linhas suficientes para penúltima',
        'não possui linhas suficientes',
        'não foi modificado hoje',
        'não encontrado'
    )
    $count = 0
    foreach ($line in $Lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        # Nome do log até .txt; a data é o primeiro campo entre colchetes
        $nameMatch = [regex]::Match($line, '^(?<name>.*?\.txt)')
        $dateMatches = [regex]::Matches($line, '\[(?<date>\d{2}/\d{2}/\d{4})\]')
        if (-not $nameMatch.Success -or $dateMatches.Count -eq 0) {
            Add-ResultRow -State Red -Text ("Linha inválida — Erro no log, verificar{0}" -f $ServerHint)
            $count++
            continue
        }
        $name = [IO.Path]::GetFileName($nameMatch.Groups['name'].Value.Trim())
        $dateText = $dateMatches[0].Groups['date'].Value
        $message = $line.Substring($dateMatches[$dateMatches.Count-1].Index + $dateMatches[$dateMatches.Count-1].Length).Trim()
        $date = $null
        try { $date = [datetime]::ParseExact($dateText, 'dd/MM/yyyy', $script:CulturePortuguese) } catch {}
        $hasBadMessage = $false
        foreach ($bad in $badMessages) {
            if ($line.IndexOf($bad, [StringComparison]::OrdinalIgnoreCase) -ge 0) { $hasBadMessage = $true; break }
        }
        if ($date -and $date.Date -eq (Get-Date).Date -and -not $hasBadMessage -and -not [string]::IsNullOrWhiteSpace($message)) {
            Add-ResultRow -State Green -Text ("{0} - {1} - {2}" -f $name, $dateText, $message)
        } else {
            Add-ResultRow -State Red -Text ("{0} - Erro no log, verificar{1}" -f $name, $ServerHint)
        }
        $count++
    }
    if ($count -eq 0) { Add-ResultRow -State Red -Text 'Nenhuma linha de log válida encontrada.' }
}
# ------------------------------------------------------------
# CARREGAR E ANALISAR UM ARQUIVO
# ------------------------------------------------------------
function Invoke-LogSelection {
    param([Parameter(Mandatory=$true)]$Definition)
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
            'REPLICAS'    { Analyze-Replicas -Lines $lines }
            'FIREBIRD_UCC'{ Analyze-Firebird -Lines $lines -HostName 'SERVFHSFA4B' }
            'FIREBIRD_USL'{ Analyze-Firebird -Lines $lines -HostName 'GESTHOSDB' }
            'DISKS'       { Analyze-Disks -Lines $lines }
            'BCK_UCC'     { Analyze-BackupUCC -Lines $lines }
            'BCK_USL'     { Analyze-BackupUSL -Lines $lines }
            'AR_BCK'      { Analyze-ARBackup -Lines $lines }
            'APL' {
                $serverHint = if ($Definition.Key -eq 'APL_UCC') { ' no 10.0.0.204.' } elseif ($Definition.Key -eq 'APL_USL') { '.' } else { '.' }
                Analyze-APL -Lines $lines -ServerHint $serverHint
            }
            default { Add-ResultRow -State Amber -Text 'Não há analisador configurado para este log.' }
        }

        $resultCount = $PainelResultados.Children.Count - 1
        $TxtResumo.Text = "Análise concluída para $($Definition.Label). Itens exibidos: $resultCount."
        $TxtStatus.Text = "Status: log carregado e analisado às $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
        $TxtConnection.Text = 'Origem: Compartilhamento de rede'
    }
    catch {
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
# ------------------------------------------------------------
# BOTOES COM TOOLTIP DELAY 2 SEGUNDOS
# ------------------------------------------------------------
foreach ($definition in $script:LogButtons) {
    $button = New-Object System.Windows.Controls.Button
    $button.Content = $definition.Label
    $button.Margin = '4'
    $button.MinHeight = 43
    $button.ToolTip = $definition.Description
    [System.Windows.Controls.ToolTipService]::SetInitialShowDelay($button, 2000)
    [System.Windows.Controls.ToolTipService]::SetShowDuration($button, 15000)
	#CORES BOTOES
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
# Clique campo de LOG copia para a área de transferência.
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
#Limpar dados
$BtnLimparResultados.Add_Click({
    $PainelResultados.Children.Clear()
    $TxtResumo.Text = 'Resultados limpos. Selecione um botão para analisar outro log.'
    $TxtStatus.Text = 'Status: pronto'
})

# ------------------------------------------------------------
# INICIALIZACAO
# ------------------------------------------------------------
if (Test-Path -LiteralPath $script:LogRoot) {
    $TxtConnection.Text = 'Origem: Compartilhamento SGBD 10.0.12.68 - acessível'
} else {
    $TxtConnection.Text = 'Origem: aguardando acesso à rede'
}
$Window.ShowDialog() | Out-Null
