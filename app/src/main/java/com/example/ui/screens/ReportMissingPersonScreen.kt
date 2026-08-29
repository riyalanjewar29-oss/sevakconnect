package com.example.ui.screens

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.MissingPersonItem
import com.example.data.model.MissingStatus
import com.example.data.repository.SevakRepository
import com.example.ui.components.OfflineBanner
import com.example.ui.components.SevakTopAppBar
import com.example.ui.theme.*

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun ReportMissingPersonScreen(
    repository: SevakRepository,
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val isOnline by repository.isOnline.collectAsState()

    var fullName by remember { mutableStateOf("") }
    var age by remember { mutableStateOf("") }
    var isMinor by remember { mutableStateOf(false) }
    var locationName by remember { mutableStateOf("Sector 4, Near Main Temple Gate") }
    var notes by remember { mutableStateOf("") }
    var hasPhotoSelected by remember { mutableStateOf(false) }

    val clothingOptions = listOf("Saffron", "White", "Cotton", "Woolen", "Barefoot", "Cap / Pagdi")
    val selectedClothing = remember { mutableStateListOf("Saffron", "Cotton") }

    Scaffold(
        topBar = {
            Column {
                SevakTopAppBar(
                    title = "Report Missing Person",
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
            // Photo Upload Box
            Surface(
                shape = RoundedCornerShape(12.dp),
                color = if (hasPhotoSelected) SecondaryFixed else SurfaceContainerLow,
                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(130.dp)
                    .clickable {
                        hasPhotoSelected = !hasPhotoSelected
                        Toast.makeText(context, if (hasPhotoSelected) "Photo Attached ✓" else "Photo Removed", Toast.LENGTH_SHORT).show()
                    }
                    .testTag("add_photo_box")
            ) {
                Column(
                    modifier = Modifier.fillMaxSize(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Icon(
                        imageVector = if (hasPhotoSelected) Icons.Default.CheckCircle else Icons.Default.AddAPhoto,
                        contentDescription = "Add Photo",
                        tint = PrimaryColor,
                        modifier = Modifier.size(32.dp)
                    )
                    Spacer(modifier = Modifier.height(6.dp))
                    Text(
                        text = if (hasPhotoSelected) "Photo Attached Successfully" else "Tap to add photo",
                        style = MaterialTheme.typography.labelLarge.copy(
                            fontWeight = FontWeight.SemiBold,
                            color = OnSurfaceColor
                        )
                    )
                    Text(
                        text = "Helps volunteer facial recognition",
                        style = MaterialTheme.typography.labelSmall.copy(
                            color = OnSurfaceVariantColor,
                            fontSize = 11.sp
                        )
                    )
                }
            }

            // Full Name
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(
                    text = "Full Name",
                    style = MaterialTheme.typography.labelMedium.copy(
                        fontWeight = FontWeight.Bold,
                        color = OnSurfaceColor
                    )
                )
                OutlinedTextField(
                    value = fullName,
                    onValueChange = { fullName = it },
                    placeholder = { Text("Enter person's name") },
                    shape = RoundedCornerShape(8.dp),
                    modifier = Modifier.fillMaxWidth().testTag("missing_name_input")
                )
            }

            // Approximate Age & Minor switch
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(
                        text = "Approximate Age",
                        style = MaterialTheme.typography.labelMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = OnSurfaceColor
                        )
                    )
                    OutlinedTextField(
                        value = age,
                        onValueChange = {
                            age = it
                            val num = it.toIntOrNull()
                            if (num != null && num < 18) isMinor = true
                        },
                        placeholder = { Text("e.g. 45") },
                        shape = RoundedCornerShape(8.dp),
                        modifier = Modifier.fillMaxWidth().testTag("missing_age_input")
                    )
                }

                Surface(
                    shape = RoundedCornerShape(8.dp),
                    color = SurfaceContainerLowest,
                    border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                    modifier = Modifier.weight(1.2f).padding(top = 18.dp)
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column {
                            Text("Is Minor?", style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold))
                            Text("Under 18", style = MaterialTheme.typography.labelSmall.copy(color = OnSurfaceVariantColor, fontSize = 10.sp))
                        }
                        Switch(
                            checked = isMinor,
                            onCheckedChange = { isMinor = it },
                            colors = SwitchDefaults.colors(
                                checkedThumbColor = Color.White,
                                checkedTrackColor = PrimaryColor
                            )
                        )
                    }
                }
            }

            // Current Location Card
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
                            text = "Last Seen Location",
                            style = MaterialTheme.typography.labelSmall.copy(
                                color = OnSurfaceVariantColor,
                                fontWeight = FontWeight.Bold
                            )
                        )
                        Spacer(modifier = Modifier.height(2.dp))
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Icon(Icons.Default.LocationOn, contentDescription = null, tint = PrimaryColor, modifier = Modifier.size(16.dp))
                            Text(
                                text = locationName,
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = OnSurfaceColor
                                )
                            )
                        }
                    }
                    TextButton(onClick = { /* edit location */ }) {
                        Text("Edit", color = PrimaryColor, fontWeight = FontWeight.Bold)
                    }
                }
            }

            // Clothing & Appearance
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = "CLOTHING & APPEARANCE",
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
                    clothingOptions.forEach { opt ->
                        val isSelected = selectedClothing.contains(opt)
                        FilterChip(
                            selected = isSelected,
                            onClick = {
                                if (isSelected) selectedClothing.remove(opt)
                                else selectedClothing.add(opt)
                            },
                            label = { Text(opt) },
                            colors = FilterChipDefaults.filterChipColors(
                                selectedContainerColor = PrimaryFixed,
                                selectedLabelColor = OnPrimaryFixed
                            ),
                            shape = RoundedCornerShape(8.dp)
                        )
                    }
                }
            }

            // Additional Notes
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(
                    text = "Distinguishing Marks & Details",
                    style = MaterialTheme.typography.labelMedium.copy(
                        fontWeight = FontWeight.Bold,
                        color = OnSurfaceColor
                    )
                )
                OutlinedTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    placeholder = { Text("e.g. carrying saffron bag, speaks Marathi only, walking stick...") },
                    shape = RoundedCornerShape(8.dp),
                    modifier = Modifier.fillMaxWidth().height(80.dp)
                )
            }

            // Submit Alert Button
            Button(
                onClick = {
                    if (fullName.isNotBlank()) {
                        repository.addMissingPerson(
                            MissingPersonItem(
                                id = System.currentTimeMillis().toString(),
                                name = fullName,
                                age = age.toIntOrNull() ?: 30,
                                isMinor = isMinor,
                                status = MissingStatus.CRITICAL,
                                reportedTime = "Reported just now",
                                location = locationName,
                                clothingTags = selectedClothing.toList(),
                                notes = notes
                            )
                        )
                        Toast.makeText(context, "Missing Person Alert Broadcasted!", Toast.LENGTH_LONG).show()
                        onBack()
                    } else {
                        Toast.makeText(context, "Please enter the person's name", Toast.LENGTH_SHORT).show()
                    }
                },
                colors = ButtonDefaults.buttonColors(
                    containerColor = PrimaryColor,
                    contentColor = OnPrimaryColor
                ),
                shape = RoundedCornerShape(999.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp)
                    .testTag("submit_missing_alert_button")
            ) {
                Icon(Icons.Default.Campaign, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Submit Alert",
                    style = MaterialTheme.typography.labelLarge.copy(
                        fontWeight = FontWeight.Bold,
                        fontSize = 16.sp
                    )
                )
            }

            Spacer(modifier = Modifier.height(20.dp))
        }
    }
}
