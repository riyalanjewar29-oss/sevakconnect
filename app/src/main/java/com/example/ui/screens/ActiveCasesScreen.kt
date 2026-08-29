package com.example.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.R
import com.example.data.model.MissingPersonItem
import com.example.data.model.MissingStatus
import com.example.data.repository.SevakRepository
import com.example.ui.components.OfflineBanner
import com.example.ui.components.SevakTopAppBar
import com.example.ui.navigation.Screen
import com.example.ui.theme.*

@Composable
fun ActiveCasesScreen(
    repository: SevakRepository,
    onBack: () -> Unit,
    onReportMissing: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isOnline by repository.isOnline.collectAsState()
    val cases by repository.missingCases.collectAsState()
    var selectedPersonDetails by remember { mutableStateOf<MissingPersonItem?>(null) }

    Scaffold(
        topBar = {
            Column {
                SevakTopAppBar(
                    title = "Active Cases",
                    showBackButton = true,
                    onBackClick = onBack,
                    isOnline = isOnline,
                    onOfflineToggleClick = { repository.toggleOnlineStatus() }
                )
                OfflineBanner(isOnline = isOnline)
            }
        },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                onClick = onReportMissing,
                containerColor = PrimaryColor,
                contentColor = OnPrimaryColor,
                shape = RoundedCornerShape(999.dp),
                modifier = Modifier.testTag("report_missing_fab")
            ) {
                Icon(Icons.Default.PersonAdd, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = "Report Missing",
                    style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold)
                )
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
            Column {
                Text(
                    text = "Active Cases",
                    style = MaterialTheme.typography.displayLarge.copy(
                        fontWeight = FontWeight.Bold,
                        color = OnSurfaceColor,
                        fontSize = 26.sp
                    )
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = "Showing open reports • ${cases.size} Cases Active",
                    style = MaterialTheme.typography.bodyMedium.copy(
                        color = OnSurfaceVariantColor
                    )
                )
            }

            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.weight(1f)
            ) {
                items(cases) { person ->
                    MissingPersonCard(
                        person = person,
                        onClick = { selectedPersonDetails = person }
                    )
                }
            }
        }
    }

    selectedPersonDetails?.let { person ->
        AlertDialog(
            onDismissRequest = { selectedPersonDetails = null },
            title = {
                Text(
                    text = "${person.name} (${person.age} yrs)",
                    style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Bold)
                )
            },
            text = {
                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text("Status: ${person.status.name}", fontWeight = FontWeight.Bold, color = PrimaryColor)
                    Text("Location: ${person.location}")
                    Text("Reported: ${person.reportedTime}")
                    if (person.notes.isNotBlank()) {
                        Text("Notes: ${person.notes}", style = MaterialTheme.typography.bodySmall)
                    }
                    if (person.clothingTags.isNotEmpty()) {
                        Text("Clothing: ${person.clothingTags.joinToString(", ")}", style = MaterialTheme.typography.bodySmall)
                    }
                }
            },
            confirmButton = {
                Button(
                    onClick = { selectedPersonDetails = null },
                    colors = ButtonDefaults.buttonColors(containerColor = PrimaryColor)
                ) {
                    Text("Found / Match Sighting")
                }
            },
            dismissButton = {
                TextButton(onClick = { selectedPersonDetails = null }) {
                    Text("Close")
                }
            }
        )
    }
}

@Composable
private fun MissingPersonCard(
    person: MissingPersonItem,
    onClick: () -> Unit
) {
    val (badgeBg, badgeColor, badgeText) = when (person.status) {
        MissingStatus.CRITICAL -> Triple(CriticalRedBg, CriticalRed, "CRITICAL")
        MissingStatus.SEARCHING -> Triple(HighOrangeBg, HighOrange, "SEARCHING")
        MissingStatus.PENDING_MATCH -> Triple(SecondaryFixed, SecondaryColor, "PENDING MATCH")
    }

    Surface(
        shape = RoundedCornerShape(14.dp),
        color = SurfaceContainerLowest,
        border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
        shadowElevation = 1.dp,
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .testTag("missing_card_${person.id}")
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            horizontalArrangement = Arrangement.spacedBy(14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Photo / Avatar Box
            Box(
                modifier = Modifier
                    .size(74.dp)
                    .clip(RoundedCornerShape(10.dp))
                    .background(SurfaceContainerHigh)
                    .border(1.dp, OutlineVariantColor, RoundedCornerShape(10.dp)),
                contentAlignment = Alignment.Center
            ) {
                if (person.imageRes != null) {
                    Image(
                        painter = painterResource(id = person.imageRes),
                        contentDescription = person.name,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.fillMaxSize()
                    )
                } else {
                    Icon(
                        imageVector = Icons.Default.Person,
                        contentDescription = null,
                        tint = OnSurfaceVariantColor,
                        modifier = Modifier.size(36.dp)
                    )
                }
            }

            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "${person.name}, ${person.age}",
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = OnSurfaceColor
                        )
                    )
                    Surface(
                        shape = RoundedCornerShape(4.dp),
                        color = badgeBg
                    ) {
                        Text(
                            text = badgeText,
                            style = MaterialTheme.typography.labelSmall.copy(
                                fontWeight = FontWeight.Bold,
                                color = badgeColor,
                                fontSize = 10.sp
                            ),
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                }

                Text(
                    text = person.reportedTime,
                    style = MaterialTheme.typography.labelSmall.copy(
                        color = OnSurfaceVariantColor,
                        fontSize = 11.sp
                    )
                )

                if (person.clothingTags.isNotEmpty()) {
                    Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        person.clothingTags.forEach { tag ->
                            Surface(
                                shape = RoundedCornerShape(4.dp),
                                color = SurfaceContainerHigh
                            ) {
                                Text(
                                    text = tag,
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        fontSize = 10.sp,
                                        color = OnSurfaceVariantColor
                                    ),
                                    modifier = Modifier.padding(horizontal = 5.dp, vertical = 1.dp)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
