package com.example.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.repository.SevakRepository
import com.example.ui.theme.*

@Composable
fun SosAlertScreen(
    repository: SevakRepository,
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    val sosState by repository.sosState.collectAsState()

    val infiniteTransition = rememberInfiniteTransition(label = "pulse")
    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.08f,
        animationSpec = infiniteRepeatable(
            animation = tween(900, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulseScale"
    )

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(SurfaceColor)
    ) {
        // Red Emergency Header
        Surface(
            color = ErrorColor,
            modifier = Modifier.fillMaxWidth()
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .statusBarsPadding()
                    .height(56.dp)
                    .padding(horizontal = 16.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                IconButton(
                    onClick = onBack,
                    modifier = Modifier.testTag("sos_back_button")
                ) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = "Back",
                        tint = Color.White
                    )
                }

                Text(
                    text = "EMERGENCY",
                    style = MaterialTheme.typography.titleLarge.copy(
                        fontWeight = FontWeight.Black,
                        color = Color.White,
                        letterSpacing = 2.sp
                    )
                )
            }
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Top Location Card
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = "SOS ALERT",
                        style = MaterialTheme.typography.displayLarge.copy(
                            fontWeight = FontWeight.Black,
                            color = ErrorColor,
                            fontSize = 28.sp
                        ),
                        textAlign = TextAlign.Center
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "Confirm immediately to broadcast your location to all nearby volunteers and command center.",
                        style = MaterialTheme.typography.bodyMedium.copy(
                            color = OnSurfaceVariantColor
                        ),
                        textAlign = TextAlign.Center
                    )
                }

                // Detected Location Card
                Surface(
                    shape = RoundedCornerShape(12.dp),
                    color = SurfaceContainerLowest,
                    border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                    shadowElevation = 1.dp,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Text(
                            text = "Detected Location",
                            style = MaterialTheme.typography.labelSmall.copy(
                                color = OnSurfaceVariantColor,
                                fontWeight = FontWeight.Bold
                            )
                        )
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.LocationOn,
                                contentDescription = null,
                                tint = ErrorColor,
                                modifier = Modifier.size(20.dp)
                            )
                            Text(
                                text = sosState.locationName,
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = OnSurfaceColor
                                )
                            )
                        }
                        Text(
                            text = sosState.coordinates,
                            style = MaterialTheme.typography.labelSmall.copy(
                                fontFamily = FontFamily.Monospace,
                                color = OnSurfaceVariantColor
                            )
                        )
                    }
                }
            }

            // Giant Pulsing SOS Button (Center)
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.padding(vertical = 12.dp)
            ) {
                // Pulse halo
                Box(
                    modifier = Modifier
                        .size(190.dp)
                        .scale(if (sosState.isTriggered) pulseScale else 1f)
                        .clip(CircleShape)
                        .background(
                            if (sosState.isTriggered) ErrorColor.copy(alpha = 0.2f)
                            else CriticalRedBg
                        )
                )

                Surface(
                    shape = CircleShape,
                    color = ErrorColor,
                    shadowElevation = 10.dp,
                    modifier = Modifier
                        .size(150.dp)
                        .clickable {
                            if (!sosState.isTriggered) {
                                repository.triggerSosAlert()
                            } else {
                                repository.resetSosAlert()
                            }
                        }
                        .testTag("confirm_sos_button")
                ) {
                    Column(
                        modifier = Modifier.fillMaxSize(),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Icon(
                            imageVector = if (sosState.isTriggered) Icons.Default.CheckCircle else Icons.Default.Warning,
                            contentDescription = null,
                            tint = Color.White,
                            modifier = Modifier.size(42.dp)
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            text = if (sosState.isTriggered) "ACTIVE" else "CONFIRM SOS",
                            style = MaterialTheme.typography.labelLarge.copy(
                                fontWeight = FontWeight.Black,
                                color = Color.White,
                                fontSize = 15.sp,
                                letterSpacing = 1.sp
                            ),
                            textAlign = TextAlign.Center
                        )
                    }
                }
            }

            // Status List (Queued, Relayed via Mesh, Delivered)
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                StatusItem(
                    title = "Queued Locally",
                    subtitle = "Stored safely on device storage",
                    isComplete = sosState.isQueued,
                    icon = Icons.Default.SaveAlt
                )

                StatusItem(
                    title = "Relayed via Mesh (Simulated)",
                    subtitle = "Shared with 4 nearby volunteer nodes",
                    isComplete = sosState.isRelayed,
                    icon = Icons.Default.ShareLocation
                )

                StatusItem(
                    title = "Delivered to Command Center",
                    subtitle = "Emergency response dispatch notified",
                    isComplete = sosState.isDelivered,
                    icon = Icons.Default.LocalPolice
                )

                Spacer(modifier = Modifier.height(12.dp))

                OutlinedButton(
                    onClick = {
                        repository.resetSosAlert()
                    },
                    shape = RoundedCornerShape(999.dp),
                    colors = ButtonDefaults.outlinedButtonColors(
                        contentColor = OnSurfaceVariantColor
                    ),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(48.dp)
                        .testTag("reset_sos_button")
                ) {
                    Text(
                        text = "Reset / Test Mode",
                        style = MaterialTheme.typography.labelLarge.copy(
                            fontWeight = FontWeight.SemiBold
                        )
                    )
                }
            }
        }
    }
}

@Composable
private fun StatusItem(
    title: String,
    subtitle: String,
    isComplete: Boolean,
    icon: androidx.compose.ui.graphics.vector.ImageVector
) {
    Surface(
        shape = RoundedCornerShape(8.dp),
        color = if (isComplete) NormalGreenBg else SurfaceContainerLowest,
        border = androidx.compose.foundation.BorderStroke(
            1.dp,
            if (isComplete) NormalGreen else OutlineVariantColor
        ),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 14.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Icon(
                imageVector = if (isComplete) Icons.Default.CheckCircle else icon,
                contentDescription = null,
                tint = if (isComplete) NormalGreen else OnSurfaceVariantColor,
                modifier = Modifier.size(22.dp)
            )
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.labelLarge.copy(
                        fontWeight = FontWeight.Bold,
                        color = if (isComplete) NormalGreen else OnSurfaceColor
                    )
                )
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.labelSmall.copy(
                        fontSize = 11.sp,
                        color = OnSurfaceVariantColor
                    )
                )
            }
        }
    }
}
