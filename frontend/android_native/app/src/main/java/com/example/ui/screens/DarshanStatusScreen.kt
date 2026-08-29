package com.example.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
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
import com.example.data.repository.SevakRepository
import com.example.ui.components.OfflineBanner
import com.example.ui.components.SevakTopAppBar
import com.example.ui.navigation.Screen
import com.example.ui.theme.*

@Composable
fun DarshanStatusScreen(
    repository: SevakRepository,
    onBack: () -> Unit,
    onNavigateToMap: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isOnline by repository.isOnline.collectAsState()
    var restModeEnabled by remember { mutableStateOf(false) }
    var isCheckedIn by remember { mutableStateOf(false) }
    var showQrDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            Column {
                SevakTopAppBar(
                    title = "Darshan Status",
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
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Simulation Disclaimer Banner
            Surface(
                shape = RoundedCornerShape(10.dp),
                color = SurfaceContainerHigh,
                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(12.dp),
                    verticalAlignment = Alignment.Top,
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Info,
                        contentDescription = null,
                        tint = PrimaryColor,
                        modifier = Modifier.size(20.dp)
                    )
                    Text(
                        text = "Proposed coordination mechanism, not yet validated. Currently running in simulation mode—no success data available.",
                        style = MaterialTheme.typography.bodySmall.copy(
                            color = OnSurfaceVariantColor,
                            fontSize = 12.sp,
                            lineHeight = 16.sp
                        )
                    )
                }
            }

            // State A: Assigned Window (Batch #A42)
            Surface(
                shape = RoundedCornerShape(14.dp),
                color = SurfaceContainerLowest,
                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                shadowElevation = 1.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Text(
                        text = "Assigned Window (Batch #A42)",
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = OnSurfaceColor
                        )
                    )

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Schedule,
                            contentDescription = null,
                            tint = PrimaryColor,
                            modifier = Modifier.size(22.dp)
                        )
                        Text(
                            text = "Time: 10:40 – 11:00",
                            style = MaterialTheme.typography.headlineMedium.copy(
                                fontWeight = FontWeight.Bold,
                                color = PrimaryColor,
                                fontSize = 20.sp
                            )
                        )
                    }

                    OutlinedButton(
                        onClick = { showQrDialog = true },
                        shape = RoundedCornerShape(8.dp),
                        colors = ButtonDefaults.outlinedButtonColors(
                            contentColor = PrimaryColor
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(48.dp)
                            .testTag("darshan_checkin_button")
                    ) {
                        Icon(
                            imageVector = Icons.Default.QrCodeScanner,
                            contentDescription = null,
                            modifier = Modifier.size(18.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = if (isCheckedIn) "Checked In ✓" else "Check In (QR / Manual)",
                            style = MaterialTheme.typography.labelLarge.copy(
                                fontWeight = FontWeight.Bold
                            )
                        )
                    }
                }
            }

            // State B: Queue Status (Live Status)
            Surface(
                shape = RoundedCornerShape(14.dp),
                color = SurfaceContainerLowest,
                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                shadowElevation = 1.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(
                            text = "Queue Status",
                            style = MaterialTheme.typography.titleMedium.copy(
                                fontWeight = FontWeight.Bold,
                                color = OnSurfaceColor
                            )
                        )
                        Surface(
                            shape = RoundedCornerShape(999.dp),
                            color = SecondaryContainerColor
                        ) {
                            Text(
                                text = "Live Status",
                                style = MaterialTheme.typography.labelSmall.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = OnSecondaryContainerColor
                                ),
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                            )
                        }
                    }

                    Text(
                        text = "Waiting / Resting - Holding Area B",
                        style = MaterialTheme.typography.bodyLarge.copy(
                            fontWeight = FontWeight.SemiBold,
                            color = OnSurfaceColor
                        )
                    )

                    HorizontalDivider(color = SurfaceVariantColor)

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(
                                text = "Rest Mode",
                                style = MaterialTheme.typography.labelLarge.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = OnSurfaceColor
                                )
                            )
                            Text(
                                text = "Pause notifications",
                                style = MaterialTheme.typography.bodySmall.copy(
                                    color = OnSurfaceVariantColor
                                )
                            )
                        }
                        Switch(
                            checked = restModeEnabled,
                            onCheckedChange = { restModeEnabled = it },
                            colors = SwitchDefaults.colors(
                                checkedThumbColor = Color.White,
                                checkedTrackColor = PrimaryColor
                            ),
                            modifier = Modifier.testTag("rest_mode_switch")
                        )
                    }

                    Text(
                        text = "We will ping your group 15 mins before your batch is called.",
                        style = MaterialTheme.typography.bodySmall.copy(
                            color = OnSurfaceVariantColor
                        )
                    )
                }
            }

            // State C: Action Required (Blue Alert Card)
            Surface(
                shape = RoundedCornerShape(14.dp),
                color = SecondaryFixed,
                border = androidx.compose.foundation.BorderStroke(1.dp, SecondaryContainerColor),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Campaign,
                            contentDescription = null,
                            tint = OnSecondaryFixed,
                            modifier = Modifier.size(22.dp)
                        )
                        Text(
                            text = "ACTION REQUIRED",
                            style = MaterialTheme.typography.labelLarge.copy(
                                fontWeight = FontWeight.Black,
                                color = OnSecondaryFixed,
                                letterSpacing = 1.sp
                            )
                        )
                    }

                    Text(
                        text = "Your slot is now - Please proceed immediately to the main gate.",
                        style = MaterialTheme.typography.bodyLarge.copy(
                            fontWeight = FontWeight.SemiBold,
                            color = OnSecondaryFixed
                        )
                    )

                    Button(
                        onClick = onNavigateToMap,
                        colors = ButtonDefaults.buttonColors(
                            containerColor = SecondaryColor,
                            contentColor = OnSecondaryColor
                        ),
                        shape = RoundedCornerShape(8.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(44.dp)
                            .testTag("view_route_map_button")
                    ) {
                        Text("View Route Map")
                        Spacer(modifier = Modifier.width(6.dp))
                        Icon(Icons.AutoMirrored.Filled.ArrowForward, contentDescription = null, modifier = Modifier.size(16.dp))
                    }
                }
            }
        }
    }

    if (showQrDialog) {
        AlertDialog(
            onDismissRequest = { showQrDialog = false },
            title = { Text("Scan / Check-in Batch", fontWeight = FontWeight.Bold) },
            text = {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Icon(
                        imageVector = Icons.Default.QrCodeScanner,
                        contentDescription = null,
                        tint = PrimaryColor,
                        modifier = Modifier.size(80.dp)
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text("Digital Darshan Pass: BATCH-A42-2026")
                    Text("Holding Area B -> Gate 1", style = MaterialTheme.typography.bodySmall)
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        isCheckedIn = true
                        showQrDialog = false
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = PrimaryColor)
                ) {
                    Text("Confirm Check-In")
                }
            },
            dismissButton = {
                TextButton(onClick = { showQrDialog = false }) {
                    Text("Cancel")
                }
            }
        )
    }
}
