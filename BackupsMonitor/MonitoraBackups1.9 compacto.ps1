# ============================================================
# MONITOR DE BACKUPS 1.7 - COMPACTO
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
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Monitor de Backups | Infraestrutura"
        Width="790" Height="590" MinWidth="700" MinHeight="500"
        WindowStartupLocation="CenterScreen"
        Background="#F3F5F8" Foreground="#263445" FontFamily="Segoe UI">
    <Window.Resources>
        <SolidColorBrush x:Key="PanelBrush" Color="#FFFFFF"/>
        <SolidColorBrush x:Key="LineBrush" Color="#E1E6ED"/>
        <SolidColorBrush x:Key="MutedBrush" Color="#718096"/>
        <Style x:Key="ActionButton" TargetType="Button">
            <Setter Property="Background" Value="#EDF2F7"/><Setter Property="Foreground" Value="#344256"/>
            <Setter Property="BorderBrush" Value="#D5DDE7"/><Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Height" Value="32"/><Setter Property="MinWidth" Value="76"/>
            <Setter Property="Padding" Value="8,0"/><Setter Property="FontSize" Value="10"/>
            <Setter Property="FontWeight" Value="SemiBold"/><Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Margin" Value="4,0,0,0"/>
            <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button">
                <Border x:Name="B" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}"
                        BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="5" Padding="{TemplateBinding Padding}">
                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="B" Property="Background" Value="#E2EAF3"/></Trigger>
                    <Trigger Property="IsPressed" Value="True"><Setter TargetName="B" Property="Opacity" Value="0.75"/></Trigger>
                    <Trigger Property="IsEnabled" Value="False"><Setter TargetName="B" Property="Opacity" Value="0.4"/></Trigger>
                </ControlTemplate.Triggers>
            </ControlTemplate></Setter.Value></Setter>
        </Style>
        <Style x:Key="PrimaryButton" TargetType="Button" BasedOn="{StaticResource ActionButton}">
            <Setter Property="Background" Value="#1769AA"/><Setter Property="Foreground" Value="#FFFFFF"/>
            <Setter Property="BorderBrush" Value="#1769AA"/>
        </Style>
        <Style x:Key="DangerButton" TargetType="Button" BasedOn="{StaticResource ActionButton}">
            <Setter Property="Background" Value="#FFF1F0"/><Setter Property="Foreground" Value="#B42318"/>
            <Setter Property="BorderBrush" Value="#F2C7C3"/>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Background" Value="#FBFCFE"/><Setter Property="Foreground" Value="#263445"/>
            <Setter Property="BorderBrush" Value="#D7DEE8"/><Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="6"/><Setter Property="FontSize" Value="10"/>
            <Setter Property="CaretBrush" Value="#1769AA"/><Setter Property="SelectionBrush" Value="#B8D7F2"/>
        </Style>
    </Window.Resources>
    <Grid Margin="9">
        <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
        <Border Grid.Row="0" Background="#FFFFFF" BorderBrush="#E1E6ED" BorderThickness="1" CornerRadius="6" Padding="9" Margin="0,0,0,6">
            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                <StackPanel><TextBlock Text="MONITOR DE BACKUPS" FontSize="15" FontWeight="Bold" Foreground="#243247"/>
                    <TextBlock Text="PAINEL DE ACOMPANHAMENTO DA INFRAESTRUTURA" FontSize="8" FontWeight="SemiBold" Foreground="#7B8797" Margin="1,2,0,0"/></StackPanel>
                <Border Grid.Column="1" Background="#EEF6FC" BorderBrush="#D6E8F6" BorderThickness="1" CornerRadius="5" Padding="7,4" VerticalAlignment="Center">
                    <TextBlock Text="●  MONITOR ATIVO" Foreground="#1769AA" FontSize="8" FontWeight="Bold"/></Border>
            </Grid>
        </Border>
        <Border Grid.Row="1" Background="#FFFFFF" BorderBrush="#E1E6ED" BorderThickness="1" CornerRadius="6" Padding="7" Margin="0,0,0,6">
            <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="58"/></Grid.RowDefinitions>
                <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                    <TextBlock Text="RELATÓRIO DE BACKUP" FontSize="9" FontWeight="Bold" Foreground="#344256" VerticalAlignment="Center"/>
                    <StackPanel Grid.Column="1" Orientation="Horizontal">
                        <Button x:Name="BtnSGBD" Content="SGBD" Style="{StaticResource ActionButton}"/>
                        <Button x:Name="BtnFILE" Content="FILE" Style="{StaticResource ActionButton}"/>
                        <Button x:Name="BtnColar" Content="COLAR" Style="{StaticResource PrimaryButton}"/>
                        <Button x:Name="BtnLimpar" Content="LIMPAR" Style="{StaticResource DangerButton}"/>
                    </StackPanel>
                </Grid>
                <TextBox x:Name="TxtRelatorio" Grid.Row="1" Margin="0,8,0,0" AcceptsReturn="True" TextWrapping="NoWrap"
                         VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" VerticalContentAlignment="Top"
                         FontFamily="Consolas" FontSize="10"/>
            </Grid>
        </Border>
        <Border Grid.Row="2" Background="#FFFFFF" BorderBrush="#E1E6ED" BorderThickness="1" CornerRadius="6" Padding="6" Margin="0,0,0,6">
            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                <Border Width="23" Height="23" Background="#EEF6FC" CornerRadius="6"><TextBlock Text="▣" Foreground="#1769AA" FontSize="12" HorizontalAlignment="Center" VerticalAlignment="Center"/></Border>
                <StackPanel Grid.Column="1" Margin="10,0,0,0" VerticalAlignment="Center">
                    <TextBlock Text="SERVIDOR IDENTIFICADO" FontSize="8" FontWeight="Bold" Foreground="#7B8797"/>
                    <TextBlock x:Name="TxtServidor" Text="Aguardando relatório..." FontSize="10" FontWeight="SemiBold" Foreground="#263445" Margin="0,1,0,0"/>
                </StackPanel>
            </Grid>
        </Border>
        <Border Grid.Row="3" Background="#FFFFFF" BorderBrush="#E1E6ED" BorderThickness="1" CornerRadius="6" Padding="7">
            <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                <Grid Grid.Row="0" Margin="2,0,2,8"><Grid.ColumnDefinitions><ColumnDefinition Width="2*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="1.4*"/></Grid.ColumnDefinitions>
                    <TextBlock Text="SISTEMA" FontSize="8" FontWeight="Bold" Foreground="#778496"/>
                    <TextBlock Grid.Column="1" Text="STATUS" FontSize="8" FontWeight="Bold" Foreground="#778496" Margin="0,0,18,0"/>
                    <TextBlock Grid.Column="2" Text="DETALHES DO BACKUP" FontSize="8" FontWeight="Bold" Foreground="#778496"/>
                </Grid>
                <ScrollViewer x:Name="ScrollBackups" Grid.Row="1" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                    <StackPanel x:Name="PainelBackups"/>
                </ScrollViewer>
            </Grid>
        </Border>
        <Border Grid.Row="4" Background="#FFFFFF" BorderBrush="#E1E6ED" BorderThickness="1" CornerRadius="5" Padding="6" Margin="0,6,0,0">
            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                <TextBlock x:Name="TxtStatus" Text="Status: Aguardando relatório..." FontSize="9" Foreground="#657386" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="1" Text="MONITOR DE BACKUPS  |  v1.7 COMPACTO" FontSize="8" FontWeight="SemiBold" Foreground="#8A96A6" VerticalAlignment="Center"/>
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
    param([string]$Nome)

    $Card = New-Object System.Windows.Controls.Border
    $Card.Background = [System.Windows.Media.Brushes]::White
    $Card.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#E8EDF3')
    $Card.BorderThickness = 1
    $Card.CornerRadius = [System.Windows.CornerRadius]::new(5)
    $Card.Padding = [System.Windows.Thickness]::new(6,2,6,2)
    $Card.Margin = [System.Windows.Thickness]::new(0,1,0,1)

    $Grid = New-Object System.Windows.Controls.Grid
    $Grid.Height = 23
    $Grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = '2*' }))
    $Grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = 'Auto' }))
    $Grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = '1.4*' }))

    $TxtNome = New-Object System.Windows.Controls.TextBlock
    $TxtNome.Text = $Nome
    $TxtNome.FontSize = 10
    $TxtNome.FontWeight = 'SemiBold'
    $TxtNome.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#344256')
    $TxtNome.VerticalAlignment = 'Center'
    [System.Windows.Controls.Grid]::SetColumn($TxtNome,0)
    [void]$Grid.Children.Add($TxtNome)

    $Badge = New-Object System.Windows.Controls.Border
    $Badge.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#F0F2F5')
    $Badge.CornerRadius = [System.Windows.CornerRadius]::new(10)
    $Badge.Padding = [System.Windows.Thickness]::new(6,1,6,1)
    $Badge.Margin = [System.Windows.Thickness]::new(0,0,18,0)
    $Badge.VerticalAlignment = 'Center'
    $TxtStatusLinha = New-Object System.Windows.Controls.TextBlock
    $TxtStatusLinha.Text = 'Aguardando dados'
    $TxtStatusLinha.FontSize = 8
    $TxtStatusLinha.FontWeight = 'SemiBold'
    $TxtStatusLinha.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#667085')
    $Badge.Child = $TxtStatusLinha
    [System.Windows.Controls.Grid]::SetColumn($Badge,1)
    [void]$Grid.Children.Add($Badge)

    $Led = New-Led '#98A2B3'
    $Led.Width = 7
    $Led.Height = 7
    $Led.Margin = [System.Windows.Thickness]::new(0,0,5,0)
    $Led.Visibility = 'Collapsed'

    $Card.Child = $Grid
    $Card.Tag = @{ Nome=$Nome; Led=$Led; Status=$TxtStatusLinha; Badge=$Badge; Card=$Card }
    $Grid.Tag = $Card.Tag
    [void]$PainelBackups.Children.Add($Card)
    return $Card
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
            [System.Windows.Media.Brushes]::DarkSlateGray
    }
    else
    {
        $IPServidor =
            $null

        $TxtServidor.Text =
            "Servidor nao identificado"

        $TxtServidor.Foreground =
            [System.Windows.Media.Brushes]::DarkOrange
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

            $Status.Text = "Não localizado"
            $Status.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#667085')
            $Dados.Badge.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#F0F2F5')

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

        $Status.Text = $Avaliacao.Texto
        $CorBadge = switch ($Avaliacao.Categoria) {
            'Hoje'      { '#E7F6EC' }
            'Ontem'     { '#FFF7DB' }
            'Anteontem' { '#FFF0E1' }
            'Antigo'    { '#FDECEC' }
            'Futuro'    { '#EAF2FF' }
            default     { '#F0F2F5' }
        }
        $Dados.Badge.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString($CorBadge)

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
                    [System.Windows.Media.Brushes]::DarkGreen

                $Hoje++
            }

            "Ontem"
            {
                $Status.Foreground =
                    [System.Windows.Media.Brushes]::DarkGoldenrod

                $Ontem++
            }

            "Anteontem"
            {
                $Status.Foreground =
                    [System.Windows.Media.Brushes]::DarkOrange

                $Anteontem++
            }

            "Antigo"
            {
                $Status.Foreground =
                    [System.Windows.Media.Brushes]::Firebrick

                $Antigos++
            }

            "Futuro"
            {
                $Status.Foreground =
                    [System.Windows.Media.Brushes]::RoyalBlue
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

Initialize-SystemList `
    -IPServidor $null

[void]$TxtRelatorio.Focus()

# ============================================================
# EXIBIR JANELA
# ============================================================

$Window.ShowDialog() | Out-Null