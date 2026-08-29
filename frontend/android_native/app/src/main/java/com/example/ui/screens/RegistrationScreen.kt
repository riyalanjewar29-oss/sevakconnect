package com.example.ui.screens

import android.widget.Toast
import androidx.compose.animation.AnimatedVisibility
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
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.DindiMember
import com.example.data.repository.SevakRepository
import com.example.ui.components.OfflineBanner
import com.example.ui.components.SevakTopAppBar
import com.example.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RegistrationScreen(
    repository: SevakRepository,
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val isOnline by repository.isOnline.collectAsState()
    val dindiFormData by repository.dindiForm.collectAsState()

    var activeTab by remember { mutableStateOf("DHINDI") } // "DHINDI" or "INDIVIDUAL"
    var isMemberSectionExpanded by remember { mutableStateOf(true) }

    // Dindi Form state
    var dindiName by remember { mutableStateOf(dindiFormData.dindiName) }
    var regId by remember { mutableStateOf(dindiFormData.regId) }
    var leaderName by remember { mutableStateOf(dindiFormData.leaderName) }
    var mobileNumber by remember { mutableStateOf(dindiFormData.mobileNumber) }
    var memberEstimate by remember { mutableStateOf(dindiFormData.memberEstimate) }
    var arrivalZone by remember { mutableStateOf(dindiFormData.arrivalZone) }
    var expectedArrival by remember { mutableStateOf("08/30/2026, 02:30 PM") }
    var category by remember { mutableStateOf(dindiFormData.category) }

    // Individual Form state
    var indFullName by remember { mutableStateOf("") }
    var indAge by remember { mutableStateOf("") }
    var indGender by remember { mutableStateOf("Male") }
    var indMobile by remember { mutableStateOf("+91 ") }
    var indEmergency by remember { mutableStateOf("+91 ") }
    var indLocation by remember { mutableStateOf("") }
    var indArrival by remember { mutableStateOf("08/30/2026, 04:00 PM") }
    var indAssistance by remember { mutableStateOf("None Required") }

    // Add Member form inside Dindi
    var newMemberName by remember { mutableStateOf("") }
    var newMemberAge by remember { mutableStateOf("") }
    var newMemberGender by remember { mutableStateOf("Male") }
    var newMemberMobile by remember { mutableStateOf("") }
    var newMemberEmergency by remember { mutableStateOf("") }
    var newMemberAssistance by remember { mutableStateOf("None") }

    // Dropdown expansion states
    var zoneDropdownExpanded by remember { mutableStateOf(false) }
    var categoryDropdownExpanded by remember { mutableStateOf(false) }
    var indGenderExpanded by remember { mutableStateOf(false) }
    var indAssistanceExpanded by remember { mutableStateOf(false) }
    var memberGenderExpanded by remember { mutableStateOf(false) }
    var memberAssistanceExpanded by remember { mutableStateOf(false) }

    val zoneOptions = listOf("Zone A (North)", "Zone B (South)", "Zone C (East)", "Zone D (West)")
    val categoryOptions = listOf("Alandi", "Dehu", "Other")
    val genderOptions = listOf("Male", "Female", "Other")
    val assistanceOptions = listOf("None Required", "Wheelchair Access", "Medical Support", "Elderly Support")

    Scaffold(
        topBar = {
            Column {
                SevakTopAppBar(
                    title = "Registration",
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
            // Segmented Control: DHINDI vs INDIVIDUAL matching Image 2
            Surface(
                shape = RoundedCornerShape(8.dp),
                color = SurfaceContainerLowest,
                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineColor.copy(alpha = 0.6f)),
                shadowElevation = 1.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(4.dp)
                ) {
                    // DHINDI Tab
                    Surface(
                        shape = RoundedCornerShape(6.dp),
                        color = if (activeTab == "DHINDI") Color(0xFFF2851C) else Color.Transparent,
                        modifier = Modifier
                            .weight(1f)
                            .clickable { activeTab = "DHINDI" }
                            .testTag("tab_dhindi")
                    ) {
                        Text(
                            text = "DHINDI",
                            style = MaterialTheme.typography.labelLarge.copy(
                                fontWeight = FontWeight.Bold,
                                color = if (activeTab == "DHINDI") Color(0xFF2C1600) else Color(0xFF1E1E1E),
                                letterSpacing = 0.5.sp
                            ),
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center,
                            modifier = Modifier.padding(vertical = 10.dp)
                        )
                    }

                    // INDIVIDUAL Tab
                    Surface(
                        shape = RoundedCornerShape(6.dp),
                        color = if (activeTab == "INDIVIDUAL") Color(0xFFF2851C) else Color.Transparent,
                        modifier = Modifier
                            .weight(1f)
                            .clickable { activeTab = "INDIVIDUAL" }
                            .testTag("tab_individual")
                    ) {
                        Text(
                            text = "INDIVIDUAL",
                            style = MaterialTheme.typography.labelLarge.copy(
                                fontWeight = FontWeight.Bold,
                                color = if (activeTab == "INDIVIDUAL") Color(0xFF2C1600) else Color(0xFF1E1E1E),
                                letterSpacing = 0.5.sp
                            ),
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center,
                            modifier = Modifier.padding(vertical = 10.dp)
                        )
                    }
                }
            }

            if (activeTab == "DHINDI") {
                // Dindi Details Card
                Surface(
                    shape = RoundedCornerShape(12.dp),
                    color = SurfaceContainerLowest,
                    border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                    shadowElevation = 1.dp,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(14.dp)
                    ) {
                        Text(
                            text = "Dindi Details",
                            style = MaterialTheme.typography.headlineMedium.copy(
                                fontWeight = FontWeight.Bold,
                                color = OnSurfaceColor
                            )
                        )

                        FormField(label = "Dindi Name") {
                            OutlinedTextField(
                                value = dindiName,
                                onValueChange = { dindiName = it },
                                placeholder = { Text("Enter Dindi Name") },
                                singleLine = true,
                                shape = RoundedCornerShape(6.dp),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }

                        FormField(label = "Registration ID") {
                            OutlinedTextField(
                                value = regId,
                                onValueChange = { regId = it },
                                placeholder = { Text("e.g. DND-2023-458") },
                                singleLine = true,
                                shape = RoundedCornerShape(6.dp),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }

                        FormField(label = "Leader Name") {
                            OutlinedTextField(
                                value = leaderName,
                                onValueChange = { leaderName = it },
                                placeholder = { Text("Full Name") },
                                singleLine = true,
                                shape = RoundedCornerShape(6.dp),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }

                        FormField(label = "Mobile Number") {
                            OutlinedTextField(
                                value = mobileNumber,
                                onValueChange = { mobileNumber = it },
                                placeholder = { Text("+91") },
                                singleLine = true,
                                shape = RoundedCornerShape(6.dp),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }

                        FormField(label = "Member Estimate") {
                            OutlinedTextField(
                                value = memberEstimate,
                                onValueChange = { memberEstimate = it },
                                placeholder = { Text("Total expected members") },
                                singleLine = true,
                                shape = RoundedCornerShape(6.dp),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }

                        FormField(label = "Arrival Zone") {
                            ExposedDropdownMenuBox(
                                expanded = zoneDropdownExpanded,
                                onExpandedChange = { zoneDropdownExpanded = !zoneDropdownExpanded }
                            ) {
                                OutlinedTextField(
                                    value = arrivalZone,
                                    onValueChange = {},
                                    readOnly = true,
                                    trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = zoneDropdownExpanded) },
                                    shape = RoundedCornerShape(6.dp),
                                    modifier = Modifier
                                        .menuAnchor()
                                        .fillMaxWidth()
                                )
                                ExposedDropdownMenu(
                                    expanded = zoneDropdownExpanded,
                                    onDismissRequest = { zoneDropdownExpanded = false }
                                ) {
                                    zoneOptions.forEach { z ->
                                        DropdownMenuItem(
                                            text = { Text(z) },
                                            onClick = {
                                                arrivalZone = z
                                                zoneDropdownExpanded = false
                                            }
                                        )
                                    }
                                }
                            }
                        }

                        FormField(label = "Expected Arrival") {
                            OutlinedTextField(
                                value = expectedArrival,
                                onValueChange = { expectedArrival = it },
                                trailingIcon = { Icon(Icons.Default.CalendarMonth, contentDescription = null) },
                                singleLine = true,
                                shape = RoundedCornerShape(6.dp),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }

                        FormField(label = "Category") {
                            ExposedDropdownMenuBox(
                                expanded = categoryDropdownExpanded,
                                onExpandedChange = { categoryDropdownExpanded = !categoryDropdownExpanded }
                            ) {
                                OutlinedTextField(
                                    value = category,
                                    onValueChange = {},
                                    readOnly = true,
                                    trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = categoryDropdownExpanded) },
                                    shape = RoundedCornerShape(6.dp),
                                    modifier = Modifier
                                        .menuAnchor()
                                        .fillMaxWidth()
                                )
                                ExposedDropdownMenu(
                                    expanded = categoryDropdownExpanded,
                                    onDismissRequest = { categoryDropdownExpanded = false }
                                ) {
                                    categoryOptions.forEach { c ->
                                        DropdownMenuItem(
                                            text = { Text(c) },
                                            onClick = {
                                                category = c
                                                categoryDropdownExpanded = false
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }

                // Member Registration Accordion
                Surface(
                    shape = RoundedCornerShape(12.dp),
                    color = SurfaceContainerLowest,
                    border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                    shadowElevation = 1.dp,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .background(SurfaceContainerLow)
                                .clickable { isMemberSectionExpanded = !isMemberSectionExpanded }
                                .padding(16.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column {
                                Text(
                                    text = "Member Registration",
                                    style = MaterialTheme.typography.headlineMedium.copy(
                                        fontWeight = FontWeight.Bold,
                                        color = OnSurfaceColor
                                    )
                                )
                                Text(
                                    text = "Manage individuals in this Dindi",
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        color = OnSurfaceVariantColor
                                    )
                                )
                            }
                            Icon(
                                imageVector = if (isMemberSectionExpanded) Icons.Default.ExpandLess else Icons.Default.ExpandMore,
                                contentDescription = null,
                                tint = OnSurfaceColor
                            )
                        }

                        AnimatedVisibility(visible = isMemberSectionExpanded) {
                            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
                                // Progress Bar
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Text(
                                        text = "Registration Progress",
                                        style = MaterialTheme.typography.bodyMedium.copy(
                                            color = OnSurfaceVariantColor
                                        )
                                    )
                                    Text(
                                        text = "93.5%",
                                        style = MaterialTheme.typography.labelLarge.copy(
                                            fontWeight = FontWeight.Bold,
                                            color = PrimaryColor
                                        )
                                    )
                                }
                                LinearProgressIndicator(
                                    progress = { 0.935f },
                                    color = PrimaryColor,
                                    trackColor = SurfaceVariantColor,
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .height(8.dp)
                                        .clip(RoundedCornerShape(4.dp))
                                )

                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    Surface(
                                        shape = RoundedCornerShape(8.dp),
                                        color = SurfaceContainerLowest,
                                        border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                                        modifier = Modifier.weight(1f)
                                    ) {
                                        Column(
                                            modifier = Modifier.padding(10.dp),
                                            horizontalAlignment = Alignment.CenterHorizontally
                                        ) {
                                            Text(
                                                text = "${187 + dindiFormData.members.size}",
                                                style = MaterialTheme.typography.headlineMedium.copy(
                                                    fontWeight = FontWeight.Bold,
                                                    color = OnSurfaceColor
                                                )
                                            )
                                            Text(
                                                text = "Registered",
                                                style = MaterialTheme.typography.labelSmall.copy(
                                                    color = OnSurfaceVariantColor
                                                )
                                            )
                                        }
                                    }
                                    Surface(
                                        shape = RoundedCornerShape(8.dp),
                                        color = SurfaceContainerLowest,
                                        border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                                        modifier = Modifier.weight(1f)
                                    ) {
                                        Column(
                                            modifier = Modifier.padding(10.dp),
                                            horizontalAlignment = Alignment.CenterHorizontally
                                        ) {
                                            Text(
                                                text = "200",
                                                style = MaterialTheme.typography.headlineMedium.copy(
                                                    fontWeight = FontWeight.Bold,
                                                    color = OnSurfaceColor
                                                )
                                            )
                                            Text(
                                                text = "Expected",
                                                style = MaterialTheme.typography.labelSmall.copy(
                                                    color = OnSurfaceVariantColor
                                                )
                                            )
                                        }
                                    }
                                }

                                HorizontalDivider(color = SurfaceVariantColor)

                                // Add New Member Subform
                                Text(
                                    text = "Add New Member",
                                    style = MaterialTheme.typography.labelLarge.copy(
                                        fontWeight = FontWeight.Bold,
                                        color = OnSurfaceColor
                                    )
                                )

                                OutlinedTextField(
                                    value = newMemberName,
                                    onValueChange = { newMemberName = it },
                                    placeholder = { Text("Full Name") },
                                    singleLine = true,
                                    shape = RoundedCornerShape(6.dp),
                                    modifier = Modifier.fillMaxWidth()
                                )

                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                                ) {
                                    OutlinedTextField(
                                        value = newMemberAge,
                                        onValueChange = { newMemberAge = it },
                                        placeholder = { Text("Age") },
                                        singleLine = true,
                                        shape = RoundedCornerShape(6.dp),
                                        modifier = Modifier.weight(1f)
                                    )

                                    ExposedDropdownMenuBox(
                                        expanded = memberGenderExpanded,
                                        onExpandedChange = { memberGenderExpanded = !memberGenderExpanded },
                                        modifier = Modifier.weight(2f)
                                    ) {
                                        OutlinedTextField(
                                            value = newMemberGender,
                                            onValueChange = {},
                                            readOnly = true,
                                            trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = memberGenderExpanded) },
                                            shape = RoundedCornerShape(6.dp),
                                            modifier = Modifier.menuAnchor()
                                        )
                                        ExposedDropdownMenu(
                                            expanded = memberGenderExpanded,
                                            onDismissRequest = { memberGenderExpanded = false }
                                        ) {
                                            genderOptions.forEach { g ->
                                                DropdownMenuItem(
                                                    text = { Text(g) },
                                                    onClick = {
                                                        newMemberGender = g
                                                        memberGenderExpanded = false
                                                    }
                                                )
                                            }
                                        }
                                    }
                                }

                                OutlinedTextField(
                                    value = newMemberMobile,
                                    onValueChange = { newMemberMobile = it },
                                    placeholder = { Text("Mobile Number") },
                                    singleLine = true,
                                    shape = RoundedCornerShape(6.dp),
                                    modifier = Modifier.fillMaxWidth()
                                )

                                OutlinedTextField(
                                    value = newMemberEmergency,
                                    onValueChange = { newMemberEmergency = it },
                                    placeholder = { Text("Emergency Contact") },
                                    singleLine = true,
                                    shape = RoundedCornerShape(6.dp),
                                    modifier = Modifier.fillMaxWidth()
                                )

                                Button(
                                    onClick = {
                                        if (newMemberName.isNotBlank()) {
                                            repository.addDindiMember(
                                                DindiMember(
                                                    name = newMemberName,
                                                    age = newMemberAge.toIntOrNull() ?: 30,
                                                    gender = newMemberGender,
                                                    mobile = newMemberMobile,
                                                    emergencyContact = newMemberEmergency,
                                                    assistance = newMemberAssistance
                                                )
                                            )
                                            Toast.makeText(context, "Member $newMemberName Added!", Toast.LENGTH_SHORT).show()
                                            newMemberName = ""
                                            newMemberAge = ""
                                            newMemberMobile = ""
                                            newMemberEmergency = ""
                                        }
                                    },
                                    colors = ButtonDefaults.buttonColors(
                                        containerColor = SecondaryContainerColor,
                                        contentColor = OnSecondaryContainerColor
                                    ),
                                    shape = RoundedCornerShape(999.dp),
                                    modifier = Modifier.fillMaxWidth()
                                ) {
                                    Icon(Icons.Default.Add, contentDescription = null, modifier = Modifier.size(16.dp))
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(
                                        text = "Add Member",
                                        style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold)
                                    )
                                }
                            }
                        }
                    }
                }
            } else {
                // Individual Section
                Surface(
                    shape = RoundedCornerShape(12.dp),
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
                                text = "Personal Details",
                                style = MaterialTheme.typography.headlineMedium.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = OnSurfaceColor
                                )
                            )
                            Surface(
                                shape = RoundedCornerShape(999.dp),
                                color = SecondaryFixed,
                                modifier = Modifier.padding(4.dp)
                            ) {
                                Text(
                                    text = "ID: IND-8492-X",
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        fontFamily = FontFamily.Monospace,
                                        fontWeight = FontWeight.Bold,
                                        color = OnSecondaryFixed
                                    ),
                                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                                )
                            }
                        }

                        FormField(label = "Full Name") {
                            OutlinedTextField(
                                value = indFullName,
                                onValueChange = { indFullName = it },
                                placeholder = { Text("Enter Full Name") },
                                singleLine = true,
                                shape = RoundedCornerShape(6.dp),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            FormField(label = "Age", modifier = Modifier.weight(1f)) {
                                OutlinedTextField(
                                    value = indAge,
                                    onValueChange = { indAge = it },
                                    placeholder = { Text("Years") },
                                    singleLine = true,
                                    shape = RoundedCornerShape(6.dp),
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }

                            FormField(label = "Gender", modifier = Modifier.weight(1f)) {
                                ExposedDropdownMenuBox(
                                    expanded = indGenderExpanded,
                                    onExpandedChange = { indGenderExpanded = !indGenderExpanded }
                                ) {
                                    OutlinedTextField(
                                        value = indGender,
                                        onValueChange = {},
                                        readOnly = true,
                                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = indGenderExpanded) },
                                        shape = RoundedCornerShape(6.dp),
                                        modifier = Modifier.menuAnchor()
                                    )
                                    ExposedDropdownMenu(
                                        expanded = indGenderExpanded,
                                        onDismissRequest = { indGenderExpanded = false }
                                    ) {
                                        genderOptions.forEach { g ->
                                            DropdownMenuItem(
                                                text = { Text(g) },
                                                onClick = {
                                                    indGender = g
                                                    indGenderExpanded = false
                                                }
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        FormField(label = "Mobile Number") {
                            OutlinedTextField(
                                value = indMobile,
                                onValueChange = { indMobile = it },
                                singleLine = true,
                                shape = RoundedCornerShape(6.dp),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }

                        FormField(label = "Emergency Contact") {
                            OutlinedTextField(
                                value = indEmergency,
                                onValueChange = { indEmergency = it },
                                singleLine = true,
                                shape = RoundedCornerShape(6.dp),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }

                        FormField(label = "Current Location (City/Village)") {
                            OutlinedTextField(
                                value = indLocation,
                                onValueChange = { indLocation = it },
                                placeholder = { Text("Where are you starting from?") },
                                singleLine = true,
                                shape = RoundedCornerShape(6.dp),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }

                        FormField(label = "Expected Arrival") {
                            OutlinedTextField(
                                value = indArrival,
                                onValueChange = { indArrival = it },
                                singleLine = true,
                                shape = RoundedCornerShape(6.dp),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }

                        FormField(label = "Special Assistance") {
                            ExposedDropdownMenuBox(
                                expanded = indAssistanceExpanded,
                                onExpandedChange = { indAssistanceExpanded = !indAssistanceExpanded }
                            ) {
                                OutlinedTextField(
                                    value = indAssistance,
                                    onValueChange = {},
                                    readOnly = true,
                                    trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = indAssistanceExpanded) },
                                    shape = RoundedCornerShape(6.dp),
                                    modifier = Modifier
                                        .menuAnchor()
                                        .fillMaxWidth()
                                )
                                ExposedDropdownMenu(
                                    expanded = indAssistanceExpanded,
                                    onDismissRequest = { indAssistanceExpanded = false }
                                ) {
                                    assistanceOptions.forEach { a ->
                                        DropdownMenuItem(
                                            text = { Text(a) },
                                            onClick = {
                                                indAssistance = a
                                                indAssistanceExpanded = false
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Darshan Token Ready Card (Common)
            Surface(
                shape = RoundedCornerShape(12.dp),
                color = SurfaceContainerLowest,
                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineVariantColor),
                shadowElevation = 1.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    Text(
                        text = "Darshan Token Ready",
                        style = MaterialTheme.typography.headlineMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = OnSurfaceColor
                        )
                    )
                    Text(
                        text = "Complete registration to enter the digital queue for smooth Darshan allocation.",
                        style = MaterialTheme.typography.bodySmall.copy(
                            color = OnSurfaceVariantColor
                        )
                    )

                    // 3-Step Stepper matching Image 2
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        StepperItem(
                            step = "Register",
                            icon = Icons.Default.Apps,
                            isActive = true
                        )
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .height(3.dp)
                                .background(Color(0xFF864303))
                        )
                        StepperItem(
                            step = "Check-in",
                            icon = Icons.Default.HowToReg,
                            isActive = false
                        )
                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .height(3.dp)
                                .background(Color(0xFFE0E0E0))
                        )
                        StepperItem(
                            step = "Token",
                            icon = Icons.Default.ConfirmationNumber,
                            isActive = false
                        )
                    }

                    // Token Preview Card
                    Surface(
                        shape = RoundedCornerShape(10.dp),
                        color = Color(0xFFFBF8F5),
                        border = androidx.compose.foundation.BorderStroke(1.dp, OutlineColor.copy(alpha = 0.4f)),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column(
                            modifier = Modifier.padding(14.dp),
                            verticalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column {
                                    Text(
                                        text = "PREVIEW DARSHAN TOKEN",
                                        style = MaterialTheme.typography.labelSmall.copy(
                                            color = OnSurfaceVariantColor,
                                            letterSpacing = 0.5.sp,
                                            fontWeight = FontWeight.Bold
                                        )
                                    )
                                    Text(
                                        text = "Batch B-17",
                                        style = MaterialTheme.typography.headlineMedium.copy(
                                            fontWeight = FontWeight.Bold,
                                            color = OnSurfaceColor
                                        )
                                    )
                                }
                                Surface(
                                    shape = RoundedCornerShape(4.dp),
                                    color = Color(0xFFF2851C)
                                ) {
                                    Text(
                                        text = "MOCK",
                                        style = MaterialTheme.typography.labelSmall.copy(
                                            color = Color(0xFF2C1600),
                                            fontWeight = FontWeight.Bold,
                                            fontFamily = FontFamily.Monospace
                                        ),
                                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                                    )
                                }
                            }

                            Surface(
                                shape = RoundedCornerShape(6.dp),
                                color = Color.White,
                                border = androidx.compose.foundation.BorderStroke(1.dp, OutlineColor.copy(alpha = 0.3f))
                            ) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(10.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.Schedule,
                                        contentDescription = null,
                                        tint = Color(0xFF864303),
                                        modifier = Modifier.size(18.dp)
                                    )
                                    Text(
                                        text = "Window: 04:30 PM - 05:00 PM",
                                        style = MaterialTheme.typography.labelLarge.copy(
                                            fontWeight = FontWeight.SemiBold,
                                            color = OnSurfaceColor
                                        )
                                    )
                                }
                            }
                        }
                    }
                }
            }

            // Submit Button matching Image 2
            Button(
                onClick = {
                    Toast.makeText(context, "Registration Submitted & Stored Offline/Online!", Toast.LENGTH_LONG).show()
                    onBack()
                },
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFF864303),
                    contentColor = Color.White
                ),
                shape = RoundedCornerShape(999.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp)
                    .testTag("submit_registration_button")
            ) {
                Text(
                    text = "Submit Registration",
                    style = MaterialTheme.typography.labelLarge.copy(
                        fontWeight = FontWeight.Bold,
                        fontSize = 16.sp,
                        color = Color.White
                    )
                )
                Spacer(modifier = Modifier.width(8.dp))
                Icon(
                    imageVector = Icons.Default.CheckCircle,
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.size(20.dp)
                )
            }

            Spacer(modifier = Modifier.height(20.dp))
        }
    }
}

@Composable
private fun FormField(
    label: String,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall.copy(
                color = OnSurfaceVariantColor,
                fontWeight = FontWeight.Medium
            )
        )
        content()
    }
}

@Composable
private fun StepperItem(
    step: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    isActive: Boolean
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        Box(
            modifier = Modifier
                .size(36.dp)
                .clip(CircleShape)
                .background(if (isActive) Color(0xFF864303) else Color(0xFFE0E0E0)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = if (isActive) Color.White else Color(0xFF6E6E6E),
                modifier = Modifier.size(18.dp)
            )
        }
        Text(
            text = step,
            style = MaterialTheme.typography.labelSmall.copy(
                fontSize = 11.sp,
                fontWeight = if (isActive) FontWeight.Bold else FontWeight.Normal,
                color = if (isActive) Color(0xFF864303) else OnSurfaceVariantColor
            )
        )
    }
}
