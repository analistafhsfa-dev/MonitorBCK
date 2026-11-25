# ============================================================
# MONITOR DE BACKUPS 1.8 - DOIS LOGS
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
        Width="600" Height="660" MinWidth="600" MinHeight="660" MaxWidth="690" MaxHeight="660"
        WindowStartupLocation="CenterScreen"
        Background="#F3F5F8" Foreground="#263445" FontFamily="Segoe UI">
    <Window.Resources>
        <Style x:Key="PrimaryButton" TargetType="Button">
            <Setter Property="Background" Value="#1769AA"/><Setter Property="Foreground" Value="White"/>
            <Setter Property="BorderBrush" Value="#1769AA"/><Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Height" Value="30"/><Setter Property="Padding" Value="13,0"/>
            <Setter Property="FontSize" Value="10"/><Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Cursor" Value="Hand"/><Setter Property="Template"><Setter.Value>
                <ControlTemplate TargetType="Button"><Border x:Name="B" Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}"
                    CornerRadius="5" Padding="{TemplateBinding Padding}"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/></Border>
                    <ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="B" Property="Background" Value="#12558B"/></Trigger>
                    <Trigger Property="IsPressed" Value="True"><Setter TargetName="B" Property="Opacity" Value="0.75"/></Trigger>
                    <Trigger Property="IsEnabled" Value="False"><Setter TargetName="B" Property="Opacity" Value="0.5"/></Trigger></ControlTemplate.Triggers>
                </ControlTemplate></Setter.Value></Setter>
        </Style>
    </Window.Resources>
    <Grid Margin="9">
        <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
        <Border Grid.Row="0" Background="White" BorderBrush="#E1E6ED" BorderThickness="1" CornerRadius="6" Padding="9" Margin="0,0,0,6">
            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                <StackPanel><TextBlock Text="MONITOR DE BACKUPS" FontSize="15" FontWeight="Bold" Foreground="#243247"/>
                    <TextBlock Text="ACOMPANHAMENTO SGBD E FILESERVER" FontSize="8" FontWeight="SemiBold" Foreground="#7B8797" Margin="1,2,0,0"/></StackPanel>
                <Button x:Name="BtnCarregarLogs" Grid.Column="1" Content="CARREGAR LOGS" Style="{StaticResource PrimaryButton}" VerticalAlignment="Center"/>
            </Grid>
        </Border>
        <Border Grid.Row="1" Background="White" BorderBrush="#E1E6ED" BorderThickness="1" CornerRadius="6" Padding="7" Margin="0,0,0,6">
            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                <StackPanel><TextBlock Text="SGBD" FontSize="8" FontWeight="Bold" Foreground="#7B8797"/><TextBlock x:Name="TxtServidorSGBD" Text="Aguardando log..." FontSize="9" FontWeight="SemiBold" Foreground="#344256"/></StackPanel>
                <StackPanel Grid.Column="1"><TextBlock Text="FILE SERVER" FontSize="8" FontWeight="Bold" Foreground="#7B8797"/><TextBlock x:Name="TxtServidorFILE" Text="Aguardando log..." FontSize="9" FontWeight="SemiBold" Foreground="#344256"/></StackPanel>
            </Grid>
        </Border>
        <Border Grid.Row="2" Background="White" BorderBrush="#E1E6ED" BorderThickness="1" CornerRadius="6" Padding="7">
            <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                <Grid Grid.Row="0" Margin="3,0,3,7"><Grid.ColumnDefinitions><ColumnDefinition Width="1.15*"/><ColumnDefinition Width="1*"/><ColumnDefinition Width="1*"/></Grid.ColumnDefinitions>
                    <TextBlock Text="SISTEMA" FontSize="8" FontWeight="Bold" Foreground="#778496"/>
                    <TextBlock Grid.Column="1" Text="STATUS LOG SGBD" FontSize="8" FontWeight="Bold" Foreground="#1769AA"/>
                    <TextBlock Grid.Column="2" Text="STATUS LOG FILE SERVER" FontSize="8" FontWeight="Bold" Foreground="#1769AA"/>
                </Grid>
                <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                    <StackPanel x:Name="PainelBackups"/>
                </ScrollViewer>
            </Grid>
        </Border>
        <Border Grid.Row="3" Background="White" BorderBrush="#E1E6ED" BorderThickness="1" CornerRadius="5" Padding="6" Margin="0,6,0,0">
            <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                <TextBlock x:Name="TxtStatus" Text="Status: Aguardando carregamento dos logs..." FontSize="9" Foreground="#657386" VerticalAlignment="Center"/>
                <TextBlock Grid.Column="1" Text="MONITOR DE BACKUPS | v1.8" FontSize="8" FontWeight="SemiBold" Foreground="#8A96A6" VerticalAlignment="Center"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$Reader = New-Object System.Xml.XmlNodeReader $Xaml
$Window = [Windows.Markup.XamlReader]::Load($Reader)
$BtnCarregarLogs = $Window.FindName("BtnCarregarLogs")
$TxtServidorSGBD = $Window.FindName("TxtServidorSGBD")
$TxtServidorFILE = $Window.FindName("TxtServidorFILE")
$PainelBackups = $Window.FindName("PainelBackups")
$TxtStatus = $Window.FindName("TxtStatus")

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
    $Grid.Height = 25
    foreach ($peso in @(1.15,1.0,1.0)) {
        $col = New-Object System.Windows.Controls.ColumnDefinition
        $col.Width = [System.Windows.GridLength]::new([double]$peso, [System.Windows.GridUnitType]::Star)
        [void]$Grid.ColumnDefinitions.Add($col)
    }

    $TxtNome = New-Object System.Windows.Controls.TextBlock
    $TxtNome.Text = $Nome; $TxtNome.FontSize = 9; $TxtNome.FontWeight = 'SemiBold'
    $TxtNome.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#344256')
    $TxtNome.VerticalAlignment = 'Center'
    [void]$Grid.Children.Add($TxtNome)

    $makeStatus = {
        $wrap = New-Object System.Windows.Controls.Border
        $wrap.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#F0F2F5')
        $wrap.CornerRadius = [System.Windows.CornerRadius]::new(4)
        $wrap.Padding = [System.Windows.Thickness]::new(5,2,5,2)
        $wrap.Margin = [System.Windows.Thickness]::new(3,1,5,1)
        $wrap.VerticalAlignment = 'Center'
        $tb = New-Object System.Windows.Controls.TextBlock
        $tb.Text = 'Aguardando'; $tb.FontSize = 8; $tb.FontWeight = 'SemiBold'
        $tb.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#667085')
        $tb.TextTrimming = 'CharacterEllipsis'
        $wrap.Child = $tb
        return @{ Badge=$wrap; Text=$tb }
    }
    $sgbd = & $makeStatus
    $file = & $makeStatus
    [System.Windows.Controls.Grid]::SetColumn($sgbd.Badge,1)
    [System.Windows.Controls.Grid]::SetColumn($file.Badge,2)
    [void]$Grid.Children.Add($sgbd.Badge)
    [void]$Grid.Children.Add($file.Badge)

    $Card.Child = $Grid
    $Card.Tag = @{ Nome=$Nome; SGBD=$sgbd; FILE=$file }
    [void]$PainelBackups.Children.Add($Card)
    return $Card
}
# ============================================================

function Initialize-SystemList
{
    $PainelBackups.Children.Clear()
    $Lista = @($SistemasFixos) + @($SistemasSGBD)
    if ((Get-Date).DayOfWeek -eq [DayOfWeek]::Wednesday) {
        $Lista += @($SistemasSegunda)
    }
    foreach ($Sistema in ($Lista | Select-Object -Unique)) {
        New-SystemRow -Nome $Sistema | Out-Null
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

function Set-StatusSistema
{
    param(
        [hashtable]$Destino,
        $Backup
    )
    if ($null -eq $Backup) {
        $Destino.Text.Text = '-'
        $Destino.Text.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#667085')
        $Destino.Badge.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#F0F2F5')
        return 'Nao localizado'
    }

    $Avaliacao = Get-BackupStatus -DataBackup $Backup.DataHora -Tamanho $Backup.Tamanho
    $Destino.Text.Text = ('{0} | {1} | {2}' -f $Avaliacao.Categoria, $Backup.DataHora.ToString('dd/MM HH:mm'), $Backup.Tamanho)
    $Destino.Text.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#344256')
    $CorBadge = switch ($Avaliacao.Categoria) {
        'Hoje'      { '#E7F6EC' }
        'Ontem'     { '#FFF7DB' }
        'Anteontem' { '#FFF0E1' }
        'Antigo'    { '#FDECEC' }
        'Futuro'     { '#EAF2FF' }
        default     { '#F0F2F5' }
    }
    $Destino.Badge.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString($CorBadge)
    return $Avaliacao.Categoria
}

function Process-DualLogs
{
    param(
        [string]$TextoSGBD,
        [string]$TextoFILE
    )

    Initialize-SystemList
    $InfoSGBD = Get-ServerInformation -Texto $TextoSGBD
    $InfoFILE = Get-ServerInformation -Texto $TextoFILE
    $TxtServidorSGBD.Text = if ($InfoSGBD) { "$($InfoSGBD.Nome) - $($InfoSGBD.IP)" } else { 'Servidor SGBD não identificado' }
    $TxtServidorFILE.Text = if ($InfoFILE) { "$($InfoFILE.Nome) - $($InfoFILE.IP)" } else { 'Servidor FILE não identificado' }

    $RegistrosSGBD = @(Get-BackupRecords -Texto $TextoSGBD -IPServidor '10.0.12.68')
    $RegistrosFILE = @(Get-BackupRecords -Texto $TextoFILE -IPServidor '10.0.0.233')
    $Contagem = @{ Hoje=0; Ontem=0; Anteontem=0; Antigo=0; 'Nao localizado'=0; Futuro=0 }

    foreach ($Controle in $PainelBackups.Children) {
        $Dados = $Controle.Tag
        $Sistema = $Dados.Nome
        $BackupSGBD = Find-BackupForSystem -Sistema $Sistema -Registros $RegistrosSGBD
        $BackupFILE = Find-BackupForSystem -Sistema $Sistema -Registros $RegistrosFILE
        $CategoriaSGBD = Set-StatusSistema -Destino $Dados.SGBD -Backup $BackupSGBD
        $CategoriaFILE = Set-StatusSistema -Destino $Dados.FILE -Backup $BackupFILE
        foreach ($cat in @($CategoriaSGBD,$CategoriaFILE)) {
            if ($Contagem.ContainsKey($cat)) { $Contagem[$cat]++ }
        }
    }

    $Total = $RegistrosSGBD.Count + $RegistrosFILE.Count
    $TxtStatus.Text = "Status: $Total registro(s) | SGBD e FILE atualizados em $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
}

# ============================================================
# CARREGAR OS DOIS LOGS COM UM UNICO BOTAO
# ============================================================

$BtnCarregarLogs.Add_Click({
    $BtnCarregarLogs.IsEnabled = $false
    $TxtStatus.Text = 'Status: Carregando logs SGBD e FILE...'
    try {
        $OrigemSGBD = '\\10.0.12.68\c$\temp\Logs OS Automatizados\LOGS\BCK(10.0.12.68).txt'
        $OrigemFILE = '\\10.0.12.68\c$\temp\Logs OS Automatizados\LOGS\BCK(10.0.0.233).txt'

        if (-not (Test-Path -LiteralPath $OrigemSGBD -PathType Leaf)) {
            throw "Log SGBD não encontrado ou sem acesso:`n$OrigemSGBD"
        }
        if (-not (Test-Path -LiteralPath $OrigemFILE -PathType Leaf)) {
            throw "Log FILE SERVER não encontrado ou sem acesso:`n$OrigemFILE"
        }

        $LogSGBD = Get-Content -LiteralPath $OrigemSGBD -Raw -ErrorAction Stop
        $LogFILE = Get-Content -LiteralPath $OrigemFILE -Raw -ErrorAction Stop
        Process-DualLogs -TextoSGBD $LogSGBD -TextoFILE $LogFILE
    }
    catch {
        $TxtStatus.Text = 'Status: Falha ao carregar os logs.'
        [System.Windows.MessageBox]::Show(
            "Não foi possível carregar os dois logs.`n`n$($_.Exception.Message)",
            'Erro ao carregar logs', 'OK', 'Error'
        ) | Out-Null
    }
    finally {
        $BtnCarregarLogs.IsEnabled = $true
    }
})

# ============================================================
# INICIALIZACAO
# ============================================================

Initialize-SystemList

# ============================================================
# EXIBIR JANELA
# ============================================================

$Window.ShowDialog() | Out-Null