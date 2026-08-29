package com.example.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.CrowdSeverity
import com.example.data.model.ZoneStatus
import com.example.data.repository.SevakRepository
import com.example.ui.components.OfflineBanner
import com.example.ui.components.SevakTopAppBar
import com.example.ui.navigation.Screen
import com.example.ui.theme.*

@Composable
fun ChandrabhagaZonesScreen(
    repository: SevakRepository,
    onBack: () -> Unit,
    onNavigateToReport: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isOnline by repository.isOnline.collectAsState()
    val zones by repository.zones.collectAsState()
    var selectedZoneForDetails by remember { mutableStateOf<ZoneStatus?>(null) }

    Scaffold(
        topBar = {
            Column {
                SevakTopAppBar(
                    title = "Chandrabhaga Zones",
                    showBackButton = true,
                    onBackClick = onBack,
                    isOnline = isOnline,
                    onOfflineToggleClick = { repository.toggleOnlineStatus() }
                )
                OfflineBanner(isOnline = isOnline)
            }
        },
        containerColor = SurfaceColor,
        modifier = modifier.fillMaxSize()
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            // Header Info
            Column {
                Text(
                    text = "Chandrabhaga Zones",
                    style = MaterialTheme.typography.displayLarge.copy(
                        fontWeight = FontWeight.Bold,
                        color = OnSurfaceColor,
                        fontSize = 26.sp
                    )
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "Live density monitoring for Ghats.",
                    style = MaterialTheme.typography.bodyMedium.copy(
                        color = OnSurfaceVariantColor
                    )
                )
            }

            // 2-Column Grid of Zones
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.weight(1f)
            ) {
                items(zones) { zone ->
                    ZoneCard(
                        zone = zone,
                        onClick = { selectedZoneForDetails = zone }
                    )
                }
            }

            // Bottom CTA to submit new report
            Button(
                onClick = onNavigateToReport,
                colors = ButtonDefaults.buttonColors(
                    containerColor = PrimaryColor,
                    contentColor = OnPrimaryColor
                ),
                shape = RoundedCornerShape(999.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(50.dp)
                    .testTag("zone_report_button")
            ) {
                Icon(Icons.Default.AddLocationAlt, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Submit Zone Observation",
                    style = MaterialTheme.typography.labelLarge.copy(
                        fontWeight = FontWeight.Bold
                    )
                )
            }
        }
    }

    // Detail Dialog
    selectedZoneForDetails?.let { zone ->
        AlertDialog(
            onDismissRequest = { selectedZoneForDetails = null },
            title = {
                Text(
                    text = "${zone.code} Details",
                    style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Bold)
                )
            },
            text = {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text("Location: ${zone.name}", style = MaterialTheme.typography.bodyMedium)
                    Text("Status: ${zone.severity.name}", style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold))
                    Text("Last updated: ${zone.timeAgo}", style = MaterialTheme.typography.bodySmall)
                    Text("Volunteers Active in this zone: 6", style = MaterialTheme.typography.bodySmall)
                }
            },
            confirmButton = {
                TextButton(onClick = { selectedZoneForDetails = null }) {
                    Text("Close", color = PrimaryColor)
                }
            }
        )
    }
}

@Composable
private fun ZoneCard(
    zone: ZoneStatus,
    onClick: () -> Unit
) {
    val (badgeBg, badgeTextColor, badgeLabel) = when (zone.severity) {
        CrowdSeverity.CRITICAL -> Triple(CriticalRedBg, CriticalRed, "Critical")
        CrowdSeverity.HIGH -> Triple(HighOrangeBg, HighOrange, "High")
        CrowdSeverity.MODERATE -> Triple(SecondaryFixed, SecondaryColor, "Elevated")
        CrowdSeverity.NORMAL -> Triple(SurfaceContainerHighest, OnSurfaceVariantColor, "Normal")
    }

    Surface(
        shape = RoundedCornerShape(14.dp),
        color = SurfaceContainerLowest,
        border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
        shadowElevation = 1.dp,
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .testTag("zone_card_${zone.code.lowercase().replace(" ", "_")}")
    ) {
        Column(
            modifier = Modifier.padding(14.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Top
            ) {
                Text(
                    text = zone.code,
                    style = MaterialTheme.typography.titleLarge.copy(
                        fontWeight = FontWeight.Bold,
                        color = OnSurfaceColor
                    )
                )

                if (zone.hasBlockIcon) {
                    Icon(
                        imageVector = Icons.Default.Block,
                        contentDescription = "Blocked",
                        tint = CriticalRed,
                        modifier = Modifier.size(18.dp)
                    )
                } else if (zone.hasWarningIcon) {
                    Icon(
                        imageVector = Icons.Default.Warning,
                        contentDescription = "Warning",
                        tint = HighOrange,
                        modifier = Modifier.size(18.dp)
                    )
                }
            }

            Text(
                text = zone.name,
                style = MaterialTheme.typography.bodySmall.copy(
                    color = OnSurfaceVariantColor,
                    fontSize = 13.sp
                ),
                minLines = 2,
                maxLines = 2
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Surface(
                    shape = RoundedCornerShape(999.dp),
                    color = badgeBg
                ) {
                    Text(
                        text = badgeLabel,
                        style = MaterialTheme.typography.labelSmall.copy(
                            fontWeight = FontWeight.Bold,
                            color = badgeTextColor
                        ),
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                    )
                }

                Text(
                    text = zone.timeAgo,
                    style = MaterialTheme.typography.labelSmall.copy(
                        fontSize = 11.sp,
                        color = OnSurfaceVariantColor
                    )
                )
            }
        }
    }
}
