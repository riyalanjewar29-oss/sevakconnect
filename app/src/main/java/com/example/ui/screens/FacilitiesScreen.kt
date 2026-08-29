package com.example.ui.screens

import android.widget.Toast
import androidx.compose.foundation.Canvas
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
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.FacilityItem
import com.example.data.model.FacilityStatus
import com.example.data.model.FacilityType
import com.example.data.repository.SevakRepository
import com.example.ui.components.OfflineBanner
import com.example.ui.components.SevakTopAppBar
import com.example.ui.theme.*

@Composable
fun FacilitiesScreen(
    repository: SevakRepository,
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val isOnline by repository.isOnline.collectAsState()
    val facilities by repository.facilities.collectAsState()

    var isMapView by remember { mutableStateOf(false) }
    var selectedFilter by remember { mutableStateOf(FacilityType.ALL) }
    var selectedFacilityDetail by remember { mutableStateOf<FacilityItem?>(null) }

    val filteredFacilities = facilities.filter {
        selectedFilter == FacilityType.ALL || it.type == selectedFilter
    }

    Scaffold(
        topBar = {
            Column {
                SevakTopAppBar(
                    title = "Facilities",
                    showBackButton = true,
                    onBackClick = onBack,
                    isOnline = isOnline,
                    onOfflineToggleClick = { repository.toggleOnlineStatus() }
                )
                OfflineBanner(isOnline = isOnline)
            }
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = {
                    Toast.makeText(context, "Add Facility form ready", Toast.LENGTH_SHORT).show()
                },
                containerColor = PrimaryColor,
                contentColor = OnPrimaryColor,
                shape = CircleShape,
                modifier = Modifier.testTag("add_facility_fab")
            ) {
                Icon(Icons.Default.Add, contentDescription = "Add Facility")
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
            // View Toggle: List View vs Map View
            Surface(
                shape = RoundedCornerShape(8.dp),
                color = SurfaceContainerLowest,
                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                shadowElevation = 1.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(modifier = Modifier.padding(4.dp)) {
                    Surface(
                        shape = RoundedCornerShape(6.dp),
                        color = if (!isMapView) PrimaryContainerColor else Color.Transparent,
                        modifier = Modifier
                            .weight(1f)
                            .clickable { isMapView = false }
                            .testTag("toggle_list_view")
                    ) {
                        Row(
                            modifier = Modifier.padding(vertical = 8.dp),
                            horizontalArrangement = Arrangement.Center,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(Icons.Default.FormatListBulleted, contentDescription = null, modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                text = "List View",
                                style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold)
                            )
                        }
                    }

                    Surface(
                        shape = RoundedCornerShape(6.dp),
                        color = if (isMapView) PrimaryContainerColor else Color.Transparent,
                        modifier = Modifier
                            .weight(1f)
                            .clickable { isMapView = true }
                            .testTag("toggle_map_view")
                    ) {
                        Row(
                            modifier = Modifier.padding(vertical = 8.dp),
                            horizontalArrangement = Arrangement.Center,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(Icons.Default.Map, contentDescription = null, modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                text = "Map View",
                                style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold)
                            )
                        }
                    }
                }
            }

            // Filter Chips
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                FilterChipItem("All", selectedFilter == FacilityType.ALL) { selectedFilter = FacilityType.ALL }
                FilterChipItem("Medical", selectedFilter == FacilityType.MEDICAL) { selectedFilter = FacilityType.MEDICAL }
                FilterChipItem("Water", selectedFilter == FacilityType.WATER) { selectedFilter = FacilityType.WATER }
                FilterChipItem("Toilet", selectedFilter == FacilityType.TOILET) { selectedFilter = FacilityType.TOILET }
            }

            if (!isMapView) {
                // List View
                LazyColumn(
                    verticalArrangement = Arrangement.spacedBy(10.dp),
                    modifier = Modifier.weight(1f)
                ) {
                    items(filteredFacilities) { item ->
                        FacilityCard(item = item, onClick = { selectedFacilityDetail = item })
                    }
                }
            } else {
                // Map Canvas View
                Surface(
                    shape = RoundedCornerShape(14.dp),
                    color = SurfaceContainerLowest,
                    border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f)
                ) {
                    Box(modifier = Modifier.fillMaxSize()) {
                        Canvas(modifier = Modifier.fillMaxSize()) {
                            // Draw pilgrimage route path
                            drawLine(
                                color = PrimaryColor.copy(alpha = 0.4f),
                                start = Offset(size.width * 0.2f, size.height * 0.1f),
                                end = Offset(size.width * 0.5f, size.height * 0.4f),
                                strokeWidth = 8f
                            )
                            drawLine(
                                color = PrimaryColor.copy(alpha = 0.4f),
                                start = Offset(size.width * 0.5f, size.height * 0.4f),
                                end = Offset(size.width * 0.7f, size.height * 0.85f),
                                strokeWidth = 8f
                            )

                            // Facility Nodes
                            drawCircle(color = ErrorColor, radius = 18f, center = Offset(size.width * 0.35f, size.height * 0.25f))
                            drawCircle(color = SecondaryColor, radius = 18f, center = Offset(size.width * 0.5f, size.height * 0.45f))
                            drawCircle(color = NormalGreen, radius = 18f, center = Offset(size.width * 0.65f, size.height * 0.7f))
                        }

                        Column(
                            modifier = Modifier
                                .align(Alignment.BottomCenter)
                                .fillMaxWidth()
                                .padding(12.dp)
                        ) {
                            Surface(
                                shape = RoundedCornerShape(10.dp),
                                color = SurfaceContainerHighest,
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Row(
                                    modifier = Modifier.padding(10.dp),
                                    horizontalArrangement = Arrangement.SpaceAround
                                ) {
                                    LegendItem(color = ErrorColor, label = "Medical")
                                    LegendItem(color = SecondaryColor, label = "Water")
                                    LegendItem(color = NormalGreen, label = "Toilets")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    selectedFacilityDetail?.let { f ->
        AlertDialog(
            onDismissRequest = { selectedFacilityDetail = null },
            title = { Text(f.name, fontWeight = FontWeight.Bold) },
            text = {
                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text("Type: ${f.type.name}")
                    Text("Location: ${f.locationName}")
                    Text("Distance: ${f.distance}")
                    Text("Status: ${f.lastUpdated}", fontWeight = FontWeight.Bold, color = PrimaryColor)
                }
            },
            confirmButton = {
                Button(
                    onClick = { selectedFacilityDetail = null },
                    colors = ButtonDefaults.buttonColors(containerColor = PrimaryColor)
                ) {
                    Text("Navigate to Pin")
                }
            },
            dismissButton = {
                TextButton(onClick = { selectedFacilityDetail = null }) {
                    Text("Close")
                }
            }
        )
    }
}

@Composable
private fun FilterChipItem(label: String, isSelected: Boolean, onClick: () -> Unit) {
    Surface(
        shape = RoundedCornerShape(999.dp),
        color = if (isSelected) SecondaryContainerColor else SurfaceContainerLowest,
        border = androidx.compose.foundation.BorderStroke(
            1.dp,
            if (isSelected) SecondaryColor else OutlineVariantColor
        ),
        modifier = Modifier.clickable { onClick() }
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall.copy(
                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                color = if (isSelected) OnSecondaryContainerColor else OnSurfaceColor
            ),
            modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp)
        )
    }
}

@Composable
private fun FacilityCard(item: FacilityItem, onClick: () -> Unit) {
    val (typeIcon, typeBg, typeColor) = when (item.type) {
        FacilityType.MEDICAL -> Triple(Icons.Default.MedicalServices, CriticalRedBg, CriticalRed)
        FacilityType.WATER -> Triple(Icons.Default.LocalDrink, SecondaryFixed, SecondaryColor)
        FacilityType.TOILET -> Triple(Icons.Default.Wc, NormalGreenBg, NormalGreen)
        FacilityType.ALL -> Triple(Icons.Default.Place, SurfaceContainerHigh, OnSurfaceVariantColor)
    }

    Surface(
        shape = RoundedCornerShape(12.dp),
        color = SurfaceContainerLowest,
        border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
        shadowElevation = 1.dp,
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .testTag("facility_card_${item.id}")
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(typeBg),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = typeIcon,
                    contentDescription = null,
                    tint = typeColor,
                    modifier = Modifier.size(22.dp)
                )
            }

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = item.name,
                    style = MaterialTheme.typography.titleMedium.copy(
                        fontWeight = FontWeight.Bold,
                        color = OnSurfaceColor
                    )
                )
                Text(
                    text = "${item.locationName} • ${item.distance}",
                    style = MaterialTheme.typography.labelSmall.copy(
                        color = OnSurfaceVariantColor
                    )
                )
            }

            Surface(
                shape = RoundedCornerShape(4.dp),
                color = if (item.status == FacilityStatus.ACTIVE) NormalGreenBg else WarningYellowBg
            ) {
                Text(
                    text = item.lastUpdated,
                    style = MaterialTheme.typography.labelSmall.copy(
                        fontWeight = FontWeight.Bold,
                        color = if (item.status == FacilityStatus.ACTIVE) NormalGreen else WarningYellow,
                        fontSize = 11.sp
                    ),
                    modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                )
            }
        }
    }
}

@Composable
private fun LegendItem(color: Color, label: String) {
    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
        Box(modifier = Modifier.size(10.dp).clip(CircleShape).background(color))
        Text(text = label, style = MaterialTheme.typography.labelSmall.copy(fontSize = 11.sp))
    }
}
