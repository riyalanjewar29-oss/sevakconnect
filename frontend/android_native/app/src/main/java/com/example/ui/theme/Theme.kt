package com.example.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val SurfaceTint = PrimaryColor

private val DharmaLightColorScheme = lightColorScheme(
    primary = PrimaryColor,
    onPrimary = OnPrimaryColor,
    primaryContainer = PrimaryContainerColor,
    onPrimaryContainer = OnPrimaryContainerColor,
    inversePrimary = InversePrimaryColor,
    
    secondary = SecondaryColor,
    onSecondary = OnSecondaryColor,
    secondaryContainer = SecondaryContainerColor,
    onSecondaryContainer = OnSecondaryContainerColor,
    
    tertiary = TertiaryColor,
    onTertiary = OnTertiaryColor,
    tertiaryContainer = TertiaryContainerColor,
    onTertiaryContainer = OnTertiaryContainerColor,
    
    background = SurfaceColor,
    onBackground = OnSurfaceColor,
    
    surface = SurfaceColor,
    onSurface = OnSurfaceColor,
    surfaceVariant = SurfaceVariantColor,
    onSurfaceVariant = OnSurfaceVariantColor,
    surfaceTint = SurfaceTint,
    
    error = ErrorColor,
    onError = OnErrorColor,
    errorContainer = ErrorContainerColor,
    onErrorContainer = OnErrorContainerColor,
    
    outline = OutlineColor,
    outlineVariant = OutlineVariantColor,
    
    inverseSurface = InverseSurfaceColor,
    inverseOnSurface = InverseOnSurfaceColor
)

@Composable
fun SevakConnectTheme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = DharmaLightColorScheme,
        typography = Typography,
        content = content
    )
}

