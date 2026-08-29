package com.example.ui.screens

import android.widget.Toast
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.CrowdSeverity
import com.example.data.repository.SevakRepository
import com.example.ui.components.OfflineBanner
import com.example.ui.components.SevakTopAppBar
import com.example.ui.theme.*

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun ReportCrowdScreen(
    repository: SevakRepository,
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val isOnline by repository.isOnline.collectAsState()

    var selectedSeverity by remember { mutableStateOf(CrowdSeverity.HIGH) }
    var locationName by remember { mutableStateOf("Chandrabhaga Ghat — Zone 3B") }
    var additionalNotes by remember { mutableStateOf("") }
    var isSubmitted by remember { mutableStateOf(false) }

    val observationOptions = listOf(
        "Narrow Passage",
        "Stalled Queue",
        "Barricade",
        "Medical Event Nearby",
        "Heat-Related",
        "Slow movement",
        "Exit blocked"
    )
    val selectedObservations = remember { mutableStateListOf("Narrow Passage", "Stalled Queue") }

    Scaffold(
        topBar = {
            Column {
                SevakTopAppBar(
                    title = "Report Crowd",
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
            // Location Card
            Surface(
                shape = RoundedCornerShape(12.dp),
                color = SurfaceContainerLowest,
                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                shadowElevation = 1.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(14.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = locationName,
                            style = MaterialTheme.typography.titleMedium.copy(
                                fontWeight = FontWeight.Bold,
                                color = OnSurfaceColor
                            )
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Text(
                            text = "GPS auto-detected • Just now",
                            style = MaterialTheme.typography.labelSmall.copy(
                                color = OnSurfaceVariantColor
                            )
                        )
                    }
                    TextButton(onClick = { /* change location */ }) {
                        Text("Change", color = PrimaryColor, fontWeight = FontWeight.Bold)
                    }
                }
            }

            // Real-time volunteer insight card
            Surface(
                shape = RoundedCornerShape(10.dp),
                color = WarningYellowBg,
                border = androidx.compose.foundation.BorderStroke(1.dp, WarningYellow.copy(alpha = 0.5f)),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Groups,
                        contentDescription = null,
                        tint = OnPrimaryContainerColor,
                        modifier = Modifier.size(20.dp)
                    )
                    Text(
                        text = "3 other volunteers reported MODERATE crowd near here in the last 15 minutes.",
                        style = MaterialTheme.typography.bodySmall.copy(
                            color = OnPrimaryContainerColor,
                            fontWeight = FontWeight.Medium
                        )
                    )
                }
            }

            // Step 1: Select Crowd Level
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "SELECT CROWD LEVEL",
                    style = MaterialTheme.typography.labelSmall.copy(
                        color = OnSurfaceVariantColor,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    SeverityButton(
                        label = "NORMAL",
                        isSelected = selectedSeverity == CrowdSeverity.NORMAL,
                        activeColor = NormalGreen,
                        activeBg = NormalGreenBg,
                        onClick = { selectedSeverity = CrowdSeverity.NORMAL },
                        modifier = Modifier.weight(1f)
                    )
                    SeverityButton(
                        label = "MODERATE",
                        isSelected = selectedSeverity == CrowdSeverity.MODERATE,
                        activeColor = WarningYellow,
                        activeBg = WarningYellowBg,
                        onClick = { selectedSeverity = CrowdSeverity.MODERATE },
                        modifier = Modifier.weight(1f)
                    )
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    SeverityButton(
                        label = "HIGH",
                        isSelected = selectedSeverity == CrowdSeverity.HIGH,
                        activeColor = HighOrange,
                        activeBg = HighOrangeBg,
                        onClick = { selectedSeverity = CrowdSeverity.HIGH },
                        modifier = Modifier.weight(1f)
                    )
                    SeverityButton(
                        label = "CRITICAL",
                        isSelected = selectedSeverity == CrowdSeverity.CRITICAL,
                        activeColor = CriticalRed,
                        activeBg = CriticalRedBg,
                        onClick = { selectedSeverity = CrowdSeverity.CRITICAL },
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            // Quick Observation Chips
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "QUICK OBSERVATIONS",
                    style = MaterialTheme.typography.labelSmall.copy(
                        color = OnSurfaceVariantColor,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                )

                FlowRow(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    observationOptions.forEach { obs ->
                        val isChecked = selectedObservations.contains(obs)
                        FilterChip(
                            selected = isChecked,
                            onClick = {
                                if (isChecked) selectedObservations.remove(obs)
                                else selectedObservations.add(obs)
                            },
                            label = { Text(obs) },
                            colors = FilterChipDefaults.filterChipColors(
                                selectedContainerColor = SecondaryContainerColor,
                                selectedLabelColor = OnSecondaryContainerColor
                            ),
                            shape = RoundedCornerShape(8.dp)
                        )
                    }
                }
            }

            // Additional Notes
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(
                    text = "ADDITIONAL NOTES",
                    style = MaterialTheme.typography.labelSmall.copy(
                        color = OnSurfaceVariantColor,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    )
                )

                OutlinedTextField(
                    value = additionalNotes,
                    onValueChange = { additionalNotes = it },
                    placeholder = { Text("Add details (e.g., landmark, urgency)...") },
                    shape = RoundedCornerShape(8.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(90.dp)
                )
            }

            // Submit Button
            Button(
                onClick = {
                    isSubmitted = true
                    Toast.makeText(context, "Crowd Alert Broadcasted to Team!", Toast.LENGTH_SHORT).show()
                },
                colors = ButtonDefaults.buttonColors(
                    containerColor = PrimaryColor,
                    contentColor = OnPrimaryColor
                ),
                shape = RoundedCornerShape(999.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp)
                    .testTag("submit_crowd_report_button")
            ) {
                Icon(Icons.Default.Send, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "SUBMIT & ALERT NEARBY TEAM",
                    style = MaterialTheme.typography.labelLarge.copy(
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.5.sp
                    )
                )
            }

            // Resolution Progress Tracker (When submitted or active)
            AnimatedVisibility(visible = isSubmitted) {
                Surface(
                    shape = RoundedCornerShape(12.dp),
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
                            text = "Resolution Tracker",
                            style = MaterialTheme.typography.titleMedium.copy(
                                fontWeight = FontWeight.Bold,
                                color = OnSurfaceColor
                            )
                        )

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            TrackerNode("Reported", isDone = true)
                            Box(modifier = Modifier.weight(1f).height(2.dp).background(NormalGreen))
                            TrackerNode("Assigned", isDone = true)
                            Box(modifier = Modifier.weight(1f).height(2.dp).background(PrimaryColor))
                            TrackerNode("Enroute", isDone = false)
                            Box(modifier = Modifier.weight(1f).height(2.dp).background(SurfaceVariantColor))
                            TrackerNode("Resolved", isDone = false)
                        }

                        Surface(
                            shape = RoundedCornerShape(8.dp),
                            color = SecondaryFixed,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Row(
                                modifier = Modifier.padding(10.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                Icon(Icons.Default.DirectionsWalk, contentDescription = null, tint = OnSecondaryFixed)
                                Column {
                                    Text("Assigned: Rahul Patil (0.4 km away)", style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold, color = OnSecondaryFixed))
                                    Text("ETA to Ghat: 3 minutes", style = MaterialTheme.typography.labelSmall.copy(color = OnSecondaryFixed))
                                }
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(24.dp))
        }
    }
}

@Composable
private fun SeverityButton(
    label: String,
    isSelected: Boolean,
    activeColor: Color,
    activeBg: Color,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        shape = RoundedCornerShape(8.dp),
        color = if (isSelected) activeBg else SurfaceContainerLowest,
        border = androidx.compose.foundation.BorderStroke(
            width = if (isSelected) 2.dp else 1.dp,
            color = if (isSelected) activeColor else OutlineVariantColor
        ),
        modifier = modifier
            .height(48.dp)
            .clickable { onClick() }
    ) {
        Box(contentAlignment = Alignment.Center) {
            Text(
                text = label,
                style = MaterialTheme.typography.labelLarge.copy(
                    fontWeight = FontWeight.Bold,
                    color = if (isSelected) activeColor else OnSurfaceColor
                )
            )
        }
    }
}

@Composable
private fun TrackerNode(
    label: String,
    isDone: Boolean
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(3.dp)
    ) {
        Icon(
            imageVector = if (isDone) Icons.Default.CheckCircle else Icons.Default.RadioButtonUnchecked,
            contentDescription = null,
            tint = if (isDone) NormalGreen else OnSurfaceVariantColor,
            modifier = Modifier.size(18.dp)
        )
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall.copy(
                fontSize = 10.sp,
                fontWeight = if (isDone) FontWeight.Bold else FontWeight.Normal,
                color = if (isDone) OnSurfaceColor else OnSurfaceVariantColor
            )
        )
    }
}
